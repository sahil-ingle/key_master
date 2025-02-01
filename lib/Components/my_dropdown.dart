import 'package:flutter/material.dart';

class MyDropdown extends StatelessWidget {
  final List<String>? items;
  final Function(String?)? onChanged;
  final String? selectedValue;
  final String? hint;
  final String? label;
  final String? errorText;
  final bool isDense;
  final bool isExpanded;
  final EdgeInsetsGeometry? padding;

  const MyDropdown({
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.hint,
    this.label,
    this.errorText,
    this.isDense = false,
    this.isExpanded = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.blue.shade600,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.red.shade400,
              width: 1.5,
            ),
          ),
          labelText: label,
          hintText: hint,
          errorText: errorText,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
          errorStyle: TextStyle(
            color: Colors.red.shade400,
            fontSize: 12,
          ),
        ),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),
        icon: Icon(
          Icons.expand_more,
          color: Colors.grey.shade500,
          size: 20,
        ),
        elevation: 2,
        menuMaxHeight: 300,
        isDense: isDense,
        isExpanded: isExpanded,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
        items: items?.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                item,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        selectedItemBuilder: (BuildContext context) {
          return items?.map<Widget>((String item) {
                return Text(
                  item,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }).toList() ??
              [];
        },
      ),
    );
  }
}
