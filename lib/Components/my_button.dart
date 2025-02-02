import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final Function()? onBtnPress;
  final IconData icon;
  final Color color;
  final Color textColor;

  const MyButton({
    required this.onBtnPress,
    required this.text,
    this.textColor = Colors.white,
    super.key,
    required this.icon,
    this.color = const Color(0xFF90CAF9),
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onBtnPress,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0, // Material You typically favors a flatter look
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
