import 'package:smart_menu/models/display.dart';

class DeviceSubscription {
  final int deviceSubscriptionId;
  final int storeDeviceId;
  final int subscriptionId;
  final String subscriptionStartDate;
  final String subscriptionEndDate;
  final int subscriptionStatus;
  final StoreDevice storeDevice;
  final List<Transaction> transactions;
  final bool isDeleted;

  DeviceSubscription({
    required this.deviceSubscriptionId,
    required this.storeDeviceId,
    required this.subscriptionId,
    required this.subscriptionStartDate,
    required this.subscriptionEndDate,
    required this.subscriptionStatus,
    required this.storeDevice,
    required this.transactions,
    required this.isDeleted,
  });

  factory DeviceSubscription.fromJson(Map<String, dynamic> json) {
    return DeviceSubscription(
      deviceSubscriptionId: json['deviceSubscriptionId'],
      storeDeviceId: json['storeDeviceId'],
      subscriptionId: json['subscriptionId'],
      subscriptionStartDate: json['subscriptionStartDate'],
      subscriptionEndDate: json['subscriptionEndDate'],
      subscriptionStatus: json['subscriptionStatus'],
      storeDevice: StoreDevice.fromJson(json['storeDevice']),
      transactions: (json['transactions'] as List)
          .map((transaction) => Transaction.fromJson(transaction))
          .toList(),
      isDeleted: json['isDeleted'],
    );
  }
}

class Transaction {
  final int transactionId;
  final int deviceSubscriptionId;
  final double amount;
  final int payType;
  final String payDate;
  final bool isDeleted;

  Transaction({
    required this.transactionId,
    required this.deviceSubscriptionId,
    required this.amount,
    required this.payType,
    required this.payDate,
    required this.isDeleted,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'],
      deviceSubscriptionId: json['deviceSubscriptionId'],
      amount: json['amount'],
      payType: json['payType'],
      payDate: json['payDate'],
      isDeleted: json['isDeleted'],
    );
  }
}
