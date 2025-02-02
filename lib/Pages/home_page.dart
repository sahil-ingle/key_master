import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:key_master/Components/my_app_bar.dart';
import 'package:key_master/Components/my_button.dart';
import 'package:key_master/Components/my_card.dart';
import 'package:key_master/Components/my_dropdown.dart';
import 'package:key_master/Components/my_textfield.dart';
import 'package:key_master/Pages/credentials_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';

// Enum to track which Add option is expanded.
enum AddOption { none, credential, category }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // Controllers for the Add Credentials form
  final TextEditingController _uniqueNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  // Controller for the Add Category field (used in the "Add" tab)
  final TextEditingController _categoryController = TextEditingController();
  // Controller for searching categories in the Home tab.
  final TextEditingController _searchController = TextEditingController();
  // Controller for entering/editing the user's name in Settings.
  final TextEditingController _nameController = TextEditingController();

  List<String> _categoryList = [];
  // List used for filtering based on search query.
  List<String> _filteredCategoryList = [];
  String? _selectedCategory;

  // This variable tracks the current tab:
  // 0 => Add Fragment, 1 => Home Fragment, 2 => Settings Fragment.
  int _selectedTabIndex = 1;

  // This variable tracks which add option is expanded.
  AddOption _selectedAddOption = AddOption.none;

  // Variable to store the user's name.
  String _myName = "";
  // Flag to toggle editing mode for the name.
  bool _isEditingName = false;

  final FlutterSecureStorage storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    loadData();
    loadName();
  }

  @override
  void dispose() {
    _uniqueNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _categoryController.dispose();
    _searchController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> loadData() async {
    try {
      final SharedPreferences pref = await SharedPreferences.getInstance();
      setState(() {
        _categoryList = pref.getStringList('category') ?? ["Personal", "Work"];
        _filteredCategoryList = List.from(_categoryList);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> loadName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _myName = pref.getString('myName') ?? "";
      // If name is empty, start in editing mode.
      _isEditingName = _myName.isEmpty;
      _nameController.text = _myName;
    });
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategoryList = _categoryList
          .where((category) =>
              category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> saveCredential(
      String uniqueName, String email, String password, String category) async {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Credential saved successfully!')),
    );
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
      _filteredCategoryList = List.from(_categoryList);
    });
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setStringList('category', _categoryList);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Category saved successfully!')),
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
      setState(() {
        _categoryList.removeAt(index);
        _filteredCategoryList = List.from(_categoryList);
      });
      final SharedPreferences pref = await SharedPreferences.getInstance();
      await pref.setStringList('category', _categoryList);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting category: $e')),
      );
    }
  }

  // Helper widget to build a card-like option for the Add tab.
  Widget _buildAddOptionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward, color: Colors.deepPurple),
        onTap: onTap,
      ),
    );
  }

  /// "Add" Fragment now shows either two option cards or the expanded form,
  /// based on which option is selected.
  Widget _buildAddFragment() {
    if (_selectedAddOption == AddOption.none) {
      // Show two option cards
      return SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildAddOptionCard("Add Credential", Icons.vpn_key, () {
              setState(() {
                _selectedAddOption = AddOption.credential;
              });
            }),
            _buildAddOptionCard("Add Category", Icons.category, () {
              setState(() {
                _selectedAddOption = AddOption.category;
              });
            }),
          ],
        ),
      );
    } else if (_selectedAddOption == AddOption.credential) {
      // Expanded view for adding credentials.
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button to return to option cards.
              ListTile(
                leading: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                title: const Text(
                  "Back",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedAddOption = AddOption.none;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Add Credentials",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              MyTextfield(
                _uniqueNameController,
                false,
                'Unique Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 10),
              MyTextfield(
                _emailController,
                false,
                'Email',
                icon: Icons.email_outlined,
              ),
              const SizedBox(height: 10),
              MyTextfield(
                _passwordController,
                true,
                'Password',
                icon: Icons.lock_outline,
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 95,
                child: MyDropdown(
                  selectedValue: _selectedCategory,
                  items: _categoryList,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  hint: 'Select Category',
                ),
              ),
              const SizedBox(height: 20),
              MyButton(
                onBtnPress: () {
                  if (_selectedCategory == null || _selectedCategory!.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a category')),
                    );
                    return;
                  }
                  saveCredential(
                    _uniqueNameController.text,
                    _emailController.text,
                    _passwordController.text,
                    _selectedCategory!,
                  );
                },
                text: 'Save Credential',
                icon: Icons.save_rounded,
              ),
            ],
          ),
        ),
      );
    } else if (_selectedAddOption == AddOption.category) {
      // Expanded view for adding a category.
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Back button to return to option cards.
              ListTile(
                leading: const Icon(Icons.arrow_back, color: Colors.deepPurple),
                title: const Text(
                  "Back",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.deepPurple,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedAddOption = AddOption.none;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Add Category",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              MyTextfield(_categoryController, false, 'Enter Category'),
              const SizedBox(height: 10),
              MyButton(
                onBtnPress: addCategory,
                text: 'Save Category',
                icon: Icons.save,
              ),
            ],
          ),
        ),
      );
    }
    return Container();
  }

  /// "Home" Fragment: Displays a search field and list of categories.
  Widget _buildHomeFragment() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: _filterCategories,
            decoration: InputDecoration(
              hintText: 'Search Categories',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: _searchController.text.isEmpty
              ? ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    if (newIndex > oldIndex) newIndex--;
                    setState(() {
                      final item = _categoryList.removeAt(oldIndex);
                      _categoryList.insert(newIndex, item);
                      _filteredCategoryList = List.from(_categoryList);
                    });
                  },
                  children: [
                    for (int index = 0; index < _categoryList.length; index++)
                      MyCard(
                        key: ValueKey(_categoryList[index]),
                        username: _categoryList[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CredentialsPage(_categoryList[index]),
                            ),
                          );
                        },
                        onIconTap: () => onDeleteIconTap(
                            context, _categoryList[index], index),
                        dragHandle: ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Icons.drag_handle,
                              color: Colors.white),
                        ),
                      ),
                  ],
                )
              : ListView.builder(
                  itemCount: _filteredCategoryList.length,
                  itemBuilder: (context, index) {
                    return MyCard(
                      key: ValueKey(_filteredCategoryList[index]),
                      username: _filteredCategoryList[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CredentialsPage(_filteredCategoryList[index]),
                          ),
                        );
                      },
                      onIconTap: () {
                        // For filtered view, reordering is disabled.
                        int actualIndex =
                            _categoryList.indexOf(_filteredCategoryList[index]);
                        onDeleteIconTap(
                            context, _filteredCategoryList[index], actualIndex);
                      },
                      dragHandle: Container(), // No drag handle when filtered.
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Builds the Name Section in Settings.

  /// "Settings" Fragment: Displays settings content.
  /// Builds the Name Section in Settings.
  Widget _buildNameSection() {
    if (_myName.isNotEmpty && !_isEditingName) {
      // Display greeting with an option to edit using a ListTile.
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.person, color: Colors.deepPurple),
        title: Text(
          "Hi, $_myName",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        trailing: TextButton(
          onPressed: () {
            setState(() {
              _isEditingName = true;
              _nameController.text = _myName;
            });
          },
          child: const Text("Edit", style: TextStyle(color: Colors.deepPurple)),
        ),
      );
    } else {
      // Show a Card-wrapped text field for entering the name.
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "My Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              MyButton(
                onBtnPress: () async {
                  final SharedPreferences pref =
                      await SharedPreferences.getInstance();
                  await pref.setString('myName', _nameController.text);
                  setState(() {
                    _myName = _nameController.text;
                    _isEditingName = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Name saved successfully!')),
                  );
                },
                text: 'Save Name',
                icon: Icons.save,
              ),
            ],
          ),
        ),
      );
    }
  }

  /// "Settings" Fragment: Displays settings content with improved Material You styling.
  /// "Settings" Fragment: Displays settings content with improved Material You styling.
  Widget _buildSettingsFragment() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header for User Settings.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "User Settings",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Wrap the name section in a Card.
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildNameSection(),
              ),
            ),
            // Header for Data Management.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Data Management",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            // Use a Card with a ListTile for the delete action, now with a confirmation dialog.
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete All Data'),
                onTap: () async {
                  // Show a confirmation dialog before deleting all data.
                  bool confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirm Deletion'),
                      content: const Text(
                          'Are you sure you want to delete all data? This action cannot be undone.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    deleteAllData();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> deleteAllData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
    await storage.deleteAll();
    setState(() {
      // Reset categories to defaults.
      _categoryList = ["Personal", "Work"];
      _filteredCategoryList = List.from(_categoryList);
      _myName = "";
      _nameController.clear();
      _isEditingName = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All data deleted successfully!')),
    );
  }

  /// Chooses which fragment to display based on the current tab.
  Widget _buildBody() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildAddFragment();
      case 1:
        return _buildHomeFragment();
      case 2:
        return _buildSettingsFragment();
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: MyAppBar(
          // Update the title to include the user's name if set.
          title: _myName.isEmpty ? "Key Master" : "Key Master - $_myName",
          isHomePage: true,
          myIcon: const Icon(Icons.settings, color: Colors.black87),
          onTap: () {
            setState(() {
              _selectedTabIndex = 2;
            });
          },
        ),
        body: _buildBody(),
        bottomNavigationBar: Builder(
          builder: (context) {
            return CircleNavBar(
              // Set a smaller overall height for the bottom navigation bar.
              height: 65,
              // Set a smaller width for the active circle.
              circleWidth: 55,
              activeIndex: _selectedTabIndex,
              activeIcons: const [
                Icon(Icons.add_box_outlined, color: Colors.white),
                Icon(Icons.home, color: Colors.white),
                Icon(Icons.settings, color: Colors.white),
              ],
              inactiveIcons: const [
                Text("Add"),
                Text("Home"),
                Text("Settings"),
              ],
              activeLevelsStyle:
                  const TextStyle(fontSize: 14, color: Colors.deepPurple),
              inactiveLevelsStyle:
                  const TextStyle(fontSize: 12, color: Colors.grey),
              color: Colors.white,
              circleColor: Colors.deepPurpleAccent.shade100,
              circleGradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 41, 128, 185),
                  Color.fromARGB(255, 109, 213, 250),
                ],
              ),
              circleShadowColor: Colors.grey,
              cornerRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
                bottomRight: Radius.circular(24),
                bottomLeft: Radius.circular(24),
              ),
              elevation: 10,
              tabCurve: Curves.easeInOut,
              iconCurve: Curves.bounceOut,
              tabDurationMillSec: 500,
              iconDurationMillSec: 300,
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              shadowColor: const Color.fromARGB(255, 188, 188, 188),
              onTap: (index) {
                setState(() {
                  _selectedTabIndex = index;
                  // Reset Add option if switching away from Add tab.
                  if (index != 0) {
                    _selectedAddOption = AddOption.none;
                  }
                });
              },
            );
          },
        ),
      ),
    );
  }
}
