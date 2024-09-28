import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
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
    _setFullScreen();
    print('Display:  ${widget.display.displayId}');
  }

  void _setFullScreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  void _setOrientation(bool isHorizontal) {
    if (isHorizontal) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  Future<String> _getMenuName(int? menuId) async {
    if (menuId == null) return '';
    try {
      return await _repository.getMenuName(menuId);
    } catch (e) {
      return 'Error fetching menu';
    }
  }

  Future<String> _getCollectionName(int? collectionId) async {
    if (collectionId == null) return '';
    try {
      return await _repository.getCollectionName(collectionId);
    } catch (e) {
      return 'Error fetching collection';
    }
  }

  Future<String> _getDeviceName(int? storeDeviceId) async {
    if (storeDeviceId == null) return 'No device';
    try {
      return await _repository.getDeviceName(storeDeviceId);
    } catch (e) {
      return 'Error fetching device';
    }
  }

  Future<String> _getTemplateName(int? templateId) async {
    if (templateId == null) return '';
    try {
      return await _repository.getTemplateName(templateId);
    } catch (e) {
      return 'Error fetching template';
    }
  }

  String _formatDisplayTime(double? time) {
    if (time == null) return 'Not set';
    int hours = time.floor();
    int minutes = ((time - hours) * 60).round();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
  }

  Future<void> _getDisplayDetails() async {
    final displayId = widget.display.displayId;
    try {
      final displayDetails = await _repository.getDisplayDetails(displayId);
      if (displayDetails.containsKey('displayItemIds') &&
          displayDetails.containsKey('productGroupIds')) {
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

  Future<Size> _getImageDimensions(String imageUrl) async {
    final ImageProvider provider = NetworkImage(imageUrl);
    final ImageStream stream = provider.resolve(ImageConfiguration());
    final Completer<Size> completer = Completer();
    final listener = ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(Size(
        info.image.width.toDouble(),
        info.image.height.toDouble(),
      ));
    });
    stream.addListener(listener);
    final size = await completer.future;
    stream.removeListener(listener);
    return size;
  }

  void _showFullScreenImage(BuildContext context) {
    if (widget.display.displayImgPath == null) return;

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Scaffold(
        body: FutureBuilder<Size>(
          future: _getImageDimensions(widget.display.displayImgPath!),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              final size = snapshot.data!;
              final isHorizontal = size.width > size.height;

              _setOrientation(isHorizontal);

              return WillPopScope(
                onWillPop: () async {
                  _setOrientation(false); // Reset to portrait when exiting
                  return true;
                },
                child: Container(
                  color: Colors.black,
                  child: PhotoView(
                    imageProvider: NetworkImage(widget.display.displayImgPath!),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 2,
                    backgroundDecoration: BoxDecoration(color: Colors.black),
                    loadingBuilder: (context, event) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    customSize: MediaQuery.of(context).size,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    ));
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
    return GestureDetector(
      onTap: () => _showFullScreenImage(context),
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          image: widget.display.displayImgPath != null &&
                  Uri.tryParse(widget.display.displayImgPath!)
                          ?.hasAbsolutePath ==
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
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF0F0F7),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoItem(
              'Device', _getDeviceName(widget.display.storeDeviceId)),
          SizedBox(height: 12),
          if (widget.display.collectionId != null)
            _buildInfoItem(
                'Collection', _getCollectionName(widget.display.collectionId))
          else if (widget.display.menuId != null)
            _buildInfoItem('Menu', _getMenuName(widget.display.menuId)),
          SizedBox(height: 12),
          _buildInfoItem(
              'Template', _getTemplateName(widget.display.templateId)),
          SizedBox(height: 12),
          _buildInfoItem('Display Time',
              Future.value(_formatDisplayTime(widget.display.activeHour))),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _navigateToSelectProductGroup,
            child: Text(
              'Change Product Group',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.teal,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, Future<String> futureValue) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          FutureBuilder<String>(
            future: futureValue,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text('Loading...',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                        fontWeight: FontWeight.bold));
              } else {
                return Text(
                  snapshot.data ?? 'Not available',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
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
