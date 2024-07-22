import 'package:flutter/material.dart';
import 'package:smart_menu/models/menu.dart';

class SearchableDropdown extends StatefulWidget {
  final List<Menu> menus;
  final int? selectedMenuId;
  final ValueChanged<int?> onChanged;
  final String hint;

  const SearchableDropdown({
    Key? key,
    required this.menus,
    required this.selectedMenuId,
    required this.onChanged,
    required this.hint,
  }) : super(key: key);

  @override
  _SearchableDropdownState createState() => _SearchableDropdownState();
}

class _SearchableDropdownState extends State<SearchableDropdown> {
  final TextEditingController _searchController = TextEditingController();
  List<Menu> _filteredMenus = [];

  @override
  void initState() {
    super.initState();
    _filteredMenus = widget.menus;
    _searchController.addListener(_filterMenus);
  }

  void _filterMenus() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredMenus = widget.menus
          .where((menu) => menu.menuName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterMenus);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            labelText: widget.hint,
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: 10),
        DropdownButtonFormField<int>(
          value: widget.selectedMenuId,
          items: _filteredMenus.map((menu) {
            return DropdownMenuItem<int>(
              value: menu.menuId,
              child: Text(menu.menuName),
            );
          }).toList(),
          onChanged: widget.onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
