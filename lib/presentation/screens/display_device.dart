import 'package:flutter/material.dart';
import 'package:smart_menu/repository/device_display_repository.dart';
import 'package:smart_menu/repository/get_image.dart';

class DisplayDevice extends StatefulWidget {
  final int deviceId;

  const DisplayDevice({Key? key, required this.deviceId}) : super(key: key);

  @override
  _DisplayDeviceState createState() => _DisplayDeviceState();
}

class _DisplayDeviceState extends State<DisplayDevice> {
  late Future<List<Image>> _futureImages;
  bool _showImages = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _futureImages = FetchDeviceDisplay(widget.deviceId);
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
