import 'package:flutter/material.dart';
import 'package:smart_menu/repository/display_repository.dart';

class SelectProductGroupScreen extends StatefulWidget {
  final List<int> displayItemIds;
  final List<int> productGroupIds;

  const SelectProductGroupScreen({
    Key? key,
    required this.displayItemIds,
    required this.productGroupIds,
  }) : super(key: key);

  @override
  _SelectProductGroupScreenState createState() =>
      _SelectProductGroupScreenState();
}

class _SelectProductGroupScreenState extends State<SelectProductGroupScreen> {
  final DisplayRepository _repository = DisplayRepository();
  Map<int, String> _productGroupMap = {};
  int? _selectedDisplayItemId;
  int? _selectedProductGroupId;

  @override
  void initState() {
    super.initState();
    _fetchProductGroupNames();
  }

  Future<void> _fetchProductGroupNames() async {
    final Map<int, String> map = {};
    for (int id in widget.productGroupIds) {
      try {
        final name = await _repository.getProductGroupName(id);
        map[id] = name;
      } catch (e) {
        print('Error fetching product group name for ID $id: $e');
        map[id] = 'Error';
      }
    }
    setState(() => _productGroupMap = map);
  }

  void _updateProductGroup() async {
    if (_selectedDisplayItemId == null || _selectedProductGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Please select both a display item and a product group')),
      );
      return;
    }

    final success = await _repository.updateDisplayProductGroup(
      _selectedDisplayItemId!,
      {'productGroupId': _selectedProductGroupId},
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(success
              ? 'Product group updated successfully'
              : 'Failed to update product group')),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: Container(
        color: Colors.teal,
        child: Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose which category will change:',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 30),
                      _buildDropdown(
                        value: _selectedDisplayItemId,
                        items: widget.displayItemIds,
                        onChanged: (value) =>
                            setState(() => _selectedDisplayItemId = value),
                        hint: 'Select Render Layer',
                        itemBuilder: (id, index) => 'Render Layer ${index + 1}',
                      ),
                      SizedBox(height: 20),
                      _buildDropdown(
                        value: _selectedProductGroupId,
                        items: widget.productGroupIds,
                        onChanged: (value) =>
                            setState(() => _selectedProductGroupId = value),
                        hint: 'Select Product Group',
                        itemBuilder: (id, _) =>
                            _productGroupMap[id] ?? 'Unknown',
                      ),
                      Spacer(),
                      ElevatedButton(
                        onPressed: _updateProductGroup,
                        child: Text('Change',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          minimumSize: Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required int? value,
    required List<int> items,
    required ValueChanged<int?> onChanged,
    required String hint,
    required String Function(int, int) itemBuilder,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.teal),
          padding: EdgeInsets.symmetric(horizontal: 16),
          onChanged: onChanged,
          items: items.asMap().entries.map((entry) {
            final index = entry.key;
            final id = entry.value;
            return DropdownMenuItem<int>(
              value: id,
              child: Text(itemBuilder(id, index)),
            );
          }).toList(),
        ),
      ),
    );
  }
}
