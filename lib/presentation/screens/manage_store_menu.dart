import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_menu.dart';
import 'package:smart_menu/presentation/screens/store_menu_detail.dart';
import 'package:smart_menu/repository/store_menu_repository.dart';
import 'package:smart_menu/presentation/screens/partner/store_menu_form.dart';

class StoreMenuListScreen extends StatefulWidget {
  final int storeId;
  final int brandId;

  const StoreMenuListScreen(
      {super.key, required this.storeId, required this.brandId});

  @override
  State<StoreMenuListScreen> createState() => _StoreMenuListScreenState();
}

class _StoreMenuListScreenState extends State<StoreMenuListScreen> {
  final StoreMenuRepository _storeMenuRepository = StoreMenuRepository();
  late Future<List<StoreMenu>> _futureStoreMenus;
  String _searchQuery = '';
  String _sortOption = 'newest';

  void _fetchStoreMenus() {
    setState(() {
      _futureStoreMenus =
          _storeMenuRepository.getAll(widget.storeId).then((storeMenus) {
        switch (_sortOption) {
          case 'newest':
            storeMenus.sort((a, b) => b.storeMenuId.compareTo(a.storeMenuId));
            break;
          case 'oldest':
            storeMenus.sort((a, b) => a.storeMenuId.compareTo(b.storeMenuId));
            break;
          case 'name_asc':
            storeMenus.sort((a, b) => (a.menu?.menuName?.toLowerCase() ?? '')
                .compareTo(b.menu?.menuName?.toLowerCase() ?? ''));
            break;
          case 'name_desc':
            storeMenus.sort((a, b) => (b.menu?.menuName?.toLowerCase() ?? '')
                .compareTo(a.menu?.menuName?.toLowerCase() ?? ''));
            break;
          default:
            storeMenus.sort((a, b) => b.storeMenuId.compareTo(a.storeMenuId));
        }

        if (_searchQuery.isNotEmpty) {
          storeMenus = storeMenus
              .where((storeMenu) =>
                  storeMenu.menu?.menuName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false)
              .toList();
        }
        return storeMenus;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreMenus();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void _navigateToMenuDetail(int menuId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreMenuDetail(
          menuId: menuId,
          brandId: widget.brandId,
        ),
      ),
    );
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
        title: const Text('Delete Store Menu',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
        content: const Text('Are you sure you want to delete this store menu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _storeMenuRepository.deleteStoreMenu(storeMenuId);

      if (success) {
        _showSnackBar('Failed', Colors.red);
      } else {
        _fetchStoreMenus();
        _showSnackBar('Menu deleted successfully', Colors.green);
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: const Text(
              'Store Menus',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.orange.shade100,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchUI(),
          Expanded(
            child: FutureBuilder<List<StoreMenu>>(
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
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 3 / 1,
                    ),
                    itemCount: storeMenus.length,
                    itemBuilder: (context, index) {
                      final storeMenu = storeMenus[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.restaurant,
                                  size: 40, color: Colors.orange),
                              title: Text('${storeMenu.menu?.menuName}',
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(
                                  'Description: ${storeMenu.menu?.menuDescription}',
                                  style: const TextStyle(
                                      fontSize: 16, color: Colors.grey)),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.view_agenda,
                                      color: Colors.blue),
                                  onPressed: () =>
                                      _navigateToMenuDetail(storeMenu.menuId),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  onPressed: () => _navigateToStoreMenuForm(
                                      storeMenu: storeMenu),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () =>
                                      _deleteStoreMenu(storeMenu.storeMenuId),
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
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToStoreMenuForm(),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchUI() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        offset: Offset(0, 2),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.only(right: 16),
                  child: Padding(
                    padding:
                        EdgeInsets.only(left: 16, right: 16, top: 4, bottom: 4),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search menus...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _fetchStoreMenus();
                        });
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DropdownButton<String>(
                  value: _sortOption,
                  onChanged: (newValue) {
                    setState(() {
                      _sortOption = newValue!;
                      _fetchStoreMenus();
                    });
                  },
                  items: <String>['newest', 'oldest', 'name_asc', 'name_desc']
                      .map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_getSortOptionLabel(value)),
                    );
                  }).toList(),
                  hint: const Text('Sort by'),
                  isExpanded: true,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  'Filter',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getSortOptionLabel(String sortOption) {
    switch (sortOption) {
      case 'newest':
        return 'Newest';
      case 'oldest':
        return 'Oldest';
      case 'name_asc':
        return 'Name: A-Z';
      case 'name_desc':
        return 'Name: Z-A';
      default:
        return 'Sort by';
    }
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
