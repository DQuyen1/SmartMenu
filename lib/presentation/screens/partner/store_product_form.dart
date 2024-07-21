import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_product.dart';
import 'package:smart_menu/repository/store_product_repository.dart';

class StoreProductFormScreen extends StatefulWidget {
  final StoreProduct? storeProduct;
  final int storeId;
  const StoreProductFormScreen(
      {Key? key, this.storeProduct, required this.storeId})
      : super(key: key);

  @override
  _StoreProductFormScreenState createState() => _StoreProductFormScreenState();
}

class _StoreProductFormScreenState extends State<StoreProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StoreProductRepository _repository = StoreProductRepository();
  late TextEditingController _productIdController;

  @override
  void initState() {
    super.initState();
    _productIdController = TextEditingController(
        text: widget.storeProduct?.categoryId.toString() ?? '');
  }

  @override
  void dispose() {
    _productIdController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final storeProductData = {
        'storeId': widget.storeProduct?.storeId ?? widget.storeId,
        'categoryId': int.parse(_productIdController.text),
      };

      bool success;
      if (widget.storeProduct == null) {
        success = await _repository.createStoreProduct(storeProductData);
      } else {
        success = await _repository.updateStoreProduct(
            widget.storeProduct!.storeProductId, storeProductData as bool);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save store product')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeProduct == null
            ? 'Create Store Product'
            : 'Edit Store Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _productIdController,
                decoration: const InputDecoration(labelText: 'Category Id'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter category Id';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
