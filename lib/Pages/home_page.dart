import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:key_master/Components/my_app_bar.dart';
import 'package:key_master/Components/my_button.dart';
import 'package:key_master/Components/my_card.dart';
import 'package:key_master/Components/my_dropdown.dart';
import 'package:key_master/Components/my_textfield.dart';
import 'package:key_master/Pages/credentials_page.dart';
import 'package:key_master/Pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final TextEditingController _uniqueNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  List<String> _categoryList = [];
  String? _selectedCategory;

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  void dispose() {
    _uniqueNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        _categoryList = pref.getStringList('category') ?? ["Personal", "Work"];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> saveCredential(
    String uniqueName,
    String email,
    String password,
    String category,
  ) async {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    final String? existingEntry = await storage.read(key: uniqueName);
    if (existingEntry != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This unique name already exists')),
      );
      return;
    }

    final Map<String, String> userCredentials = {
      'userName': uniqueName,
      'email': email,
      'password': password,
      'category': category,
    };

    await storage.write(key: uniqueName, value: jsonEncode(userCredentials));
    _uniqueNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    if (mounted) Navigator.pop(context);
  }

  void addCategory() async {
    if (_categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name cannot be empty')),
      );
      return;
    }

    setState(() {
      _categoryList.add(_categoryController.text);
      _selectedCategory = _categoryController.text;
      _categoryController.clear();
    });

    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setStringList('category', _categoryList);
    if (mounted) Navigator.pop(context);
  }

  void addCategoryBtn() {
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        child: StatefulBuilder(
          builder: (context, setState) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Enter Category", style: TextStyle(fontSize: 20)),
                const SizedBox(height: 20),
                MyTextfield(_categoryController, false, 'Enter Category'),
                const SizedBox(height: 20),
                MyButton(
                  onBtnPress: addCategory,
                  text: 'Save',
                  icon: Icons.save_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onDeleteIconTap(
      BuildContext context, String categoryName, int index) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete all credentials in "$categoryName" category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final Map<String, String> allData = await storage.readAll();
      final List<String> keysToDelete = [];

      for (String key in allData.keys) {
        final String? jsonString = allData[key];
        if (jsonString != null) {
          final Map<String, dynamic> credentials = jsonDecode(jsonString);
          if (credentials['category'] == categoryName) {
            keysToDelete.add(key);
          }
        }
      }

      for (String key in keysToDelete) {
        await storage.delete(key: key);
      }

      if (mounted) {
        setState(() => _categoryList.removeAt(index));
        final SharedPreferences pref = await SharedPreferences.getInstance();
        await pref.setStringList('category', _categoryList);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting category: $e')),
        );
      }
    }
  }

  void showDialogBox() {
    showDialog(
      context: context,
      builder: (BuildContext context) => Theme(
        data: Theme.of(context).copyWith(
          dialogTheme: DialogTheme(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        child: Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Container(
              constraints: const BoxConstraints(minWidth: 300),
              child: StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter Credentials",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    MyTextfield(
                      _uniqueNameController,
                      false,
                      "Unique Name",
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 2),
                    MyTextfield(
                      _emailController,
                      false,
                      'Email',
                      icon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 2),
                    MyTextfield(
                      _passwordController,
                      true,
                      'Password',
                      icon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 5),
                    SizedBox(
                      height: 95,
                      child: MyDropdown(
                        selectedValue: _selectedCategory,
                        items: _categoryList,
                        onChanged: (String? value) =>
                            setState(() => _selectedCategory = value),
                        hint: 'Select Category',
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () {
                              _uniqueNameController.clear();
                              _emailController.clear();
                              _passwordController.clear();
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancel",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          MyButton(
                            onBtnPress: () => saveCredential(
                              _uniqueNameController.text,
                              _emailController.text,
                              _passwordController.text,
                              _selectedCategory!,
                            ),
                            text: 'Save',
                            color: Colors.blue.shade100,
                            textColor: Colors.blue.shade800,
                            icon: Icons.save_rounded,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Add back the missing methods
  Future<void> deleteAllData() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Delete ALL credentials and categories?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await storage.deleteAll();
      setState(() {
        _categoryList = ["Personal", "Work"]; // Reset to default
      });
      final SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setStringList('category', _categoryList);
    }
  }

// Update the build method
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: MyAppBar(
            title: "Key Master",
            myIcon: const Icon(Icons.settings, color: Colors.black87),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      icon: const Icon(Icons.add_box_outlined),
                      label: const Text("Add Category"),
                      onPressed: addCategoryBtn,
                    ),
                    MyButton(
                      onBtnPress: deleteAllData,
                      text: 'Clear All',
                      icon: Icons.delete_forever,
                      color: Colors.red.shade100,
                      textColor: Colors.red.shade800,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _categoryList.isEmpty
                    ? Center(
                        child: Text(
                          'No categories found. Add a new category!',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                    : ReorderableListView(
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          setState(() {
                            final item = _categoryList.removeAt(oldIndex);
                            _categoryList.insert(newIndex, item);
                          });
                        },
                        children: [
                          for (int index = 0;
                              index < _categoryList.length;
                              index++)
                            MyCard(
                              key: ValueKey(_categoryList[index]),
                              username: _categoryList[index],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CredentialsPage(_categoryList[index]),
                                ),
                              ),
                              onIconTap: () => onDeleteIconTap(
                                  context, _categoryList[index], index),
                              dragHandle: ReorderableDragStartListener(
                                index: index,
                                child: const Icon(Icons.drag_handle,
                                    color: Colors.white),
                              ),
                            ),
                        ],
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: showDialogBox,
            backgroundColor: const Color(0xFF90CAF9),
            foregroundColor: Colors.grey.shade800,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFF90CAF9), width: 1.5),
            ),
            child: const Icon(Icons.add_rounded, size: 28),
          ),
        ));
  }
}
