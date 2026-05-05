import 'package:board_game_app/widgets/field_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/utils/app_helpers.dart';
import 'package:board_game_app/widgets/settings_buttons.dart';

class GameDetailsScreen extends StatefulWidget {
  final String gameId;
  final BoardGame? game;
  final String? initialImageUrl;

  const GameDetailsScreen(
      {super.key, required this.gameId, this.game, this.initialImageUrl});

  @override
  State<GameDetailsScreen> createState() => _GameDetailsScreenState();
}

class _GameDetailsScreenState extends State<GameDetailsScreen> {
  bool _isWatched = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildPriceGrid() {
    final stores = widget.game!.storeInfo.entries.toList();

    return Container(
      decoration: context.cardDecoration,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Layout.v(12)),
        child: Table(
          border: TableBorder(
            horizontalInside: BorderSide(color: AppColors.divider, width: 1),
            verticalInside: BorderSide(color: AppColors.divider, width: 1),
          ),
          children: [
            // Row 1
            TableRow(
              children: [
                _buildStoreCell(stores[1]),
                _buildStoreCell(stores[3]),
              ],
            ),
            // Row 2
            TableRow(
              children: [
                _buildStoreCell(stores[2]),
                _buildStoreCell(stores[0]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreCell(MapEntry<String, StoreInfo>? store) {
    if (store == null) return const SizedBox.shrink();

    final String assetPath = 'assets/images/${store.key}.png';

    return Padding(
      padding: Layout.all(12),
      child: Column(
        children: [
          // Store Logo and Name
          Container(
            padding: Layout.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Layout.v(20)),
              color: AppHelpers.getStoreColor(store.key),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset(
                  assetPath,
                  width: Layout.v(36),
                  height: Layout.v(36),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.store,
                    size: Layout.v(18),
                  ),
                ),
                Layout.widthBox(4),
                Text(
                  AppHelpers.getStoreLabel(store.key),
                  style: AppTextStyles.font12.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Layout.heightBox(8),

          // Price Info
          Text(
            store.value.price != 0
                ? AppHelpers.formatPrice(store.value.price)
                : AppLocalization.notAvailable,
            style: AppTextStyles.font18.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? targetUrl =
        widget.game!.storeInfo[widget.game!.lowestPriceStore]?.sourceUrl;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(gradient: AppColors.scaffoldGradient),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            elevation: 0,
            title: Text(AppLocalization.gameDetailsAppBar),
            foregroundColor: AppColors.secondary,
            leadingWidth: Layout.v(70),
            titleSpacing: 0,
            actionsPadding: Layout.only(right: 20),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isWatched = !_isWatched;
                    });
                  },
                  icon: Icon(
                    _isWatched
                        ? Icons.bookmark_remove
                        : Icons.bookmark_add_outlined,
                    size: Layout.v(28),
                  ))
            ],
          ),
          body: SingleChildScrollView(
              padding: Layout.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Game Name
                  Text(
                    widget.game!.name,
                    style: AppTextStyles.font20.copyWith(
                        fontSize: Layout.v(28),
                        fontWeight: FontWeight.w800,
                        height: 1.1),
                    textAlign: TextAlign.center,
                  ),

                  Layout.heightBox(16),

                  // Hero Card
                  Container(
                    width: double.infinity,
                    decoration: context.cardDecoration,
                    child: Padding(
                      padding: Layout.symmetric(horizontal: 24, vertical: 24),
                      child: Hero(
                        tag: 'game_image_${widget.gameId}',
                        child: CachedNetworkImage(
                          imageUrl: widget.initialImageUrl ??
                              widget.game?.imageUrls.first ??
                              '',
                          fit: BoxFit.contain,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.image),
                        ),
                      ),
                    ),
                  ),

                  Layout.heightBox(16),

                  // Buy Now Button
                  ElevatedButton(
                      onPressed: targetUrl != null
                          ? () => AppHelpers.launchStoreUrl(targetUrl)
                          : null,
                      child: widget.game!.inStockAnywhere
                          ? Column(
                              children: [
                                Text(
                                  '${AppLocalization.buyOnButton} ${AppHelpers.getStoreLabel(widget.game!.lowestPriceStore)}',
                                  style: AppTextStyles.font18,
                                ),
                                Layout.heightBox(4),
                                Text(
                                    AppHelpers.formatPrice(
                                        widget.game!.lowestPrice),
                                    style: AppTextStyles.font18
                                        .copyWith(fontWeight: FontWeight.w900)),
                              ],
                            )
                          : Text(AppLocalization.notAvailable)),

                  Layout.heightBox(16),

                  SectionHeader(title: AppLocalization.pricePerStore),

                  Layout.heightBox(16),

                  _buildPriceGrid(),

                  Layout.heightBox(16),

                  SectionHeader(title: AppLocalization.notifications),

                  Layout.heightBox(16),

                  // Notification Settings - price drop and increase, out of and back in stock
                  SwitchRow(
                      label: AppLocalization.priceDropLabel,
                      value: false,
                      onChanged: (value) {}),
                  Layout.heightBox(8),
                  SwitchRow(
                      label: AppLocalization.priceIncreaseLabel,
                      value: false,
                      onChanged: (value) {}),
                  Layout.heightBox(8),
                  SwitchRow(
                      label: AppLocalization.outOfStockLabel,
                      value: false,
                      onChanged: (value) {}),
                  Layout.heightBox(8),
                  SwitchRow(
                      label: AppLocalization.backInStockLabel,
                      value: false,
                      onChanged: (value) {}),
                ],
              )),
        ),
      ),
    );
  }
}
