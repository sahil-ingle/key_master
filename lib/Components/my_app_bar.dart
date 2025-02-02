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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use a background color that adapts based on Material You dynamic colors.
    final backgroundColor = colorScheme.primaryContainer;
    // Use a text color that contrasts with the primary container.
    final textStyle = theme.textTheme.titleLarge?.copyWith(
      color: colorScheme.onPrimaryContainer,
      fontWeight: FontWeight.w600,
    );

    // If not on the home page, display the provided title.
    if (!isHomePage) {
      return AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: preferredSize.height,
        title: Text(
          title,
          style: textStyle,
        ),
        actions: myIcon != null
            ? [
                IconButton(
                  icon: myIcon!,
                  tooltip: 'Settings',
                  onPressed: onTap,
                ),
              ]
            : null,
      );
    }

    // On the home page, use FutureBuilder to fetch the user's name.
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
          backgroundColor: backgroundColor,
          elevation: 0,
          toolbarHeight: preferredSize.height,
          title: Text(
            displayTitle,
            style: textStyle,
          ),
        );
      },
    );
  }
}
