import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/localization/localization.dart';

class GameCard extends StatefulWidget {
  final BoardGame game;

  const GameCard({super.key, required this.game});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  int _imageIndex = 0;

  String _formatPrice(int price) {
    final str = price.toString();
    final offset = str.length % 3;
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (i - offset) % 3 == 0 && i >= offset) buffer.write('.');
      buffer.write(str[i]);
    }
    return '${buffer.toString()},00 RSD';
  }

  Widget _buildImage(List<String> urls) {
    if (urls.isEmpty || _imageIndex >= urls.length) {
      return Icon(
        Icons.image_outlined,
        color: AppColors.textMuted,
        size: Layout.v(120),
      );
    }

    return CachedNetworkImage(
      imageUrl: urls[_imageIndex],
      fit: BoxFit.contain,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorWidget: (context, url, error) {
        if (_imageIndex < urls.length - 1) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _imageIndex++);
          });
          return const Center(child: CircularProgressIndicator(strokeWidth: 2));
        }
        return SizedBox(
          height: Layout.v(120),
          child: Icon(
            Icons.broken_image_outlined,
            color: AppColors.textMuted,
            size: Layout.v(40),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.game.imageUrls;

    return GestureDetector(
      onTap: () =>
          context.push('/product/${widget.game.id}', extra: widget.game),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Layout.v(12)),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Game Title
            Padding(
              padding: Layout.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                height: Layout.v(44),
                child: Center(
                  child: Text(
                    widget.game.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font14.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

            Divider(color: AppColors.divider, thickness: 1, height: 1),

            // Game Image
            Padding(
              padding: Layout.symmetric(vertical: 12, horizontal: 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: Layout.v(120)),
                child: _buildImage(urls),
              ),
            ),

            Divider(color: AppColors.divider, thickness: 1, height: 1),

            // Game Price
            Padding(
              padding: Layout.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                height: Layout.v(44),
                child: widget.game.lowestPrice > 0
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppLocalization.lowestPrice,
                            style: AppTextStyles.font12.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Text(
                            _formatPrice(widget.game.lowestPrice),
                            style: AppTextStyles.font14.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      )
                    : Align(
                        alignment: Alignment.center,
                        child: Text(
                          AppLocalization.notAvailable,
                          style: AppTextStyles.font14.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
