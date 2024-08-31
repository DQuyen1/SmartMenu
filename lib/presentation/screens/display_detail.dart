import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/display.dart';
import 'package:smart_menu/repository/display_repository.dart';

class DisplayDetailScreen extends StatefulWidget {
  final Display display;

  const DisplayDetailScreen({super.key, required this.display});

  @override
  _DisplayDetailScreenState createState() => _DisplayDetailScreenState();
}

class _DisplayDetailScreenState extends State<DisplayDetailScreen> {
  final DisplayRepository _repository = DisplayRepository();

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Display Details'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.display.displayImgPath != null &&
                Uri.tryParse(widget.display.displayImgPath!)?.hasAbsolutePath ==
                    true)
              Image.network(
                widget.display.displayImgPath!,
                fit: BoxFit.cover,
              )
            else
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey.shade300,
                child: const Icon(
                  Icons.image,
                  color: Colors.grey,
                  size: 100,
                ),
              ),
            const SizedBox(height: 16),
            if (widget.display.storeDeviceId != null)
              FutureBuilder<String>(
                future: _getDeviceName(widget.display.storeDeviceId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading device name...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('Device: ${snapshot.data ?? 'No device'}');
                  }
                },
              ),
            if (widget.display.collectionId != null) const SizedBox(height: 8),
            if (widget.display.collectionId != null)
              FutureBuilder<String>(
                future: _getCollectionName(widget.display.collectionId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading collection name...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text(
                        'Collection: ${snapshot.data ?? 'No collection'}');
                  }
                },
              ),
            if (widget.display.templateId != null) const SizedBox(height: 8),
            if (widget.display.templateId != null)
              FutureBuilder<String>(
                future: _getTemplateName(widget.display.templateId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading template name...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('Template: ${snapshot.data ?? 'No template'}');
                  }
                },
              ),
            if (widget.display.menuId != null) const SizedBox(height: 8),
            if (widget.display.menuId != null)
              FutureBuilder<String>(
                future: _getMenuName(widget.display.menuId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text('Loading menu name...');
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    return Text('Menu: ${snapshot.data ?? 'No menu'}');
                  }
                },
              ),
          ],
        ),
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
