import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_collection.dart';
import 'package:smart_menu/repository/store_collection_repository.dart';

class StoreCollectionFormScreen extends StatefulWidget {
  final StoreCollection? storeCollection;
  final int storeId;

  const StoreCollectionFormScreen(
      {Key? key, this.storeCollection, required this.storeId})
      : super(key: key);

  @override
  _StoreCollectionFormScreenState createState() =>
      _StoreCollectionFormScreenState();
}

class _StoreCollectionFormScreenState extends State<StoreCollectionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StoreCollectionRepository _storeCollectionRepository =
      StoreCollectionRepository();

  late TextEditingController _collectionIdController;

  @override
  void initState() {
    super.initState();
    _collectionIdController = TextEditingController(
        text: widget.storeCollection?.collectionId.toString() ?? '');
  }

  @override
  void dispose() {
    _collectionIdController.dispose();
    super.dispose();
  }

  void _saveStoreCollection() async {
    if (_formKey.currentState!.validate()) {
      final storeCollectionData = {
        'storeId': widget.storeCollection?.storeId ?? widget.storeId,
        'collectionId': int.parse(_collectionIdController.text),
      };

      bool success;
      if (widget.storeCollection == null) {
        success = await _storeCollectionRepository
            .createStoreCollection(storeCollectionData);
      } else {
        success = await _storeCollectionRepository.updateStoreCollection(
            widget.storeCollection!.storeCollectionId, storeCollectionData);
      }

      if (success) {
        Navigator.pop(context, true);
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   const SnackBar(content: Text('Failed to save store collection')),
        // );

        _showSnackBar('Failed to save store collection', Colors.red);
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
      appBar: AppBar(
        title: Text(
            widget.storeCollection == null
                ? 'Create Store Collection'
                : 'Edit Store Collection',
            style: const TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _collectionIdController,
                decoration: InputDecoration(
                  labelText: 'Collection ID',
                  labelStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[800],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  filled: true,
                  focusedBorder: InputBorder.none,
                  fillColor: Colors.grey[200],
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter collection ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Center(
                child: SizedBox(
                  width: double.infinity, // Make button full width
                  child: ElevatedButton(
                    onPressed: _saveStoreCollection,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
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
