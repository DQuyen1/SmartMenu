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
        title: const Text('Delete Store Product',
            style: TextStyle(
                color: Colors.red, fontWeight: FontWeight.bold, fontSize: 20)),
        content:
            const Text('Are you sure you want to delete this store product?'),
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
      final success = await _repository.deleteStoreProduct(storeProductId);
      _fetchStoreProduct();
      if (success) {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Failed to delete product')),
        // );

        _showSnackBar('Failed to delete product', Colors.red);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Store menu deleted successfully')),
        // );

        _showSnackBar('Store menu deleted successfully', Colors.green);
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
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Failed to update product availability')),
      // );

      _showSnackBar('Failed to update product availability', Colors.red);
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
        title: const Text('Store Products',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
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
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1, // Number of columns in the grid
                childAspectRatio: 3 / 1, // Aspect ratio for the items
              ),
              itemCount: storeProducts.length,
              itemBuilder: (context, index) {
                final storeProduct = storeProducts[index];
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
                            '${storeProduct.product?.productName ?? 'Unknown'}',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Description: ${storeProduct.product?.productDescription ?? 'No description'}',
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.grey)),
                            // Text(
                            //     'Available: ${storeProduct.isAvailable ? 'On' : 'Off'}'),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                            iconSize: 32,
                            onPressed: () => _toggleAvailability(storeProduct),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _navigateToStoreProductForm(
                                storeProduct: storeProduct),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteStoreProduct(
                                storeProduct.storeProductId),
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
        onPressed: () => _navigateToStoreProductForm(),
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
