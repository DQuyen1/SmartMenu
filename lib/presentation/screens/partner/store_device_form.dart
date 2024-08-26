import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_device.dart';
import 'package:smart_menu/repository/store_device_repository.dart';

class StoreDeviceFormScreen extends StatefulWidget {
  final StoreDevice? storeDevice;
  final int storeId;

  const StoreDeviceFormScreen(
      {Key? key, this.storeDevice, required this.storeId})
      : super(key: key);

  @override
  _StoreDeviceFormScreenState createState() => _StoreDeviceFormScreenState();
}

class _StoreDeviceFormScreenState extends State<StoreDeviceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StoreDeviceRepository _storeDeviceRepository = StoreDeviceRepository();

  late TextEditingController _nameController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.storeDevice?.storeDeviceName ?? '');
    _widthController = TextEditingController(
        text: widget.storeDevice?.deviceWidth.toString() ?? '');
    _heightController = TextEditingController(
        text: widget.storeDevice?.deviceHeight.toString() ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<bool> _validateDevice() async {
    String name = _nameController.text;
    bool exists = await _storeDeviceRepository.deviceExists(
      widget.storeId,
      name,
    );

    if (exists) {
      _showSnackBar('Device already exists', Colors.red);
      return false;
    }

    return true;
  }

  void _saveStoreDevice() async {
    if (_formKey.currentState!.validate()) {
      if (widget.storeDevice == null && !(await _validateDevice())) {
        return;
      }

      final storeDeviceData = {
        'storeID': widget.storeDevice?.storeId ?? widget.storeId,
        'storeDeviceName': _nameController.text,
        'deviceWidth': int.parse(_widthController.text),
        'deviceHeight': int.parse(_heightController.text),
      };

      bool success;
      if (widget.storeDevice == null) {
        success =
            await _storeDeviceRepository.createStoreDevice(storeDeviceData);
      } else {
        success = await _storeDeviceRepository.updateStoreDevice(
            widget.storeDevice!.storeDeviceId, storeDeviceData);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        _showSnackBar('Failed to save store device', Colors.red);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.storeDevice == null
                ? 'Create Store Device'
                : 'Edit Store Device',
            style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Device Name',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _widthController,
                decoration: InputDecoration(
                  labelText: 'Device Width',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device width';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _heightController,
                decoration: InputDecoration(
                  labelText: 'Device Height',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveStoreDevice,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
