class Store {
  int storeId;
  int brandId;
  String storeCode;
  String storeName;
  String storeLocation;
  String storeContactEmail;
  String storeContactNumber;
  bool storeStatus;
  bool isDeleted;

  Store({
    required this.storeId,
    required this.brandId,
    required this.storeCode,
    required this.storeName,
    required this.storeLocation,
    required this.storeContactEmail,
    required this.storeContactNumber,
    required this.storeStatus,
    required this.isDeleted,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      storeId: json['storeId'],
      brandId: json['brandId'],
      storeCode: json['storeCode'],
      storeName: json['storeName'],
      storeLocation: json['storeLocation'],
      storeContactEmail: json['storeContactEmail'],
      storeContactNumber: json['storeContactNumber'],
      storeStatus: json['storeStatus'],
      isDeleted: json['isDeleted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeId': storeId,
      'brandId': brandId,
      'storeCode': storeCode,
      'storeName': storeName,
      'storeLocation': storeLocation,
      'storeContactEmail': storeContactEmail,
      'storeContactNumber': storeContactNumber,
      'storeStatus': storeStatus,
      'isDeleted': isDeleted,
    };
  }
}
