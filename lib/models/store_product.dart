class StoreProduct {
  int storeProductId;
  int storeId;
  int productId;
  bool isAvailable;

  StoreProduct({
    required this.storeProductId,
    required this.storeId,
    required this.productId,
    required this.isAvailable,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      storeProductId: json['storeProductId'],
      storeId: json['storeId'],
      productId: json['productId'],
      isAvailable: json['isAvailable'],
    );
  }

  get categoryId => null;

  void toggleAvailability() {
    isAvailable = !isAvailable;
  }
}
