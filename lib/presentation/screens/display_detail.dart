import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/display.dart';
import 'package:smart_menu/presentation/screens/partner/update_productGroup.dart';
import 'package:smart_menu/repository/display_repository.dart';

class DisplayDetailScreen extends StatefulWidget {
  final Display display;

  const DisplayDetailScreen({super.key, required this.display});

  @override
  _DisplayDetailScreenState createState() => _DisplayDetailScreenState();
}

class _DisplayDetailScreenState extends State<DisplayDetailScreen> {
  final DisplayRepository _repository = DisplayRepository();
  List<int> _productGroupIds = [];
  List<int> _displayItemIds = [];

  @override
  void initState() {
    super.initState();
    _getDisplayDetails();
    HttpOverrides.global = _DevHttpOverrides();
  }

  Future<String> _getMenuName(int? menuId) async {
    if (menuId == null) return '';

    try {
      final menuName = await _repository.getMenuName(menuId);
      return menuName;
    } catch (e) {
      return 'Error fetching menu';
    }
  }

  Future<String> _getCollectionName(int? collectionId) async {
    if (collectionId == null) return '';

    try {
      final collectionName = await _repository.getCollectionName(collectionId);
      return collectionName;
    } catch (e) {
      return 'Error fetching collection';
    }
  }

  Future<String> _getDeviceName(int? storeDeviceId) async {
    if (storeDeviceId == null) return 'No device';

    try {
      final deviceName = await _repository.getDeviceName(storeDeviceId);
      return deviceName;
    } catch (e) {
      return 'Error fetching device';
    }
  }

  Future<String> _getTemplateName(int? templateId) async {
    if (templateId == null) return '';

    try {
      final templateName = await _repository.getTemplateName(templateId);
      return templateName;
    } catch (e) {
      return 'Error fetching template';
    }
  }

  Future<void> _getDisplayDetails() async {
    final displayId = widget.display.displayId;

    try {
      final displayDetails = await _repository.getDisplayDetails(displayId);

      if (displayDetails.containsKey('displayItemIds') &&
          displayDetails.containsKey('productGroupIds')) {
        print('Display Item IDs: ${displayDetails['displayItemIds']}');
        print('Product Group IDs: ${displayDetails['productGroupIds']}');

        setState(() {
          _displayItemIds = List<int>.from(displayDetails['displayItemIds']);
          _productGroupIds = List<int>.from(displayDetails['productGroupIds']);
        });
      } else {
        throw Exception('Invalid data structure in display details');
      }
    } catch (e) {
      print('Error in _getDisplayDetails: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching display details: $e')),
      );
    }
  }

  void _navigateToSelectProductGroup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectProductGroupScreen(
          displayItemIds: _displayItemIds,
          productGroupIds: _productGroupIds,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDisplayImage(),
            _buildInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDisplayImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        image: widget.display.displayImgPath != null &&
                Uri.tryParse(widget.display.displayImgPath!)?.hasAbsolutePath ==
                    true
            ? DecorationImage(
                image: NetworkImage(widget.display.displayImgPath!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: widget.display.displayImgPath == null
          ? Icon(Icons.image, color: Colors.grey.shade400, size: 64)
          : null,
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoItem(
              'Device', _getDeviceName(widget.display.storeDeviceId)),
          if (widget.display.collectionId != null)
            _buildInfoItem(
                'Collection', _getCollectionName(widget.display.collectionId))
          else if (widget.display.menuId != null)
            _buildInfoItem('Menu', _getMenuName(widget.display.menuId)),
          _buildInfoItem(
              'Template', _getTemplateName(widget.display.templateId)),
          _buildInfoItem('Display Time',
              Future.value(widget.display.activeHour.toString())),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToSelectProductGroup,
            child: Text('Change Product On Display'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, Future<String> futureValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 4),
          FutureBuilder<String>(
            future: futureValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...', style: TextStyle(fontSize: 16));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}',
                    style: TextStyle(fontSize: 16, color: Colors.red));
              } else {
                return Text(
                  snapshot.data ?? 'Not available',
                  style: TextStyle(fontSize: 16),
                );
              }
            },
          ),
        ],
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
