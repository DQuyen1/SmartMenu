import 'package:flutter/material.dart';
import 'package:smart_menu/presentation/screens/display_device.dart';
import 'package:smart_menu/presentation/screens/display_image.dart';

class DisplayDeviceForm extends StatefulWidget {
  @override
  _DisplayDeviceFormState createState() => _DisplayDeviceFormState();
}

class _DisplayDeviceFormState extends State<DisplayDeviceForm> {
  final TextEditingController _controller = TextEditingController();

  void _navigateToDisplayDevice() {
    final int deviceId = int.tryParse(_controller.text) ?? -1;
    if (deviceId != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayDevice(deviceId: deviceId),
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
        title: Text('Enter Device Id'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Device Id'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _navigateToDisplayDevice,
              child: Text('View Images'),
            ),
          ],
        ),
      ),
    );
  }
}
