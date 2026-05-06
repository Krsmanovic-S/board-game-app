import 'package:board_game_app/utils/app_helpers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/data/models/watchlist_item.dart';
import 'package:board_game_app/localization/localization.dart';

class WatchlistCard extends StatefulWidget {
  final BoardGame game;
  final WatchlistItem item;

  const WatchlistCard({super.key, required this.game, required this.item});

  @override
  State<WatchlistCard> createState() => _WatchlistCardState();
}

class _WatchlistCardState extends State<WatchlistCard> {
  int _imageIndex = 0;

  Widget _buildImage(List<String> urls) {
    if (urls.isEmpty || _imageIndex >= urls.length) {
      return Icon(
        Icons.image_outlined,
        color: AppColors.textMuted,
        size: Layout.v(48),
      );
    }

    return CachedNetworkImage(
      imageUrl: urls[_imageIndex],
      fit: BoxFit.contain,
      placeholder: (_, __) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (_, __, ___) {
        if (_imageIndex < urls.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _imageIndex++);
          });
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        return Icon(
          Icons.broken_image_outlined,
          color: AppColors.textMuted,
          size: Layout.v(32),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.game.imageUrls;
    final price = widget.game.lowestPrice > 0 && widget.game.inStockAnywhere
        ? AppHelpers.formatPrice(widget.game.lowestPrice)
        : AppLocalization.notAvailable;

    return GestureDetector(
      onTap: () {
        final workingUrl = urls.isNotEmpty ? urls[_imageIndex] : null;
        context.push('/product/${widget.game.id}', extra: {
          'game': widget.game,
          'initialImageUrl': workingUrl,
        });
      },
      child: Container(
        decoration: context.cardDecoration,
        child: Padding(
          padding: Layout.all(12),
          child: Row(
            children: [
              SizedBox(
                width: Layout.v(64),
                height: Layout.v(64),
                child: _buildImage(urls),
              ),
              Layout.widthBox(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.game.name,
                      style: AppTextStyles.font16.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Layout.heightBox(6),
                    Text(
                      price,
                      style: AppTextStyles.font16.copyWith(
                        fontWeight: FontWeight.w800,
                        color: widget.game.lowestPrice > 0 &&
                                widget.game.inStockAnywhere
                            ? AppColors.primary
                            : AppColors.games4you,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: Layout.v(14),
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
