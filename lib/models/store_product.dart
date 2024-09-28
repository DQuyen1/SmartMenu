class StoreProduct {
  int storeProductId;
  int storeId;
  int productId;
  bool isAvailable;
  Product? product;
  bool isDeleted;

  StoreProduct({
    required this.storeProductId,
    required this.storeId,
    required this.productId,
    required this.isAvailable,
    this.product,
    required this.isDeleted,
  });

  factory StoreProduct.fromJson(Map<String, dynamic> json) {
    return StoreProduct(
      storeProductId: json['storeProductId'],
      storeId: json['storeId'],
      productId: json['productId'],
      isAvailable: json['isAvailable'],
      product:
          json['product'] != null ? Product.fromJson(json['product']) : null,
      isDeleted: json['isDeleted'],
    );
  }
  void toggleAvailability() {
    isAvailable = !isAvailable;
  }

  get categoryId => null;
}

class Product {
  final int productId;
  final int categoryId;
  final String productName;
  final String productDescription;
  final int productPriceCurrency;
  final String? productImgPath;
  final List<ProductSizePrice> productSizePrices;
  final bool isDeleted;

  Product({
    required this.productId,
    required this.categoryId,
    required this.productName,
    required this.productDescription,
    required this.productPriceCurrency,
    required this.productImgPath,
    required this.productSizePrices,
    required this.isDeleted,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    var list = json['productSizePrices'] as List;
    List<ProductSizePrice> productSizePricesList =
        list.map((i) => ProductSizePrice.fromJson(i)).toList();

    return Product(
      productId: json['productId'],
      categoryId: json['categoryId'],
      productName: json['productName'],
      productDescription: json['productDescription'],
      productPriceCurrency: json['productPriceCurrency'],
      productImgPath: json['productImgPath'],
      productSizePrices: productSizePricesList,
      isDeleted: json['isDeleted'],
    );
  }
}

class ProductSizePrice {
  final int productSizePriceId;
  final int productId;
  final int productSizeType;
  final double price;
  final bool isDeleted;

  ProductSizePrice({
    required this.productSizePriceId,
    required this.productId,
    required this.productSizeType,
    required this.price,
    required this.isDeleted,
  });

  factory ProductSizePrice.fromJson(Map<String, dynamic> json) {
    return ProductSizePrice(
      productSizePriceId: json['productSizePriceId'],
      productId: json['productId'],
      productSizeType: json['productSizeType'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'],
      isDeleted: json['isDeleted'],
    );
  }
}
