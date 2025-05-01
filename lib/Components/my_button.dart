import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final VoidCallback? onBtnPress;
  final IconData icon;
  /// If null, defaults to the theme's ColorScheme.primary
  final Color? color;
  /// If null, defaults to the theme's ColorScheme.onPrimary
  final Color? textColor;

  const MyButton({
    required this.onBtnPress,
    required this.text,
    required this.icon,
    this.color,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ElevatedButton.icon(
      onPressed: onBtnPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? scheme.primary,
        foregroundColor: textColor ?? scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0, // flatter look
      ),
      icon: Icon(icon, size: 24),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
