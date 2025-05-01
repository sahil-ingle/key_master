import 'package:flutter/material.dart';
import 'package:key_master/Pages/home_page.dart';
import 'package:key_master/Pages/lock_screen.dart';
import 'package:key_master/Themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LockScreen(),
      routes: {
        '/home': (context) => const HomePage(),
      },
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
