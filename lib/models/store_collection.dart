class StoreCollection {
  final int storeCollectionId;
  final int storeId;
  final int collectionId;
  final bool isDeleted;

  StoreCollection({
    required this.storeCollectionId,
    required this.storeId,
    required this.collectionId,
    required this.isDeleted,
  });

  factory StoreCollection.fromJson(Map<String, dynamic> json) {
    return StoreCollection(
      storeCollectionId: json['storeCollectionId'],
      storeId: json['storeId'],
      collectionId: json['collectionId'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeCollectionId': storeCollectionId,
      'storeId': storeId,
      'collectionId': collectionId,
      'isDeleted': isDeleted,
    };
  }
}
