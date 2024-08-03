class Category {
  final int categoryId;
  final int brandId;
  final String categoryName;
  final List<dynamic>? products;
  final bool isDeleted;

  Category({
    required this.categoryId,
    required this.brandId,
    required this.categoryName,
    this.products,
    required this.isDeleted,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['categoryId'],
      brandId: json['brandId'],
      categoryName: json['categoryName'],
      products: json['products'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'brandId': brandId,
      'categoryName': categoryName,
      'products': products,
      'isDeleted': isDeleted,
    };
  }
}
