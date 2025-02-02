import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final bool obscureText;
  final String hint;
  final String? helperText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? icon;

  const MyTextfield(
    this.controller,
    this.obscureText,
    this.hint, {
    super.key,
    this.helperText,
    this.errorText,
    this.onChanged,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        cursorColor: theme.colorScheme.primary,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          prefixIcon:
              icon != null ? Icon(icon, color: theme.iconTheme.color) : null,
          hintText: hint,
          filled: true,
          fillColor: theme.inputDecorationTheme.fillColor ?? Colors.transparent,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // Let the theme handle enabled and focused borders if provided.
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.dividerColor,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.primary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: theme.colorScheme.error,
              width: 1.5,
            ),
          ),
          hintStyle: theme.textTheme.bodyMedium?.copyWith(
            color: theme.hintColor,
          ),
          helperText: helperText,
          helperStyle: theme.textTheme.bodySmall,
          errorText: errorText,
          errorStyle: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.error,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }
}
