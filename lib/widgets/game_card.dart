import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/localization/localization.dart';

class GameCard extends StatelessWidget {
  final BoardGame game;

  const GameCard({super.key, required this.game});

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

  @override
  Widget build(BuildContext context) {
    final imageUrl = game.firstImageUrl;

    return GestureDetector(
      onTap: () => context.go('/product/${game.id}'),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: Layout.symmetric(horizontal: 12, vertical: 8),
              child: SizedBox(
                height: Layout.v(36),
                child: Center(
                  child: Text(
                    game.name,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.font14.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
            Divider(color: AppColors.divider, thickness: 1, height: 1),
            Expanded(
              child: Padding(
                padding: Layout.symmetric(vertical: 16, horizontal: 8),
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.contain,
                        placeholder: (context, url) => const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        ),
                        errorWidget: (context, url, error) => Icon(
                          Icons.broken_image_outlined,
                          color: AppColors.textMuted,
                          size: Layout.v(40),
                        ),
                      )
                    : Center(
                        child: Icon(
                          Icons.image_outlined,
                          color: AppColors.textMuted,
                          size: Layout.v(40),
                        ),
                      ),
              ),
            ),
            Divider(color: AppColors.divider, thickness: 1, height: 1),
            Padding(
              padding: Layout.symmetric(horizontal: 8, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalization.price,
                    style: AppTextStyles.font12.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  Text(
                    _formatPrice(game.lowestPrice),
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
    );
  }
}
