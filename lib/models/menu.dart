class Menu {
  final int menuId;
  final int brandId;
  final String menuName;
  final String menuDescription;
  final List<dynamic>? productGroups;
  final bool isDeleted;

  Menu({
    required this.menuId,
    required this.brandId,
    required this.menuName,
    required this.menuDescription,
    this.productGroups,
    required this.isDeleted,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      menuId: json['menuId'],
      brandId: json['brandId'],
      menuName: json['menuName'],
      menuDescription: json['menuDescription'],
      productGroups: json['productGroups'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuId': menuId,
      'brandId': brandId,
      'menuName': menuName,
      'menuDescription': menuDescription,
      'productGroups': productGroups,
      'isDeleted': isDeleted,
    };
  }
}
