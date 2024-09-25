import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_collection.dart';
import 'package:smart_menu/presentation/screens/store_menu_detail.dart';
import 'package:smart_menu/repository/store_collection_repository.dart';
import 'package:smart_menu/presentation/screens/partner/store_collection_form.dart';

class StoreCollectionListScreen extends StatefulWidget {
  final int storeId;
  final int brandId;

  const StoreCollectionListScreen(
      {super.key, required this.storeId, required this.brandId});

  @override
  State<StoreCollectionListScreen> createState() =>
      _StoreCollectionListScreenState();
}

class _StoreCollectionListScreenState extends State<StoreCollectionListScreen> {
  final StoreCollectionRepository _storeCollectionRepository =
      StoreCollectionRepository();
  late Future<List<StoreCollection>> _futureStoreCollections;
  String _searchQuery = '';
  String _sortOption = 'newest';

  @override
  void initState() {
    super.initState();
    _fetchStoreCollections();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void _fetchStoreCollections() {
    setState(() {
      _futureStoreCollections = _storeCollectionRepository
          .getAll(widget.storeId)
          .then((storeCollections) {
        switch (_sortOption) {
          case 'newest':
            storeCollections.sort(
                (a, b) => b.storeCollectionId.compareTo(a.storeCollectionId));
            break;
          case 'oldest':
            storeCollections.sort(
                (a, b) => a.storeCollectionId.compareTo(b.storeCollectionId));
            break;
          case 'name_asc':
            storeCollections.sort((a, b) => (a.collection?.collectionName ?? '')
                .toLowerCase()
                .compareTo((b.collection?.collectionName ?? '').toLowerCase()));
            break;
          case 'name_desc':
            storeCollections.sort((a, b) => (b.collection?.collectionName ?? '')
                .toLowerCase()
                .compareTo((a.collection?.collectionName ?? '').toLowerCase()));
            break;
          default:
            break;
        }
        if (_searchQuery.isNotEmpty) {
          storeCollections = storeCollections
              .where((storeCollection) =>
                  storeCollection.collection?.collectionName
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false)
              .toList();
        }
        return storeCollections;
      });
    });
  }

  void _navigateToCollectionDetail(int collectionId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreMenuDetail(
          brandId: widget.brandId,
          menuId: collectionId,
        ),
      ),
    );
  }

  void _navigateToStoreCollectionForm(
      {StoreCollection? storeCollection}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreCollectionFormScreen(
          storeCollection: storeCollection,
          storeId: widget.storeId,
        ),
      ),
    );

    if (result == true) {
      _fetchStoreCollections();
    }
  }

  void _deleteStoreCollection(int storeCollectionId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Store Collection',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
        content: const Text(
            'Are you sure you want to change status this collection?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Agree', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _storeCollectionRepository
          .deleteStoreCollection(storeCollectionId);
      _fetchStoreCollections();
      if (success) {
        _showSnackBar('Failed to delete store collection', Colors.red);
      } else {
        _showSnackBar('Deleted successfully', Colors.green);
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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          child: AppBar(
            title: const Text(
              'Store Collections',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.purple.shade100,
          ),
        ),
      ),
      body: SingleChildScrollView(
        // Wrap here
        child: Column(
          children: [
            _buildSearchUI(),
            // Removed Expanded, since it's in a scrollable view
            FutureBuilder<List<StoreCollection>>(
              future: _futureStoreCollections,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No collection found'));
                } else {
                  final storeCollections = snapshot.data!;
                  return GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 3 / 1,
                    ),
                    itemCount: storeCollections.length,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable scrolling for GridView
                    shrinkWrap:
                        true, // Allow GridView to take the height of its children
                    itemBuilder: (context, index) {
                      final storeCollection = storeCollections[index];

                      Color backgroundColor = storeCollection.isDeleted
                          ? Colors.grey[300]!
                          : Colors.white;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        color: backgroundColor,
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ListTile(
                                title: Text(
                                  '${storeCollection.collection?.collectionName}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  'Description: ${storeCollection.collection?.collectionDescription}',
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
                                    icon: const Icon(Icons.restaurant,
                                        color: Colors.blue),
                                    onPressed: () =>
                                        _navigateToCollectionDetail(
                                            storeCollection.collectionId),
                                  ),
                                  // IconButton(
                                  //   icon: const Icon(Icons.edit,
                                  //       color: Colors.blue),
                                  //   onPressed: () =>
                                  //       _navigateToStoreCollectionForm(
                                  //           storeCollection: storeCollection),
                                  // ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () => _deleteStoreCollection(
                                        storeCollection.storeCollectionId),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _navigateToStoreCollectionForm(),
      //   backgroundColor: Colors.green,
      //   child: const Icon(Icons.add, color: Colors.white),
      // ),
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
                        hintText: 'Search collections...',
                        border: InputBorder.none,
                        prefixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                          _fetchStoreCollections();
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
                      _fetchStoreCollections();
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
