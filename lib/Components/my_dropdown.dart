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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: padding!,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.outline,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: 1.5,
            ),
          ),
          labelText: label,
          hintText: hint,
          errorText: errorText,
          labelStyle: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.error,
            fontSize: 12,
          ),
        ),
        dropdownColor: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        icon: Icon(
          Icons.expand_more,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        elevation: 2,
        menuMaxHeight: 300,
        isDense: isDense,
        isExpanded: isExpanded,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        items: items?.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                item,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                );
              }).toList() ??
              [];
        },
      ),
    );
  }
}
