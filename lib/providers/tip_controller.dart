import 'package:flutter/material.dart';
import 'package:board_game_app/utils/tip_service.dart';

class TipServiceScope extends InheritedNotifier<TipService> {
  const TipServiceScope({
    super.key,
    required TipService tipService,
    required super.child,
  }) : super(notifier: tipService);

  static TipService of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TipServiceScope>()!
        .notifier!;
  }
}
