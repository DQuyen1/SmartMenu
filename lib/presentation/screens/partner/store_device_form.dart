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

  void _saveStoreDevice() async {
    if (_formKey.currentState!.validate()) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save store device')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeDevice == null
            ? 'Create Store Device'
            : 'Edit Store Device'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Device Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _widthController,
                decoration: const InputDecoration(labelText: 'Device Width'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device width';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(labelText: 'Device Height'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter device height';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStoreDevice,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
