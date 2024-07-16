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
        title: const Text('Delete Store Collection'),
        content: const Text(
            'Are you sure you want to delete this store collection?'),
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
      final success = await _storeCollectionRepository
          .deleteStoreCollection(storeCollectionId);
      _fetchStoreCollections();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete store collection')),
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
        title: const Text('Store Collections'),
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
            return ListView.builder(
              itemCount: storeCollections.length,
              itemBuilder: (context, index) {
                final storeCollection = storeCollections[index];
                return ListTile(
                  title: Text('Collection ID: ${storeCollection.collectionId}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToStoreCollectionForm(
                            storeCollection: storeCollection),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteStoreCollection(
                            storeCollection.storeCollectionId),
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
        onPressed: () => _navigateToStoreCollectionForm(),
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
