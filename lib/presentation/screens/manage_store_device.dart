import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_device.dart';
import 'package:smart_menu/models/subscription.dart';
import 'package:smart_menu/presentation/screens/display_device.dart';
import 'package:smart_menu/presentation/screens/shared/payment_webview.dart';
import 'package:smart_menu/presentation/screens/transaction_bill.dart';
import 'package:smart_menu/repository/store_device_repository.dart';
import 'package:smart_menu/repository/subscription_repository.dart';
import 'package:smart_menu/presentation/screens/partner/store_device_form.dart';
import 'package:vnpay_flutter/vnpay_flutter.dart';

class StoreDeviceListScreen extends StatefulWidget {
  final int storeId;

  const StoreDeviceListScreen({super.key, required this.storeId});

  @override
  State<StoreDeviceListScreen> createState() => _StoreDeviceListScreenState();
}

class _StoreDeviceListScreenState extends State<StoreDeviceListScreen>
    with SingleTickerProviderStateMixin {
  final StoreDeviceRepository _storeDeviceRepository = StoreDeviceRepository();
  final SubscriptionRepository _subscriptionRepository =
      SubscriptionRepository();
  late Future<List<StoreDevice>> _futureStoreDevices;
  late TabController _tabController;

  void _fetchStoreDevices() {
    setState(() {
      _futureStoreDevices = _storeDeviceRepository.getAll(widget.storeId);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreDevices();
    _tabController = TabController(length: 2, vsync: this);
    HttpOverrides.global = _DevHttpOverrides();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _approveDevice(int storeDeviceId) async {
    final success = await _storeDeviceRepository.acceptDevice(storeDeviceId);
    if (success) {
      _fetchStoreDevices();
      _showSnackBar('Device approved successfully', Colors.green);
    } else {
      _showSnackBar('Failed to approve device', Colors.red);
    }
  }

  void _navigateToStoreDeviceForm({StoreDevice? storeDevice}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreDeviceFormScreen(
          storeDevice: storeDevice,
          storeId: widget.storeId,
        ),
      ),
    );

    if (result == true) {
      _fetchStoreDevices();
    }
  }

  void _deleteStoreDevice(int storeDeviceId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Delete Store Device',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content:
            const Text('Are you sure you want to delete this store device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await _storeDeviceRepository.deleteStoreDevice(storeDeviceId);
      _fetchStoreDevices();
      _showSnackBar(
          success ? 'Failed to delete' : 'Device deleted successfully',
          success ? Colors.red : Colors.green);
    }
  }

  void _subscribeToDevice(int storeDeviceId) async {
    final subscriptions = await _subscriptionRepository.getAll();

    if (subscriptions.isEmpty) {
      _showSnackBar('No subscription plans available', Colors.red);
      return;
    }

    Subscription? selectedSubscription;
    final result = await showDialog<Subscription?>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Choose a Subscription Plan'),
          content: DropdownButtonFormField<Subscription>(
            decoration: const InputDecoration(labelText: 'Subscription Plan'),
            items: subscriptions.map((Subscription subscription) {
              return DropdownMenuItem<Subscription>(
                value: subscription,
                child: Text(subscription.name),
              );
            }).toList(),
            onChanged: (Subscription? value) {
              selectedSubscription = value;
            },
            isExpanded: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedSubscription);
              },
              child: const Text('Subscribe'),
            ),
          ],
        );
      },
    );

    if (result == null || selectedSubscription == null) {
      _showSnackBar('Subscription cancelled or not selected', Colors.red);
      return;
    }
    final paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      url: 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
      version: '2.0.1',
      tmnCode: '5SMB5Q9G',
      txnRef: DateTime.now().millisecondsSinceEpoch.toString(),
      orderInfo: selectedSubscription!.description,
      amount: selectedSubscription!.price,
      returnUrl: 'vnpay-return://callback',
      ipAdress: '58.187.188.166',
      vnpayHashKey: 'ZKWCA7U2LJHLVPRPXDH0I3AG172ADADW',
      vnPayHashType: VNPayHashType.HMACSHA512,
      vnpayExpireDate: DateTime.now().add(const Duration(days: 500)),
    );

    final paymentResult = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PaymentWebView(paymentUrl: paymentUrl),
      ),
    );

    if (paymentResult != null && paymentResult['success'] == true) {
      String? bankCode = paymentResult['vnp_BankCode'];
      int payType;
      if (bankCode == 'VISA' || bankCode == 'MASTERCARD') {
        payType = 1;
      } else {
        payType = 0;
      }
      final deviceSubscriptionId =
          await _storeDeviceRepository.saveSubscription(
        storeDeviceId: storeDeviceId,
        subscriptionId: selectedSubscription!.subscriptionId,
      );

      if (deviceSubscriptionId != null) {
        final transactionSuccess = await _storeDeviceRepository.saveTransaction(
          deviceSubscriptionId: deviceSubscriptionId,
          amount: selectedSubscription!.price,
          payType: payType,
        );

        if (transactionSuccess) {
          _showSnackBar('Subscription and transaction recorded successfully',
              Colors.green);
          _showBillSummary(
              selectedSubscription!.price, selectedSubscription!.description);
        } else {
          _showSnackBar('Failed to record transaction', Colors.orange);
        }
      } else {
        _showSnackBar('Subscription failed', Colors.red);
      }
    }
  }

  void _showBillSummary(double amount, String description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionBillScreen(
          amount: amount,
          description: description,
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Devices'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Approved Devices'),
            Tab(text: 'Pending Devices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDeviceList(true),
          _buildDeviceList(false),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToStoreDeviceForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDeviceList(bool isApproved) {
    return FutureBuilder<List<StoreDevice>>(
      future: _futureStoreDevices,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No devices found'));
        } else {
          final storeDevices = snapshot.data!
              .where((device) => device.isApproved == isApproved)
              .toList();
          return ListView.builder(
            itemCount: storeDevices.length,
            itemBuilder: (context, index) {
              final storeDevice = storeDevices[index];
              return Card(
                child: ListTile(
                  title: Text(storeDevice.storeDeviceName),
                  subtitle: Text(
                      'Width: ${storeDevice.deviceWidth}, Height: ${storeDevice.deviceHeight}'),
                  trailing: isApproved
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _navigateToStoreDeviceForm(
                                  storeDevice: storeDevice),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteStoreDevice(storeDevice.storeDeviceId),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  _subscribeToDevice(storeDevice.storeDeviceId),
                              child: const Text('Subscribe'),
                            ),
                          ],
                        )
                      : ElevatedButton(
                          onPressed: () =>
                              _approveDevice(storeDevice.storeDeviceId),
                          child: const Text('Accept this device'),
                        ),
                ),
              );
            },
          );
        }
      },
    );
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
