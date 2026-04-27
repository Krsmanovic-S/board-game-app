class StoreInfo {
  int price;
  bool inStock;
  String image;
  String sourceUrl;
  String updatedAt;

  StoreInfo({
    required this.price,
    required this.inStock,
    required this.image,
    required this.sourceUrl,
    required this.updatedAt,
  });
}

class BoardGame {
  int id;
  String name;
  int lowestPrice;
  String lowestPriceStore;
  Map<String, StoreInfo> storeInfo;
  bool inStockAnywhere = false;

  BoardGame({
    required this.id,
    required this.name,
    this.lowestPrice = 0,
    this.lowestPriceStore = '',
    required this.storeInfo,
  }) {
    for (StoreInfo info in storeInfo.values) {
      if (info.inStock) {
        inStockAnywhere = true;
        return;
      }
    }
  }
}
