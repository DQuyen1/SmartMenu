import 'package:flutter/material.dart';
import 'package:smart_menu/models/menu.dart' as menu_model;
import 'package:smart_menu/models/store_menu.dart' as store_menu_model;
import 'package:smart_menu/repository/menu_repository.dart';
import 'package:smart_menu/repository/store_menu_repository.dart';

class StoreMenuFormScreen extends StatefulWidget {
  final store_menu_model.StoreMenu? storeMenu;
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
  List<menu_model.Menu>? _menuList;

  @override
  void initState() {
    super.initState();
    _menuIdController =
        TextEditingController(text: widget.storeMenu?.menuId.toString() ?? '');

    _fetchMenus();
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
        _showSnackBar('Failed to save store menu', Colors.red);
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
        title: Text(
          widget.storeMenu == null ? 'Create Store Menu' : 'Edit Store Menu',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
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
                value: widget.storeMenu?.menuId,
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
              Center(
                child: SizedBox(
                  width: double.infinity, // Make button full width
                  child: ElevatedButton(
                    onPressed: _saveStoreMenu,
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Colors.blue),
                    child: const Text(
                      'Save',
                      style: TextStyle(fontSize: 18, color: Colors.white),
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
