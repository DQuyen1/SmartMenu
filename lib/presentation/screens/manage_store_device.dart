import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_device.dart';
import 'package:smart_menu/presentation/screens/display_device.dart';
import 'package:smart_menu/repository/store_device_repository.dart';
import 'package:smart_menu/presentation/screens/partner/store_device_form.dart';

class StoreDeviceListScreen extends StatefulWidget {
  final int storeId;

  const StoreDeviceListScreen({super.key, required this.storeId});

  @override
  State<StoreDeviceListScreen> createState() => _StoreDeviceListScreenState();
}

class _StoreDeviceListScreenState extends State<StoreDeviceListScreen> {
  final StoreDeviceRepository _storeDeviceRepository = StoreDeviceRepository();
  late Future<List<StoreDevice>> _futureStoreDevices;

  void _fetchStoreDevices() {
    setState(() {
      _futureStoreDevices = _storeDeviceRepository.getAll(widget.storeId);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreDevices();
    HttpOverrides.global = _DevHttpOverrides();
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
          success ? 'Failed to delete' : 'Store device deleted successfully',
          success ? Colors.red : Colors.green);
    }
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
          onPressed: () {
            // Dismiss the snackbar
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: const Text(
              'Store Devices',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.red.shade100,
          ),
        ),
      ),
      body: FutureBuilder<List<StoreDevice>>(
        future: _futureStoreDevices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No store devices found'));
          } else {
            final storeDevices = snapshot.data!;
            return ListView.builder(
              itemCount: storeDevices.length,
              itemBuilder: (context, index) {
                final storeDevice = storeDevices[index];
                return Card(
                  elevation: 4.0,
                  margin: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.devices,
                            size: 40, color: Colors.red),
                        title: Text(
                          storeDevice.storeDeviceName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                            'Width: ${storeDevice.deviceWidth}, Height: ${storeDevice.deviceHeight}'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToStoreDeviceForm(
                                storeDevice: storeDevice),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () =>
                                _deleteStoreDevice(storeDevice.storeDeviceId),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DisplayDevice(
                                      deviceId: storeDevice.storeDeviceId),
                                ),
                              );
                            },
                            child: const Text('Display',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToStoreDeviceForm(),
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
