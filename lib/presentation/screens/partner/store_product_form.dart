import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_product.dart';
import 'package:smart_menu/models/category.dart';
import 'package:smart_menu/repository/store_product_repository.dart';
import 'package:smart_menu/repository/category_repository.dart';

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
  List<Category>? _cateList;

  @override
  void initState() {
    super.initState();
    _productIdController = TextEditingController(
        text: widget.storeProduct?.categoryId.toString() ?? '');
    _fetchCategory();
  }

  Future<void> _fetchCategory() async {
    try {
      final cateRepository = CategoryRepository();
      _cateList = await cateRepository.getAll(widget.storeId);
      setState(() {});
    } catch (e) {
      _showSnackBar('Failed to load category: $e', Colors.red);
    }
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

      final result = await _repository.createStoreProduct(storeProductData);

      if (result['success']) {
        _showSnackBar(result['message'], Colors.green);
        Navigator.pop(context, true);
      } else {
        _showSnackBar(result['message'], Colors.orange);
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
      appBar: AppBar(
        title: Text(
            widget.storeProduct == null
                ? 'Create Store Product'
                : 'Edit Store Product',
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<int>(
                value: widget.storeProduct?.categoryId,
                hint: const Text('Select Category'),
                items: _cateList?.map((category) {
                  return DropdownMenuItem<int>(
                    value: category.categoryId,
                    child: Text(category.categoryName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _productIdController.text = value.toString();
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                validator: (value) {
                  if (value == null) {
                    return 'Please select a menu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text('Save',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
