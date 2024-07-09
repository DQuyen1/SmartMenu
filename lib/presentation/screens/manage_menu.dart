import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_menu/models/menu.dart';
import 'package:smart_menu/repository/menu_repository.dart';
import 'package:smart_menu/presentation/screens/partner/menu_form_screen.dart';

class MenuListScreen extends StatefulWidget {
  final int brandId;

  const MenuListScreen({super.key, required this.brandId});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final MenuRepository _menuRepository = MenuRepository();
  late Future<List<Menu>> _futureMenus;

  @override
  void initState() {
    super.initState();
    _fetchMenus();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void _fetchMenus() {
    setState(() {
      _futureMenus = _menuRepository.getAll();
    });
  }

  void _navigateToMenuForm({Menu? menu}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MenuFormScreen(
          menu: menu,
          brandId: widget.brandId,
        ),
      ),
    );

    if (result == true) {
      _fetchMenus();
    }
  }

  void _deleteMenu(int menuId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Menu'),
        content: const Text('Are you sure you want to delete this menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final fail = await _menuRepository.deleteMenu(menuId);
      if (fail) {
        _fetchMenus(); // Refresh the menu list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fail deleted successfully')),
        );
      } else {
        _fetchMenus();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Menu deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menus'),
      ),
      body: FutureBuilder<List<Menu>>(
        future: _futureMenus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No menus found'));
          } else {
            final menus = snapshot.data!;
            return ListView.builder(
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                return ListTile(
                  title: Text(menu.menuName),
                  subtitle: Text(menu.menuDescription),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToMenuForm(menu: menu),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMenu(menu.menuId),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToMenuForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DevHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
