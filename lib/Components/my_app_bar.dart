import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Icon? myIcon;
  final VoidCallback onTap; // No need for nullable

  const MyAppBar({
    required this.title,
    this.myIcon,
    this.onTap = _defaultOnTap, // Default empty function
    super.key,
  });

  static void _defaultOnTap() {} // Empty function to avoid null issues

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF90CAF9),
      elevation: 2,
      centerTitle: true,
      toolbarHeight: 60,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade900,
          letterSpacing: 0.5,
        ),
      ),
      actions: myIcon != null
          ? [
              IconButton(
                icon: myIcon!,
                tooltip: 'Settings',
                onPressed: onTap,
              ),
            ]
          : [], // Empty list instead of null to avoid layout issues
      iconTheme: IconThemeData(
        color: Colors.grey.shade900,
        size: 25,
      ),
      actionsIconTheme: IconThemeData(
        color: Colors.grey.shade900,
        size: 25,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(10),
        ),
      ),
    );
  }
}
