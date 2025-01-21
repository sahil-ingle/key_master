import 'package:flutter/material.dart';

class MyDropdown extends StatelessWidget {
  final List<String>? items;
  final Function(String?)? onChanged;
  final String? _selectedValue;

  const MyDropdown(this._selectedValue, this.items, this.onChanged,
      {super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedValue,
      items: items?.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item), // Display each item in the dropdown
        );
      }).toList(),
      onChanged: onChanged, // Call the passed function when an item is selected
    );
  }
}
