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
    final scheme = Theme.of(context).colorScheme;

    Widget buildAppBarContent(String displayTitle) {
      return AppBar(
        // Make the bar itself transparent so our gradient shows through
        backgroundColor: Colors.transparent,                      // :contentReference[oaicite:3]{index=3}
        elevation: 0,
        centerTitle: true,
        toolbarHeight: preferredSize.height,
        // Place gradient behind all AppBar content
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.secondary,                                // start with secondary :contentReference[oaicite:4]{index=4}
                scheme.primary,                                  // end at primary :contentReference[oaicite:5]{index=5}
              ],
              begin: Alignment.centerLeft,                      // horizontal gradient :contentReference[oaicite:6]{index=6}
              end: Alignment.centerRight,
            ),
          ),
        ),
        title: Text(
          displayTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.onPrimaryContainer,                // contrasts with container :contentReference[oaicite:7]{index=7}
                fontWeight: FontWeight.w600,
              ),
        ),
        actions: isHomePage || myIcon == null
            ? null
            : [
                IconButton(
                  icon: myIcon!,
                  tooltip: 'Settings',
                  onPressed: onTap,
                  color: scheme.onPrimaryContainer,              // icon color matches text :contentReference[oaicite:8]{index=8}
                ),
              ],
      );
    }

    if (!isHomePage) {
      // Regular page: show provided title immediately
      return buildAppBarContent(title);
    }

    // Home page: load name from SharedPreferences
    return FutureBuilder<SharedPreferences>(
      future: SharedPreferences.getInstance(),
      builder: (context, snapshot) {
        String displayTitle = "Welcome!";
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          final prefs = snapshot.data!;
          final name = prefs.getString('myName') ?? "";
          if (name.isNotEmpty) {
            displayTitle = "Hi, $name!";
          }
        }
        return buildAppBarContent(displayTitle);
      },
    );
  }
}
