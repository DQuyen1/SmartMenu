// Update the StoreProduct model to include the product field
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
  final String? productImgPath;
  final String? productLogoPath;
  final List<ProductSizePrice> productSizePrices;
  final bool isDeleted;

  Product({
    required this.productId,
    required this.categoryId,
    required this.productName,
    required this.productDescription,
    required this.productImgPath,
    required this.productLogoPath,
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
      productImgPath: json['productImgPath'],
      productLogoPath: json['productLogoPath'],
      productSizePrices: productSizePricesList,
      isDeleted: json['isDeleted'],
    );
  }
}

class ProductSizePrice {
  final int productSizePriceId;
  final int productId;
  final int productSizeType;
  final int price;
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
      price: json['price'],
      isDeleted: json['isDeleted'],
    );
  }
}
