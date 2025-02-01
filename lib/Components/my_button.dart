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
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(color),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        foregroundColor: WidgetStateProperty.all(Colors.blueGrey.shade800),
      ),
      icon: Icon(icon, size: 20),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }
}
