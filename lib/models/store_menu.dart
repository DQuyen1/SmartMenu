class StoreMenu {
  final int storeMenuId;
  final int storeId;
  final int menuId;
  final bool isDeleted;

  StoreMenu({
    required this.storeMenuId,
    required this.storeId,
    required this.menuId,
    required this.isDeleted,
  });

  factory StoreMenu.fromJson(Map<String, dynamic> json) {
    return StoreMenu(
      storeMenuId: json['storeMenuId'],
      storeId: json['storeId'],
      menuId: json['menuId'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeMenuId': storeMenuId,
      'storeId': storeId,
      'menuId': menuId,
      'isDeleted': isDeleted,
    };
  }
}
