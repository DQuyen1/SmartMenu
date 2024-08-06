class Display {
  final int displayId;
  final int? storeDeviceId;
  final int? menuId;
  final int? collectionId;
  final int? templateId;
  final double? activeHour;
  final String? displayImgPath;
  final List<DisplayItem> displayItems;

  Display({
    required this.displayId,
    required this.storeDeviceId,
    required this.menuId,
    this.collectionId,
    required this.templateId,
    required this.activeHour,
    required this.displayImgPath,
    required this.displayItems,
  });

  factory Display.fromJson(Map<String, dynamic> json) {
    return Display(
      displayId: json['displayId'],
      storeDeviceId: json['storeDeviceId'],
      menuId: json['menuId'],
      collectionId: json['collectionId'],
      templateId: json['templateId'],
      activeHour: toDouble(json['activeHour']),
      displayImgPath: json['displayImgPath'],
      displayItems: (json['displayItems'] as List)
          .map((item) => DisplayItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayId': displayId,
      'storeDeviceId': storeDeviceId,
      'menuId': menuId,
      'collectionId': collectionId,
      'templateId': templateId,
      'activeHour': activeHour,
      'displayImgPath': displayImgPath,
      'displayItems': displayItems.map((item) => item.toJson()).toList(),
    };
  }
}

class DisplayItem {
  final int? displayItemId;
  final int? displayId;
  final int? boxId;
  final int? productGroupId;
  final Box box;
  final ProductGroup productGroup;

  DisplayItem({
    required this.displayItemId,
    required this.displayId,
    required this.boxId,
    required this.productGroupId,
    required this.box,
    required this.productGroup,
  });

  factory DisplayItem.fromJson(Map<String, dynamic> json) {
    return DisplayItem(
      displayItemId: json['displayItemId'],
      displayId: json['displayId'],
      boxId: json['boxId'],
      productGroupId: json['productGroupId'],
      box: Box.fromJson(json['box']),
      productGroup: ProductGroup.fromJson(json['productGroup']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayItemId': displayItemId,
      'displayId': displayId,
      'boxId': boxId,
      'productGroupId': productGroupId,
      'box': box.toJson(),
      'productGroup': productGroup.toJson(),
    };
  }
}

class Box {
  final int? boxId;
  final int? layerId;
  final double? boxPositionX;
  final double? boxPositionY;
  final double? boxWidth;
  final double? boxHeight;
  final int? boxType;
  final int? maxProductItem;
  final List<BoxItem> boxItems;
  final bool isDeleted;

  Box({
    required this.boxId,
    required this.layerId,
    required this.boxPositionX,
    required this.boxPositionY,
    required this.boxWidth,
    required this.boxHeight,
    required this.boxType,
    required this.maxProductItem,
    required this.boxItems,
    required this.isDeleted,
  });

  factory Box.fromJson(Map<String, dynamic> json) {
    return Box(
      boxId: json['boxId'],
      layerId: json['layerId'],
      boxPositionX: toDouble(json['boxPositionX']),
      boxPositionY: toDouble(json['boxPositionY']),
      boxWidth: toDouble(json['boxWidth']),
      boxHeight: toDouble(json['boxHeight']),
      boxType: json['boxType'],
      maxProductItem: json['maxProductItem'],
      boxItems: (json['boxItems'] as List)
          .map((item) => BoxItem.fromJson(item))
          .toList(),
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boxId': boxId,
      'layerId': layerId,
      'boxPositionX': boxPositionX,
      'boxPositionY': boxPositionY,
      'boxWidth': boxWidth,
      'boxHeight': boxHeight,
      'boxType': boxType,
      'maxProductItem': maxProductItem,
      'boxItems': boxItems.map((item) => item.toJson()).toList(),
      'isDeleted': isDeleted,
    };
  }
}

class BoxItem {
  final int? boxItemId;
  final int? boxId;
  final int? bFontId;
  final double? boxItemX;
  final double? boxItemY;
  final double? boxItemWidth;
  final double? boxItemHeight;
  final int? boxItemType;
  final int? order;
  final String? style;
  final bool isDeleted;

  BoxItem({
    required this.boxItemId,
    required this.boxId,
    required this.bFontId,
    required this.boxItemX,
    required this.boxItemY,
    required this.boxItemWidth,
    required this.boxItemHeight,
    required this.boxItemType,
    required this.order,
    required this.style,
    required this.isDeleted,
  });

  factory BoxItem.fromJson(Map<String, dynamic> json) {
    return BoxItem(
      boxItemId: json['boxItemId'],
      boxId: json['boxId'],
      bFontId: json['bFontId'],
      boxItemX: toDouble(json['boxItemX']),
      boxItemY: toDouble(json['boxItemY']),
      boxItemWidth: toDouble(json['boxItemWidth']),
      boxItemHeight: toDouble(json['boxItemHeight']),
      boxItemType: json['boxItemType'],
      order: json['order'],
      style: json['style'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'boxItemId': boxItemId,
      'boxId': boxId,
      'bFontId': bFontId,
      'boxItemX': boxItemX,
      'boxItemY': boxItemY,
      'boxItemWidth': boxItemWidth,
      'boxItemHeight': boxItemHeight,
      'boxItemType': boxItemType,
      'order': order,
      'style': style,
      'isDeleted': isDeleted,
    };
  }
}

class ProductGroup {
  final int? productGroupId;
  final int? menuId;
  final int? collectionId;
  final String? productGroupName;
  final bool haveNormalPrice;
  final List<ProductGroupItem> productGroupItems;

  ProductGroup({
    required this.productGroupId,
    required this.menuId,
    this.collectionId,
    required this.productGroupName,
    required this.haveNormalPrice,
    required this.productGroupItems,
  });

  factory ProductGroup.fromJson(Map<String, dynamic> json) {
    return ProductGroup(
      productGroupId: json['productGroupId'],
      menuId: json['menuId'],
      collectionId: json['collectionId'],
      productGroupName: json['productGroupName'],
      haveNormalPrice: json['haveNormalPrice'],
      productGroupItems: (json['productGroupItems'] as List)
          .map((item) => ProductGroupItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productGroupId': productGroupId,
      'menuId': menuId,
      'collectionId': collectionId,
      'productGroupName': productGroupName,
      'haveNormalPrice': haveNormalPrice,
      'productGroupItems':
          productGroupItems.map((item) => item.toJson()).toList(),
    };
  }
}

class ProductGroupItem {
  final int? productGroupItemId;
  final int? productGroupId;
  final int? productId;
  final Product product;

  ProductGroupItem({
    required this.productGroupItemId,
    required this.productGroupId,
    required this.productId,
    required this.product,
  });

  factory ProductGroupItem.fromJson(Map<String, dynamic> json) {
    return ProductGroupItem(
      productGroupItemId: json['productGroupItemId'],
      productGroupId: json['productGroupId'],
      productId: json['productId'],
      product: Product.fromJson(json['product']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productGroupItemId': productGroupItemId,
      'productGroupId': productGroupId,
      'productId': productId,
      'product': product.toJson(),
    };
  }
}

class Product {
  final int? productId;
  final int? categoryId;
  final String productName;
  final String productDescription;
  final int? productPriceCurrency;
  final String? productImgPath;
  final String? productLogoPath;
  final List<ProductSizePrice> productSizePrices;
  final bool isDeleted;

  Product({
    required this.productId,
    required this.categoryId,
    required this.productName,
    required this.productDescription,
    required this.productPriceCurrency,
    required this.productImgPath,
    required this.productLogoPath,
    required this.productSizePrices,
    required this.isDeleted,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: json['productId'],
      categoryId: json['categoryId'],
      productName: json['productName'],
      productDescription: json['productDescription'],
      productPriceCurrency: json['productPriceCurrency'],
      productImgPath: json['productImgPath'],
      productLogoPath: json['productLogoPath'],
      productSizePrices: (json['productSizePrices'] as List)
          .map((item) => ProductSizePrice.fromJson(item))
          .toList(),
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
      'productLogoPath': productLogoPath,
      'productSizePrices':
          productSizePrices.map((item) => item.toJson()).toList(),
      'isDeleted': isDeleted,
    };
  }
}

class ProductSizePrice {
  final int? productSizeId;
  final int? productId;
  final int? sizeType;
  final double? sizePrice;

  ProductSizePrice({
    required this.productSizeId,
    required this.productId,
    required this.sizeType,
    required this.sizePrice,
  });

  factory ProductSizePrice.fromJson(Map<String, dynamic> json) {
    return ProductSizePrice(
      productSizeId: json['productSizeId'],
      productId: json['productId'],
      sizeType: json['sizeType'],
      sizePrice: json['sizePrice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productSizeId': productSizeId,
      'productId': productId,
      'sizeType': sizeType,
      'sizePrice': sizePrice,
    };
  }
}

double? toDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? toInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class Collection {
  final int collectionId;
  final int brandId;
  final String collectionName;
  final String collectionDescription;
  final String? collectionBackgroundImgPath;
  final bool isDeleted;

  Collection({
    required this.collectionId,
    required this.brandId,
    required this.collectionName,
    required this.collectionDescription,
    required this.collectionBackgroundImgPath,
    required this.isDeleted,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      collectionId: json['collectionId'],
      brandId: json['brandId'],
      collectionName: json['collectionName'],
      collectionDescription: json['collectionDescription'],
      collectionBackgroundImgPath: json['collectionBackgroundImgPath'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collectionId': collectionId,
      'brandId': brandId,
      'collectionName': collectionName,
      'collectionDescription': collectionDescription,
      'collectionBackgroundImgPath': collectionBackgroundImgPath,
      'isDeleted': isDeleted,
    };
  }
}

class Menu {
  final int menuId;
  final int brandId;
  final String menuName;
  final String menuDescription;
  final dynamic productGroups;
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

class StoreDevice {
  final int storeDeviceId;
  final int storeId;
  final String storeDeviceName;
  final int deviceWidth;
  final int deviceHeight;
  final dynamic displays;
  final bool isDeleted;

  StoreDevice({
    required this.storeDeviceId,
    required this.storeId,
    required this.storeDeviceName,
    required this.deviceWidth,
    required this.deviceHeight,
    this.displays,
    required this.isDeleted,
  });

  factory StoreDevice.fromJson(Map<String, dynamic> json) {
    return StoreDevice(
      storeDeviceId: json['storeDeviceId'],
      storeId: json['storeId'],
      storeDeviceName: json['storeDeviceName'],
      deviceWidth: json['deviceWidth'],
      deviceHeight: json['deviceHeight'],
      displays: json['displays'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeDeviceId': storeDeviceId,
      'storeId': storeId,
      'storeDeviceName': storeDeviceName,
      'deviceWidth': deviceWidth,
      'deviceHeight': deviceHeight,
      'displays': displays,
      'isDeleted': isDeleted,
    };
  }
}

class Template {
  final int templateId;
  final int brandId;
  final String templateName;
  final String templateDescription;
  final int templateWidth;
  final int templateHeight;
  final String templateImgPath;
  final List<dynamic>? layers;
  final bool isDeleted;

  Template({
    required this.templateId,
    required this.brandId,
    required this.templateName,
    required this.templateDescription,
    required this.templateWidth,
    required this.templateHeight,
    required this.templateImgPath,
    required this.layers,
    required this.isDeleted,
  });

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
      templateId: json['templateId'],
      brandId: json['brandId'],
      templateName: json['templateName'],
      templateDescription: json['templateDescription'],
      templateWidth: json['templateWidth'],
      templateHeight: json['templateHeight'],
      templateImgPath: json['templateImgPath'],
      layers: json['layers'],
      isDeleted: json['isDeleted'],
    );
  }
}
