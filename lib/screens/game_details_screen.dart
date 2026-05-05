import 'package:board_game_app/widgets/field_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:board_game_app/data/models/board_game.dart';
import 'package:board_game_app/app/layout.dart';
import 'package:board_game_app/app/theme.dart';
import 'package:board_game_app/localization/localization.dart';
import 'package:board_game_app/utils/app_helpers.dart';
import 'package:board_game_app/data/models/board_game.dart';

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
              padding: Layout.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Game Name
                  Text(
                    widget.game!.name,
                    style: AppTextStyles.font22.copyWith(
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
                      child: Column(
                        children: [
                          Text(
                            '${AppLocalization.buyOnButton} ${AppHelpers.getStoreLabel(widget.game!.lowestPriceStore)}',
                            style: AppTextStyles.font20,
                          ),
                          Layout.heightBox(4),
                          Text(AppHelpers.formatPrice(widget.game!.lowestPrice),
                              style: AppTextStyles.font20
                                  .copyWith(fontWeight: FontWeight.w900)),
                        ],
                      )),

                  Layout.heightBox(16),

                  SectionHeader(title: AppLocalization.pricePerStore)
                ],
              )),
        ),
      ),
    );
  }
}
