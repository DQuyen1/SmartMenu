import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_device.dart';
import 'package:smart_menu/models/subscription.dart';
import 'package:smart_menu/presentation/screens/device_detail.dart';
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
  String _searchQuery = '';
  String _sortOption = 'newest';

  void _fetchStoreDevices() {
    setState(() {
      _futureStoreDevices =
          _storeDeviceRepository.getAll(widget.storeId).then((storeDevices) {
        switch (_sortOption) {
          case 'newest':
            storeDevices
                .sort((a, b) => b.storeDeviceId.compareTo(a.storeDeviceId));
            break;
          case 'oldest':
            storeDevices
                .sort((a, b) => a.storeDeviceId.compareTo(b.storeDeviceId));
            break;
          case 'name_asc':
            storeDevices.sort((a, b) => (a.storeDeviceName.toLowerCase() ?? '')
                .compareTo(b.storeDeviceName.toLowerCase() ?? ''));
            break;
          case 'name_desc':
            storeDevices.sort((a, b) => (b.storeDeviceName.toLowerCase() ?? '')
                .compareTo(a.storeDeviceName.toLowerCase() ?? ''));
            break;
          // case 'vertical':
          //   storeDevices = storeDevices
          //       .where((storeDevice) => storeDevice.ratioType == 1)
          //       .toList();
          // case 'horizontal':
          //   storeDevices = storeDevices
          //       .where((storeDevice) => storeDevice.ratioType == 0)
          //       .toList();
          default:
            storeDevices
                .sort((a, b) => b.storeDeviceId.compareTo(a.storeDeviceId));
        }
        if (_searchQuery.isNotEmpty) {
          storeDevices = storeDevices
              .where((storeDevice) =>
                  storeDevice.storeDeviceName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false)
              .toList();
        }
        return storeDevices;
      });
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

  // void _changeRatioType(int storeDeviceId) async {
  //   final success = await _storeDeviceRepository.changeRatioType(storeDeviceId);
  //   if (success) {
  //     _fetchStoreDevices();
  //     _showSnackBar('Ratio type changed successfully', Colors.green);
  //   } else {
  //     _showSnackBar('Failed to change ratio type', Colors.red);
  //   }
  // }

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
          _showBillSummary(selectedSubscription!.price,
              selectedSubscription!.description, storeDeviceId);
        } else {
          _showSnackBar('Failed to record transaction', Colors.orange);
        }
      } else {
        _showSnackBar('Subscription failed', Colors.red);
      }
    }
  }

  void _showBillSummary(double amount, String description, int storeDeviceId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionBillScreen(
            amount: amount,
            description: description,
            storeDeviceId: storeDeviceId),
      ),
    );
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              backgroundColor == Colors.green
                  ? Icons.check_circle
                  : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  Future<void> _updateDeviceLocation(StoreDevice storeDevice) async {
    final TextEditingController locationController = TextEditingController();
    locationController.text = storeDevice.deviceLocation ?? '';
    final newLocation = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Device Location'),
          content: TextField(
            controller: locationController,
            decoration: InputDecoration(hintText: "Enter new location"),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () =>
                  Navigator.of(context).pop(locationController.text),
            ),
          ],
        );
      },
    );

    if (newLocation != null && newLocation.isNotEmpty) {
      final success =
          await _storeDeviceRepository.updateLocation(storeDevice, newLocation);
      if (success) {
        _showSnackBar('Location updated successfully', Colors.green);
        _fetchStoreDevices();
      } else {
        _showSnackBar('Failed to update location', Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Devices'),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.black,
            labelColor: Colors.green,
            tabs: const [
              Tab(text: 'Approved Devices'),
              Tab(text: 'Pending Devices'),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildSearchUI(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDeviceList(true),
                  _buildDeviceList(false),
                ],
              ),
            )
          ],
        )
        // floatingActionButton: FloatingActionButton(
        //   onPressed: () => _navigateToStoreDeviceForm(),
        //   child: const Icon(Icons.add),
        // ),
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
              // final ratioTypeLabel =
              //     storeDevice.ratioType == 0 ? 'Horizontal' : 'Vertical';
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StoreDeviceDetail(
                            storeDeviceId: storeDevice.storeDeviceId),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                storeDevice.storeDeviceName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            if (isApproved)
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (String result) {
                                  switch (result) {
                                    case 'subscribe':
                                      _subscribeToDevice(
                                          storeDevice.storeDeviceId);
                                      break;
                                    case 'location':
                                      _updateDeviceLocation(storeDevice);
                                      break;
                                    case 'ratio':
                                      // _changeRatioType(
                                      //     storeDevice.storeDeviceId);
                                      break;
                                    case 'delete':
                                      _deleteStoreDevice(
                                          storeDevice.storeDeviceId);
                                      break;
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: 'subscribe',
                                    child: Text('Subscribe'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'location',
                                    child: Text('Update Location'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'ratio',
                                    child: Text('Change Ratio Type'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.check,
                                        color: Colors.green),
                                    onPressed: () => _approveDevice(
                                        storeDevice.storeDeviceId),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.red),
                                    onPressed: () => _deleteStoreDevice(
                                        storeDevice.storeDeviceId),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Width: ${storeDevice.deviceWidth}, Height: ${storeDevice.deviceHeight}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        // Text(
                        //   'Type: $ratioTypeLabel',
                        //   style: const TextStyle(fontSize: 14),
                        // ),
                        Text(
                          'Location: ${storeDevice.deviceLocation ?? "Not set"}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildSearchUI() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(right: 16),
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search devices...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _fetchStoreDevices();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _sortOption,
                  onChanged: (newValue) {
                    setState(() {
                      _sortOption = newValue!;
                      _fetchStoreDevices();
                    });
                  },
                  items: <String>[
                    'newest',
                    'oldest',
                    'name_asc',
                    'name_desc',
                    // 'vertical',
                    // 'horizontal'
                  ].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_getSortOptionLabel(value)),
                    );
                  }).toList(),
                  hint: const Text('Sort by'),
                  isExpanded: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Filter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSortOptionLabel(String sortOption) {
    switch (sortOption) {
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      case 'name_asc':
        return 'Name: A-Z';
      case 'name_desc':
        return 'Name: Z-A';
      case 'vertical':
        return 'Vertical devices';
      case 'horizontal':
        return 'Horizontal devices';
      default:
        return 'Sort by';
    }
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
