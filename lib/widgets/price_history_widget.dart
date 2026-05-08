import 'package:flutter/material.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/controllers/games_controller.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/utils/app_helpers.dart';
import 'package:board_game_app/data/models/price_list_entry.dart';

class PriceHistoryWidget extends StatefulWidget {
  final String gameId;

  const PriceHistoryWidget({super.key, required this.gameId});

  @override
  State<PriceHistoryWidget> createState() => _PriceHistoryWidgetState();
}

class _PriceHistoryWidgetState extends State<PriceHistoryWidget> {
  List<PriceHistoryEntry>? _entries;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_entries == null && _loading) {
      _fetch();
    }
  }

  Future<void> _fetch() async {
    final entries = await GamesScope.of(context).getPriceHistory(widget.gameId);
    if (mounted) {
      setState(() {
        _entries = entries;
        _loading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Maj',
      'Jun',
      'Jul',
      'Avg',
      'Sep',
      'Okt',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildTrendIcon(int index) {
    final entries = _entries!;
    // Last entry (oldest) has no arrow
    if (index == entries.length - 1) return const SizedBox(width: 20);

    final current = entries[index].lowestPrice;
    final previous = entries[index + 1].lowestPrice;

    if (current < previous) {
      return Icon(Icons.arrow_downward_rounded,
          color: AppColors.primary, size: Layout.v(22));
    } else if (current > previous) {
      return Icon(Icons.arrow_upward_rounded,
          color: AppColors.error, size: Layout.v(22));
    } else {
      return Icon(Icons.remove_rounded,
          color: AppColors.textMuted, size: Layout.v(22));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (_entries == null || _entries!.isEmpty) {
      return Center(
        child: Text(
          AppLocalization.noPriceHistory,
          style: AppTextStyles.font16.copyWith(color: AppColors.textMuted),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(Layout.v(12)),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      constraints: BoxConstraints(maxHeight: Layout.v(220)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Layout.v(12)),
        child: SingleChildScrollView(
          child: Column(
            children: List.generate(_entries!.length, (index) {
              final entry = _entries![index];
              final isLast = index == _entries!.length - 1;

              return Column(
                children: [
                  Padding(
                    padding: Layout.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        // Date - 50% width
                        Expanded(
                          child: Text(
                            _formatDate(entry.recordedAt),
                            style: AppTextStyles.font14.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        // Trend icon + price - 50% width
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _buildTrendIcon(index),
                              Layout.widthBox(6),
                              Text(
                                AppHelpers.formatPrice(entry.lowestPrice),
                                style: AppTextStyles.font14.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast)
                    Divider(
                      color: AppColors.divider,
                      thickness: 1,
                      height: 1,
                    ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
