import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_menu/repository/get_image.dart';

class ImageListScreen extends StatefulWidget {
  final int displayId;

  const ImageListScreen({Key? key, required this.displayId}) : super(key: key);

  @override
  _ImageListScreenState createState() => _ImageListScreenState();
}

class _ImageListScreenState extends State<ImageListScreen> {
  late Future<List<Image>> _futureImages;

  @override
  void initState() {
    super.initState();
    _futureImages = fetchImages(widget.displayId) as Future<List<Image>>;
    HttpOverrides.global = _DevHttpOverrides();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Image>>(
        future: _futureImages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No images found'));
          } else {
            final images = snapshot.data!;
            return ListView.builder(
              itemCount: images.length,
              itemBuilder: (context, index) {
                return images[index];
              },
            );
          }
        },
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
