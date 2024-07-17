import 'package:flutter/material.dart';
import 'package:smart_menu/presentation/screens/display_image.dart';

class DisplayIdInputScreen extends StatefulWidget {
  @override
  _DisplayIdInputScreenState createState() => _DisplayIdInputScreenState();
}

class _DisplayIdInputScreenState extends State<DisplayIdInputScreen> {
  final TextEditingController _controller = TextEditingController();

  void _navigateToImageListScreen() {
    final int displayId = int.tryParse(_controller.text) ?? -1;
    if (displayId != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImageListScreen(displayId: displayId),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid displayId')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Display ID'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Display ID'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToImageListScreen,
              child: Text('View Images'),
            ),
          ],
        ),
      ),
    );
  }
}
