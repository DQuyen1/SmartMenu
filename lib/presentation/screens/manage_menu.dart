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

  void _fetchMenus() {
    setState(() {
      _futureMenus = _menuRepository.getAll(widget.brandId);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchMenus();
    HttpOverrides.global = _DevHttpOverrides();
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
        title: const Text(
          'Delete Menu',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text('Are you sure you want to delete this menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _menuRepository.deleteMenu(menuId);
      _fetchMenus(); // Refresh the menu list
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete')),
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
        title: const Text(
          'Menus',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Number of columns in the grid
                childAspectRatio: 3 / 1, // Aspect ratio for the items
              ),
              itemCount: menus.length,
              itemBuilder: (context, index) {
                final menu = menus[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ListTile(
                        title: Text(
                          menu.menuName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text(
                          menu.menuDescription,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToMenuForm(menu: menu),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMenu(menu.menuId),
                          ),
                        ],
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
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
