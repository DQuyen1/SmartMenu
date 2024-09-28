class Product {
  final int productId;
  final int categoryId;
  final String productName;
  final String productDescription;
  final int productPriceCurrency;
  final String productImgPath;
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
    List<ProductSizePrice> sizePricesList =
        list.map((i) => ProductSizePrice.fromJson(i)).toList();

    return Product(
      productId: json['productId'],
      categoryId: json['categoryId'],
      productName: json['productName'],
      productDescription: json['productDescription'],
      productPriceCurrency: json['productPriceCurrency'],
      productImgPath: json['productImgPath'],
      productSizePrices: sizePricesList,
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'categoryId': categoryId,
      'productName': productName,
      'productDescription': productDescription,
      'productPriceCurrency': productPriceCurrency,
      'productImgPath': productImgPath,
      'productSizePrices': productSizePrices.map((i) => i.toJson()).toList(),
      'isDeleted': isDeleted,
    };
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
      price: json['price'].toDouble(),
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productSizePriceId': productSizePriceId,
      'productId': productId,
      'productSizeType': productSizeType,
      'price': price,
      'isDeleted': isDeleted,
    };
  }
}
