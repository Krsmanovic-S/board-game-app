import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class TipService extends ChangeNotifier {
  static const _tipIds = {
    'app_tip_small',
    'app_tip_medium',
    'app_tip_large',
  };

  final _iap = InAppPurchase.instance;
  StreamSubscription? _sub;

  List<ProductDetails> products = [];
  bool available = false;
  bool loading = true;
  bool purchasing = false;

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
    purchasing = true;
    notifyListeners();
    try {
      final param = PurchaseParam(productDetails: product);
      await _iap.buyConsumable(purchaseParam: param);
    } catch (_) {
      purchasing = false;
      notifyListeners();
    }
  }

  Future<void> tipById(String productId) async {
    final product = products.cast<ProductDetails?>().firstWhere(
          (p) => p?.id == productId,
          orElse: () => null,
        );

    if (product == null) {
      debugPrint("Product $productId not found or store not loaded yet.");
      return;
    }

    await tip(product);
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final p in purchases) {
      switch (p.status) {
        case PurchaseStatus.pending:
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          if (p.pendingCompletePurchase) await _iap.completePurchase(p);
          purchasing = false;
          notifyListeners();
        case PurchaseStatus.error:
        case PurchaseStatus.canceled:
          purchasing = false;
          notifyListeners();
      }
      // iOS: always complete if still pending after status handling
      if (p.pendingCompletePurchase) await _iap.completePurchase(p);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
