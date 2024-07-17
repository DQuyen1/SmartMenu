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
  bool _showImages = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _futureImages = fetchImages(widget.displayId);
  }

  void _toggleImageVisibility() {
    setState(() {
      _showImages = !_showImages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Images'),
        actions: [
          MouseRegion(
            onEnter: (_) {
              setState(() {
                _isHovering = true;
              });
            },
            onExit: (_) {
              setState(() {
                _isHovering = false;
              });
            },
            child: AnimatedOpacity(
              opacity: _isHovering ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: IconButton(
                icon:
                    Icon(_showImages ? Icons.visibility : Icons.visibility_off),
                onPressed: _toggleImageVisibility,
              ),
            ),
          ),
        ],
      ),
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
            return _showImages
                ? ListView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return images[index];
                    },
                  )
                : const Center(child: Text(''));
          }
        },
      ),
    );
  }
}
