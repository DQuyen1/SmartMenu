import 'package:flutter/material.dart';
import 'package:smart_menu/models/display.dart';
import 'package:smart_menu/repository/display_repository.dart';
import 'package:smart_menu/models/collection.dart' as collection_model;
import 'package:smart_menu/models/store_device.dart' as device_model;
import 'package:smart_menu/models/menu.dart' as menu_model;
import 'package:smart_menu/models/template.dart' as template_model;
import 'package:smart_menu/repository/menu_repository.dart';
import 'package:smart_menu/repository/collection_repository.dart';
import 'package:smart_menu/repository/store_device_repository.dart';
import 'package:smart_menu/repository/template_repository.dart';

class DisplayFormScreen extends StatefulWidget {
  final Display? display;
  final int storeId;
  final int brandId;

  const DisplayFormScreen(
      {Key? key, this.display, required this.storeId, required this.brandId})
      : super(key: key);

  @override
  _DisplayFormScreenState createState() => _DisplayFormScreenState();
}

class _DisplayFormScreenState extends State<DisplayFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final DisplayRepository _displayRepository = DisplayRepository();

  late TextEditingController _menuIdController;
  late TextEditingController _collectionIdController;
  late TextEditingController _storeDeviceIdController;
  late TextEditingController _templateIdController;
  late double _activeHour;

  bool isMenuIdEnabled = true;
  bool isCollectionIdEnabled = true;

  List<device_model.StoreDevice>? _deviceList;
  List<menu_model.Menu>? _menuList;
  List<collection_model.Collection>? _collectionList;
  List<template_model.Template>? _templateList;

  @override
  void initState() {
    super.initState();
    _menuIdController =
        TextEditingController(text: widget.display?.menuId.toString() ?? '');
    _collectionIdController = TextEditingController(
        text: widget.display?.collectionId.toString() ?? '');
    _templateIdController = TextEditingController(
        text: widget.display?.templateId.toString() ?? '');
    _activeHour = widget.display?.activeHour ?? 0.0;
    _storeDeviceIdController = TextEditingController(
        text: widget.display?.storeDeviceId.toString() ?? '');

    _menuIdController.addListener(_onMenuIdChanged);
    _collectionIdController.addListener(_onCollectionIdChanged);

    _fetchMenus();
    _fetchCollection();
    _fetchDevice();
    _fetchTemplate();
  }

  Future<void> _fetchCollection() async {
    try {
      final collectionRepository = CollectionRepository();
      _collectionList = await collectionRepository.getAll(widget.storeId);
      setState(() {});
    } catch (e) {}
  }

  Future<void> _fetchMenus() async {
    try {
      final menuRepository = MenuRepository();
      _menuList = await menuRepository.getAll(widget.storeId);
      setState(() {});
    } catch (e) {
      _showSnackBar('Failed to fetch menus: $e', Colors.red);
    }
  }

  Future<void> _fetchDevice() async {
    try {
      final deviceRepository = StoreDeviceRepository();
      _deviceList = await deviceRepository.getAll(widget.storeId);
      setState(() {});
    } catch (e) {
      _showSnackBar('Failed to fetch menus: $e', Colors.red);
    }
  }

  Future<void> _fetchTemplate() async {
    try {
      final templateRepository = TemplateRepository();
      _templateList = await templateRepository.getAll(widget.brandId);
      setState(() {});
    } catch (e) {
      _showSnackBar('Failed to fetch menus: $e', Colors.red);
    }
  }

  @override
  void dispose() {
    _menuIdController.dispose();
    _collectionIdController.dispose();
    _templateIdController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );

    if (selectedTime != null) {
      setState(() {
        _activeHour = selectedTime.hour + selectedTime.minute / 60.0;
      });
    }
  }

  void _onMenuIdChanged() {
    setState(() {
      isCollectionIdEnabled = _menuIdController.text.isEmpty;
    });
  }

  void _onCollectionIdChanged() {
    setState(() {
      isMenuIdEnabled = _collectionIdController.text.isEmpty;
    });
  }

  void _saveDisplay() async {
    if (_formKey.currentState!.validate()) {
      final displayData = {
        'storeDeviceId': int.parse(_storeDeviceIdController.text),
        'menuId': _menuIdController.text.isNotEmpty
            ? int.parse(_menuIdController.text)
            : null,
        'collectionId': _collectionIdController.text.isNotEmpty
            ? int.parse(_collectionIdController.text)
            : null,
        'templateId': int.parse(_templateIdController.text),
        'activeHour': _activeHour,
      };

      bool success;
      if (widget.display == null) {
        success = await _displayRepository.createDisplay(displayData);
      } else {
        success = await _displayRepository.updateDisplay(
            widget.display!.displayId, displayData);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        _showSnackBar('Failed to save display', Colors.red);
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
          onPressed: () {
            // Dismiss the snackbar
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.display == null ? 'Create Display' : 'Edit Display',
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
              DropdownButtonFormField<int>(
                value: widget.display?.menuId,
                hint: const Text('Select Menu'),
                items: _menuList?.map((menu) {
                  return DropdownMenuItem<int>(
                    value: menu.menuId,
                    child: Text(menu.menuName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _menuIdController.text = value.toString();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Menu',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a menu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: widget.display?.storeDeviceId,
                hint: const Text('Select Device'),
                items: _deviceList?.map((storeDevice) {
                  return DropdownMenuItem<int>(
                    value: storeDevice.storeDeviceId,
                    child: Text(storeDevice.storeDeviceName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _storeDeviceIdController.text = value.toString();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Device',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a device';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              // DropdownButtonFormField<int>(
              //   value: widget.display?.collectionId,
              //   hint: const Text('Select Collection'),
              //   items: _collectionList?.map((collection) {
              //     return DropdownMenuItem<int>(
              //       value: collection.collectionId,
              //       child: Text(collection.collectionName),
              //     );
              //   }).toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _collectionIdController.text = value.toString();
              //     });
              //   },
              //   decoration: InputDecoration(
              //     labelText: 'Collection',
              //     labelStyle: TextStyle(
              //       fontSize: 18,
              //       color: Colors.grey[800],
              //     ),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     filled: true,
              //     fillColor: Colors.grey[200],
              //     contentPadding:
              //         const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              //   ),
              //   validator: (value) {
              //     if (value == null) {
              //       return 'Please select a collection';
              //     }
              //     return null;
              //   },
              // ),
              const SizedBox(height: 20),
              DropdownButtonFormField<int>(
                value: widget.display?.templateId,
                hint: const Text('Select Template'),
                items: _templateList?.map((template) {
                  return DropdownMenuItem<int>(
                    value: template.templateId,
                    child: Text(template.templateName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _templateIdController.text = value.toString();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Template',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a template';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => _selectTime(context),
                child: Text(
                  'Select Active Hour: ${_activeHour.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16.0),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveDisplay,
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
