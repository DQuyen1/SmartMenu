import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_menu.dart';
import 'package:smart_menu/repository/store_menu_repository.dart';

class StoreMenuFormScreen extends StatefulWidget {
  final StoreMenu? storeMenu;
  final int storeId;

  const StoreMenuFormScreen({Key? key, this.storeMenu, required this.storeId})
      : super(key: key);

  @override
  _StoreMenuFormScreenState createState() => _StoreMenuFormScreenState();
}

class _StoreMenuFormScreenState extends State<StoreMenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StoreMenuRepository _storeMenuRepository = StoreMenuRepository();

  late TextEditingController _menuIdController;

  @override
  void initState() {
    super.initState();
    _menuIdController =
        TextEditingController(text: widget.storeMenu?.menuId.toString() ?? '');
  }

  @override
  void dispose() {
    _menuIdController.dispose();
    super.dispose();
  }

  void _saveStoreMenu() async {
    if (_formKey.currentState!.validate()) {
      final storeMenuData = {
        'storeId': widget.storeMenu?.storeId ?? widget.storeId,
        'menuId': int.parse(_menuIdController.text),
      };

      bool success;
      if (widget.storeMenu == null) {
        success = await _storeMenuRepository.createStoreMenu(storeMenuData);
      } else {
        success = await _storeMenuRepository.updateStoreMenu(
            widget.storeMenu!.storeMenuId, storeMenuData);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save store menu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.storeMenu == null ? 'Create Store Menu' : 'Edit Store Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _menuIdController,
                decoration: const InputDecoration(labelText: 'Menu ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter menu ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStoreMenu,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
