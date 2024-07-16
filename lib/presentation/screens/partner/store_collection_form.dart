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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save store collection')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storeCollection == null
            ? 'Create Store Collection'
            : 'Edit Store Collection'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _collectionIdController,
                decoration: const InputDecoration(labelText: 'Collection ID'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter collection ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveStoreCollection,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
