import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_menu.dart';
import 'package:smart_menu/repository/store_menu_repository.dart';
import 'package:smart_menu/presentation/screens/partner/store_menu_form.dart';

class StoreMenuListScreen extends StatefulWidget {
  final int storeId;

  const StoreMenuListScreen({super.key, required this.storeId});

  @override
  State<StoreMenuListScreen> createState() => _StoreMenuListScreenState();
}

class _StoreMenuListScreenState extends State<StoreMenuListScreen> {
  final StoreMenuRepository _storeMenuRepository = StoreMenuRepository();
  late Future<List<StoreMenu>> _futureStoreMenus;

  void _fetchStoreMenus() {
    setState(() {
      _futureStoreMenus = _storeMenuRepository.getAll(widget.storeId);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreMenus();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void _navigateToStoreMenuForm({StoreMenu? storeMenu}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreMenuFormScreen(
          storeMenu: storeMenu,
          storeId: widget.storeId,
        ),
      ),
    );

    if (result == true) {
      _fetchStoreMenus();
    }
  }

  void _deleteStoreMenu(int storeMenuId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Store Menu'),
        content: const Text('Are you sure you want to delete this store menu?'),
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
      final success = await _storeMenuRepository.deleteStoreMenu(storeMenuId);
      _fetchStoreMenus();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete menu')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Menus'),
      ),
      body: FutureBuilder<List<StoreMenu>>(
        future: _futureStoreMenus,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No store menus found'));
          } else {
            final storeMenus = snapshot.data!;
            return ListView.builder(
              itemCount: storeMenus.length,
              itemBuilder: (context, index) {
                final storeMenu = storeMenus[index];
                return ListTile(
                  title: Text(' ${storeMenu.menu?.menuName}'),
                  subtitle:
                      Text('Description: ${storeMenu.menu?.menuDescription}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () =>
                            _navigateToStoreMenuForm(storeMenu: storeMenu),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _deleteStoreMenu(storeMenu.storeMenuId),
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
        onPressed: () => _navigateToStoreMenuForm(),
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
