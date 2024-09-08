class ProductGroup {
  final int productGroupId;
  final String productGroupName;

  ProductGroup({required this.productGroupId, required this.productGroupName});

  factory ProductGroup.fromJson(Map<String, dynamic> json) {
    return ProductGroup(
      productGroupId: json['productGroupId'],
      productGroupName: json['productGroupName'],
    );
  }
}
