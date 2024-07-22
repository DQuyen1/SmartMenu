import 'dart:convert';

class StoreCollection {
  final int storeCollectionId;
  final int storeId;
  final int collectionId;
  final Collection collection;
  final bool isDeleted;

  StoreCollection({
    required this.storeCollectionId,
    required this.storeId,
    required this.collectionId,
    required this.collection,
    required this.isDeleted,
  });

  factory StoreCollection.fromJson(Map<String, dynamic> json) {
    return StoreCollection(
      storeCollectionId: json['storeCollectionId'],
      storeId: json['storeId'],
      collectionId: json['collectionId'],
      collection: Collection.fromJson(json['collection']),
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeCollectionId': storeCollectionId,
      'storeId': storeId,
      'collectionId': collectionId,
      'collection': collection.toJson(),
      'isDeleted': isDeleted,
    };
  }
}

class Collection {
  final int collectionId;
  final int brandId;
  final String collectionName;
  final String collectionDescription;
  final dynamic productGroups; // Use dynamic if the type is not specified
  final bool isDeleted;

  Collection({
    required this.collectionId,
    required this.brandId,
    required this.collectionName,
    required this.collectionDescription,
    this.productGroups,
    required this.isDeleted,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      collectionId: json['collectionId'],
      brandId: json['brandId'],
      collectionName: json['collectionName'],
      collectionDescription: json['collectionDescription'],
      productGroups: json['productGroups'], // Adjust type if necessary
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'collectionId': collectionId,
      'brandId': brandId,
      'collectionName': collectionName,
      'collectionDescription': collectionDescription,
      'productGroups': productGroups, // Adjust type if necessary
      'isDeleted': isDeleted,
    };
  }
}
