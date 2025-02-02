import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isHomePage;
  final Icon? myIcon;
  final VoidCallback onTap;

  const MyAppBar({
    required this.title,
    this.isHomePage = false,
    this.myIcon,
    this.onTap = _defaultOnTap,
    super.key,
  });

  static void _defaultOnTap() {}

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    // If not on the home page, show the provided title.
    if (!isHomePage) {
      return AppBar(
        backgroundColor: const Color(0xFF90CAF9),
        elevation: 2,
        centerTitle: true,
        toolbarHeight: preferredSize.height,
        title: Text(
          title,
          style: TextStyle(
            fontSize: 24,
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
            : [],
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

    // On the home page, use FutureBuilder to fetch the name.
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        String displayTitle = "Hello, welcome!";
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final prefs = snapshot.data;
          final name = prefs!.getString('myName') ?? "";
          if (name.isNotEmpty) {
            displayTitle = "Hello, $name!";
          }
        }
        return AppBar(
          backgroundColor: const Color(0xFF90CAF9),
          elevation: 2,
          centerTitle: true,
          toolbarHeight: preferredSize.height,
          title: Text(
            displayTitle,
            style: TextStyle(
              fontSize: 24,
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
              : [],
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
      },
    );
  }
}
