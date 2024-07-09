import 'package:flutter/material.dart';
import 'package:smart_menu/models/menu.dart';
import 'package:smart_menu/repository/menu_repository.dart';

class MenuFormScreen extends StatefulWidget {
  final Menu? menu;
  final int brandId;

  const MenuFormScreen({Key? key, this.menu, required this.brandId})
      : super(key: key);

  @override
  _MenuFormScreenState createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends State<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final MenuRepository _menuRepository = MenuRepository();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.menu?.menuName ?? '');
    _descriptionController =
        TextEditingController(text: widget.menu?.menuDescription ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveMenu() async {
    if (_formKey.currentState!.validate()) {
      final menuData = {
        'brandID': widget.menu?.brandId ?? widget.brandId,
        'menuName': _nameController.text,
        'menuDescription': _descriptionController.text,
      };

      bool success;
      if (widget.menu == null) {
        success = await _menuRepository.createMenu(menuData);
      } else {
        success =
            await _menuRepository.updateMenu(widget.menu!.menuId, menuData);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save menu')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menu == null ? 'Create Menu' : 'Edit Menu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Menu Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter menu name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Menu Description'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter menu description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMenu,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
