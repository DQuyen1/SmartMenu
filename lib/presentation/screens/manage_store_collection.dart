import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_collection.dart';
import 'package:smart_menu/repository/store_collection_repository.dart';
import 'package:smart_menu/presentation/screens/partner/store_collection_form.dart';

class StoreCollectionListScreen extends StatefulWidget {
  final int storeId;

  const StoreCollectionListScreen({super.key, required this.storeId});

  @override
  State<StoreCollectionListScreen> createState() =>
      _StoreCollectionListScreenState();
}

class _StoreCollectionListScreenState extends State<StoreCollectionListScreen> {
  final StoreCollectionRepository _storeCollectionRepository =
      StoreCollectionRepository();
  late Future<List<StoreCollection>> _futureStoreCollections;

  void _fetchStoreCollections() {
    setState(() {
      _futureStoreCollections =
          _storeCollectionRepository.getAll(widget.storeId);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreCollections();
    HttpOverrides.global = _DevHttpOverrides();
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
            'Are you sure you want to delete this store collection?'),
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
      final success = await _storeCollectionRepository
          .deleteStoreCollection(storeCollectionId);
      _fetchStoreCollections();
      if (success) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Failed to delete store collection')),
        // );
        _showSnackBar('Failed to delete store collection', Colors.red);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Deleted successfully')),
        // );
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
      body: FutureBuilder<List<StoreCollection>>(
        future: _futureStoreCollections,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No store collections found'));
          } else {
            final storeCollections = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Number of columns in the grid
                childAspectRatio: 3 / 1, // Aspect ratio for the items
              ),
              itemCount: storeCollections.length,
              itemBuilder: (context, index) {
                final storeCollection = storeCollections[index];
                return Card(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ListTile(
                          leading: storeCollection.collection
                                      ?.collectionBackgroundImgPath !=
                                  null
                              ? Image.network(
                                  storeCollection
                                      .collection!.collectionBackgroundImgPath!,
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.collections,
                                  color: Colors.purple, size: 40),
                          title: Text(
                              '${storeCollection.collection?.collectionName}',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Description: ${storeCollection.collection?.collectionDescription}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey)),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _navigateToStoreCollectionForm(
                                  storeCollection: storeCollection),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteStoreCollection(
                                  storeCollection.storeCollectionId),
                            ),
                          ],
                        ),
                      ],
                    )));
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToStoreCollectionForm(),
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
