import 'package:cloud_firestore/cloud_firestore.dart';

const _storeOrder = ['games4you', 'mipl', 'gnom', 'kraken'];

class StoreInfo {
  final int price;
  final bool inStock;
  final String image;
  final String sourceUrl;
  final String updatedAt;

  const StoreInfo({
    required this.price,
    required this.inStock,
    required this.image,
    required this.sourceUrl,
    required this.updatedAt,
  });

  factory StoreInfo.fromMap(Map<String, dynamic> map) => StoreInfo(
    price: (map['price'] as num?)?.toInt() ?? 0,
    inStock: map['inStock'] as bool? ?? false,
    image: map['image'] as String? ?? '',
    sourceUrl: map['sourceUrl'] as String? ?? '',
    updatedAt: map['updatedAt'] as String? ?? '',
  );
}

class BoardGame {
  final String id;
  final String name;
  final int lowestPrice;
  final String lowestPriceStore;
  final Map<String, StoreInfo> storeInfo;
  final bool inStockAnywhere;

  const BoardGame({
    required this.id,
    required this.name,
    this.lowestPrice = 0,
    this.lowestPriceStore = '',
    required this.storeInfo,
    this.inStockAnywhere = false,
  });

  String? get firstImageUrl {
    for (final store in _storeOrder) {
      final img = storeInfo[store]?.image;
      if (img != null && img.isNotEmpty) return img;
    }
    return null;
  }

  List<String> get imageUrls {
    final urls = <String>[];
    for (final store in _storeOrder) {
      final img = storeInfo[store]?.image;
      if (img != null && img.isNotEmpty) urls.add(img);
    }
    return urls;
  }

  factory BoardGame.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawStoreInfo = (data['storeInfo'] as Map<String, dynamic>?) ?? {};
    final storeInfo = rawStoreInfo.map(
      (key, val) =>
          MapEntry(key, StoreInfo.fromMap(val as Map<String, dynamic>)),
    );

    bool inStockAnywhere = false;
    for (final info in storeInfo.values) {
      if (info.inStock) {
        inStockAnywhere = true;
        break;
      }
    }

    return BoardGame(
      id: doc.id,
      name: data['name'] as String? ?? '',
      lowestPrice: (data['lowestPrice'] as num?)?.toInt() ?? 0,
      lowestPriceStore: data['lowestPriceStore'] as String? ?? '',
      storeInfo: storeInfo,
      inStockAnywhere: inStockAnywhere,
    );
  }
}
