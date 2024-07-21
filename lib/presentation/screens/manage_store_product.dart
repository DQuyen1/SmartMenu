import 'dart:io';

import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_product.dart';
import 'package:smart_menu/repository/store_product_repository.dart';
import 'package:smart_menu/presentation/screens/partner/store_product_form.dart';

class StoreProductListScreen extends StatefulWidget {
  final int storeId;

  const StoreProductListScreen({super.key, required this.storeId});

  @override
  _StoreProductListScreenState createState() => _StoreProductListScreenState();
}

class _StoreProductListScreenState extends State<StoreProductListScreen> {
  late Future<List<StoreProduct>> _futureStoreProducts;
  final StoreProductRepository _repository = StoreProductRepository();

  void _fetchStoreProduct() {
    setState(() {
      _futureStoreProducts = _repository.getAll(widget.storeId);
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchStoreProduct();
    HttpOverrides.global = _DevHttpOverrides();
  }

  void _navigateToStoreProductForm({StoreProduct? storeProduct}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StoreProductFormScreen(
          storeProduct: storeProduct,
          storeId: widget.storeId,
        ),
      ),
    );

    if (result == true) {
      _fetchStoreProduct();
    }
  }

  void _deleteStoreProduct(int storeProductId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Store Product'),
        content:
            const Text('Are you sure you want to delete this store product?'),
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
      final success = await _repository.deleteStoreProduct(storeProductId);
      _fetchStoreProduct();
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete product')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Store menu deleted successfully')),
        );
      }
    }
  }

  void _toggleAvailability(StoreProduct storeProduct) async {
    final success = await _repository.updateStoreProduct(
      storeProduct.storeProductId,
      !storeProduct.isAvailable,
    );
    if (success) {
      setState(() {
        storeProduct.isAvailable = !storeProduct.isAvailable;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update product availability')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Products'),
      ),
      body: FutureBuilder<List<StoreProduct>>(
        future: _futureStoreProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No store product found'));
          } else {
            final storeProducts = snapshot.data!;
            return ListView.builder(
              itemCount: storeProducts.length,
              itemBuilder: (context, index) {
                final storeProduct = storeProducts[index];
                return ListTile(
                  title: Text('Product ID: ${storeProduct.productId}'),
                  subtitle: Text(
                      'Store ID: ${storeProduct.storeId}\nAvailable: ${storeProduct.isAvailable}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          storeProduct.isAvailable
                              ? Icons.toggle_on
                              : Icons.toggle_off,
                          color: storeProduct.isAvailable
                              ? Colors.green
                              : Colors.red,
                        ),
                        onPressed: () => _toggleAvailability(storeProduct),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToStoreProductForm(
                            storeProduct: storeProduct),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () =>
                            _deleteStoreProduct(storeProduct.storeProductId),
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
        onPressed: () => _navigateToStoreProductForm(),
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
