import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<List<Image>> fetchDeviceDisplay(int deviceId) async {
  final url =
      'https://ec2-3-1-81-96.ap-southeast-1.compute.amazonaws.com/api/Displays/V1/$deviceId/image';
  print('Fetching images from URL: $url');
  final response = await http.get(Uri.parse(url));
  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    return [Image.memory(response.bodyBytes)];
  } else {
    throw Exception('Failed to load images');
  }
}

class DisplayDevice extends StatefulWidget {
  final int deviceId;

  const DisplayDevice({Key? key, required this.deviceId}) : super(key: key);

  @override
  _DisplayDeviceState createState() => _DisplayDeviceState();
}

class _DisplayDeviceState extends State<DisplayDevice> {
  late Future<List<Image>> _futureImages;
  late Timer _timer;
  bool _showImages = true;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _startTimer();
  }

  void _fetchImages() {
    setState(() {
      _futureImages = fetchDeviceDisplay(widget.deviceId);
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _fetchImages();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
