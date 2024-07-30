import 'package:flutter/material.dart';
import 'package:smart_menu/models/store_collection.dart'
    as store_collection_model;
import 'package:smart_menu/repository/store_collection_repository.dart';
import 'package:smart_menu/models/collection.dart' as collection_model;
import 'package:smart_menu/repository/collection_repository.dart';

class StoreCollectionFormScreen extends StatefulWidget {
  final store_collection_model.StoreCollection? storeCollection;
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
  List<collection_model.Collection>? _collectionList;

  @override
  void initState() {
    super.initState();
    _collectionIdController = TextEditingController(
        text: widget.storeCollection?.collectionId.toString() ?? '');
    _fetchCollection();
  }

  Future<void> _fetchCollection() async {
    try {
      final collectionRepository = CollectionRepository();
      _collectionList = await collectionRepository.getAll(widget.storeId);
      setState(() {});
    } catch (e) {}
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
              DropdownButtonFormField<int>(
                value: widget.storeCollection?.collectionId,
                hint: const Text('Select Collection'),
                items: _collectionList?.map((collection) {
                  return DropdownMenuItem<int>(
                    value: collection.collectionId,
                    child: Text(collection.collectionName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _collectionIdController.text = value.toString();
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a collection';
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
