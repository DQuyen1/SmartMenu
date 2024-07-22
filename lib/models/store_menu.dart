import 'dart:convert';

class StoreMenu {
  final int storeMenuId;
  final int storeId;
  final int menuId;
  final Menu menu;
  final bool isDeleted;

  StoreMenu({
    required this.storeMenuId,
    required this.storeId,
    required this.menuId,
    required this.menu,
    required this.isDeleted,
  });

  factory StoreMenu.fromJson(Map<String, dynamic> json) {
    return StoreMenu(
      storeMenuId: json['storeMenuId'],
      storeId: json['storeId'],
      menuId: json['menuId'],
      menu: Menu.fromJson(json['menu']),
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeMenuId': storeMenuId,
      'storeId': storeId,
      'menuId': menuId,
      'menu': menu.toJson(),
      'isDeleted': isDeleted,
    };
  }
}

class Menu {
  final int menuId;
  final int brandId;
  final String menuName;
  final String menuDescription;
  final dynamic productGroups; // Use dynamic if the type is not specified
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
      productGroups: json['productGroups'], // Adjust type if necessary
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuId': menuId,
      'brandId': brandId,
      'menuName': menuName,
      'menuDescription': menuDescription,
      'productGroups': productGroups, // Adjust type if necessary
      'isDeleted': isDeleted,
    };
  }
}
