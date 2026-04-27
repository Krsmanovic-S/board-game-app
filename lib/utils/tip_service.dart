import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class TipService extends ChangeNotifier {
  static const _tipIds = {
    'shelfwatch_tip_small',
    'shelfwatch_tip_medium',
    'shelfwatch_tip_large',
  };

  final _iap = InAppPurchase.instance;
  StreamSubscription? _sub;

  List<ProductDetails> products = [];
  bool available = false;
  bool loading = true;

  Future<void> init() async {
    available = await _iap.isAvailable();
    if (!available) {
      loading = false;
      notifyListeners();
      return;
    }

    _sub = _iap.purchaseStream.listen(_onPurchaseUpdate);

    final response = await _iap.queryProductDetails(_tipIds);
    products = response.productDetails
      ..sort((a, b) => a.rawPrice.compareTo(b.rawPrice));

    loading = false;
    notifyListeners();
  }

  Future<void> tip(ProductDetails product) async {
    final param = PurchaseParam(productDetails: product);
    await _iap.buyConsumable(purchaseParam: param);
  }

  Future<void> tipById(String productId) async {
    final product = products.firstWhere((p) => p.id == productId);
    await tip(product);
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchases) {
    for (final p in purchases) {
      if (p.status == PurchaseStatus.purchased ||
          p.status == PurchaseStatus.restored) {
        _iap.completePurchase(p); // critical — never skip this
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
