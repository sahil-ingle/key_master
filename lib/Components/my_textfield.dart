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

  const MyTextfield(this.controller, this.obscureText, this.hint,
      {super.key,
      this.helperText,
      this.errorText,
      this.onChanged,
      this.autofocus = false,
      this.keyboardType,
      this.textInputAction,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        autofocus: autofocus,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onChanged: onChanged,
        cursorColor: Colors.blue.shade600,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade800,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          prefixIcon:
              icon != null ? Icon(icon, color: Colors.grey.shade500) : null,
          hintText: hint,
          filled: true,
          fillColor: Colors.white.withOpacity(0.9),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.blue.shade600, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1.5),
          ),
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          helperText: helperText,
          helperStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 12,
          ),
          errorText: errorText,
          errorStyle: TextStyle(
            color: Colors.red.shade400,
            fontSize: 12,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }
}
