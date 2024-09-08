import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smart_menu/models/device_subscription.dart';
import 'package:smart_menu/repository/store_device_repository.dart';

class StoreDeviceDetail extends StatefulWidget {
  final int storeDeviceId;

  StoreDeviceDetail({required this.storeDeviceId});

  @override
  _StoreDeviceDetailState createState() => _StoreDeviceDetailState();
}

class _StoreDeviceDetailState extends State<StoreDeviceDetail> {
  final StoreDeviceRepository _repository = StoreDeviceRepository();
  DeviceSubscription? deviceSubscription;
  bool isLoading = true;
  String deviceName = 'Loading...';
  bool hasSubscription = true;

  @override
  void initState() {
    super.initState();
    fetchDeviceDetails();
  }

  Future<void> fetchDeviceDetails() async {
    try {
      setState(() => isLoading = true);
      List<DeviceSubscription> subscriptions =
          await _repository.getDeviceSubscriptions(widget.storeDeviceId);
      if (subscriptions.isNotEmpty) {
        setState(() {
          deviceSubscription = subscriptions.first;
          isLoading = false;
          hasSubscription = true;
        });
      } else {
        setState(() {
          isLoading = false;
          hasSubscription = false;
        });
      }
      final name = await _repository.getDeviceName(widget.storeDeviceId);
      setState(() {
        deviceName = name;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        hasSubscription = false;
      });
    }
  }

  String formatDate(String dateString) {
    DateTime date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('HH:mm:ss - dd/MM/yyyy').format(dateTime);
  }

  String formatAmount(double amount) {
    return NumberFormat.currency(locale: 'vi', symbol: 'VND', decimalDigits: 0)
        .format(amount);
  }

  Widget buildContent() {
    if (!hasSubscription) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'No subscription for this device',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView(
      children: [
        Card(
          margin: EdgeInsets.symmetric(vertical: 8),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Subscription Details',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('Devicea: $deviceName', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text(
                    'From: ${formatDate(deviceSubscription!.subscriptionStartDate)}',
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Text(
                    'End: ${formatDate(deviceSubscription!.subscriptionEndDate)}',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        Text('Transaction History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        ...deviceSubscription!.transactions
            .map((transaction) => Card(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text('${formatDateTime(transaction.payDate)}',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text('Total: ${formatAmount(transaction.amount)}'),
                    trailing: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: transaction.payType == 0
                            ? Colors.green
                            : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        transaction.payType == 0 ? 'Bank' : 'VISA/MASTER CARD',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ))
            .toList(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Details'),
        elevation: 0,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: buildContent(),
            ),
    );
  }
}
