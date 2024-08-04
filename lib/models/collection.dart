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
    this.collectionBackgroundImgPath,
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
