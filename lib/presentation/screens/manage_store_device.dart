import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_device.dart';
import 'package:smart_menu/presentation/screens/display_device.dart';
import 'package:smart_menu/presentation/screens/partner/display_device_form.dart';
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
        title: const Text('Delete Store Device'),
        content:
            const Text('Are you sure you want to delete this store device?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await _storeDeviceRepository.deleteStoreDevice(storeDeviceId);
      _fetchStoreDevices();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete store device')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store device deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Devices'),
      ),
      body: FutureBuilder<List<StoreDevice>>(
        future: _futureStoreDevices,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('No store devices found'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No store devices found'));
          } else {
            final storeDevices = snapshot.data!;
            return ListView.builder(
              itemCount: storeDevices.length,
              itemBuilder: (context, index) {
                final storeDevice = storeDevices[index];
                return ListTile(
                  title: Text(storeDevice.storeDeviceName),
                  subtitle: Text(
                      'Width: ${storeDevice.deviceWidth}, Height: ${storeDevice.deviceHeight}'),
                  trailing: Row(
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
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DisplayDevice(
                                  deviceId: storeDevice.storeDeviceId),
                            ),
                          );
                        },
                        child: const Text('Display'),
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
        child: const Icon(Icons.add),
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
