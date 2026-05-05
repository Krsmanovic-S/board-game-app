import 'package:cloud_firestore/cloud_firestore.dart';

class WatchlistItem {
  final String productId;
  final bool notifyPriceDrop;
  final bool notifyPriceIncrease;
  final bool notifyOutOfStock;
  final bool notifyBackInStock;
  final Timestamp addedAt;

  const WatchlistItem({
    required this.productId,
    required this.notifyPriceDrop,
    required this.notifyPriceIncrease,
    required this.notifyOutOfStock,
    required this.notifyBackInStock,
    required this.addedAt,
  });

  WatchlistItem copyWith({
    bool? notifyPriceDrop,
    bool? notifyPriceIncrease,
    bool? notifyOutOfStock,
    bool? notifyBackInStock,
  }) =>
      WatchlistItem(
        productId: productId,
        notifyPriceDrop: notifyPriceDrop ?? this.notifyPriceDrop,
        notifyPriceIncrease: notifyPriceIncrease ?? this.notifyPriceIncrease,
        notifyOutOfStock: notifyOutOfStock ?? this.notifyOutOfStock,
        notifyBackInStock: notifyBackInStock ?? this.notifyBackInStock,
        addedAt: addedAt,
      );

  WatchlistItem withField(String field, bool value) {
    switch (field) {
      case 'notifyPriceDrop':
        return copyWith(notifyPriceDrop: value);
      case 'notifyPriceIncrease':
        return copyWith(notifyPriceIncrease: value);
      case 'notifyOutOfStock':
        return copyWith(notifyOutOfStock: value);
      case 'notifyBackInStock':
        return copyWith(notifyBackInStock: value);
      default:
        return this;
    }
  }

  factory WatchlistItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WatchlistItem(
      productId: data['productId'] as String? ?? doc.id,
      notifyPriceDrop: data['notifyPriceDrop'] as bool? ?? true,
      notifyPriceIncrease: data['notifyPriceIncrease'] as bool? ?? true,
      notifyOutOfStock: data['notifyOutOfStock'] as bool? ?? true,
      notifyBackInStock: data['notifyBackInStock'] as bool? ?? true,
      addedAt: data['addedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'productId': productId,
        'notifyPriceDrop': notifyPriceDrop,
        'notifyPriceIncrease': notifyPriceIncrease,
        'notifyOutOfStock': notifyOutOfStock,
        'notifyBackInStock': notifyBackInStock,
        'addedAt': addedAt,
      };
}
