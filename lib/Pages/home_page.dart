import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:key_master/Components/my_back_button.dart';
import 'package:key_master/Components/my_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Components/my_app_bar.dart';
import '../Components/my_button.dart';
import '../Components/my_card.dart';
import '../Components/my_dropdown.dart';
import '../Components/my_textfield.dart';
import '../Pages/credentials_page.dart';

enum AddOption { none, credential, category }

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
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  List<String> _categoryList = [];
  List<String> _filteredCategoryList = [];
  String? _selectedCategory;

  int _selectedTabIndex = 1;
  AddOption _selectedAddOption = AddOption.none;
  String _myName = "";
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

  Future<void> exportAppData() async {
    try {
      final Map<String, String> credentialsData = await storage.readAll();
      List<Map<String, dynamic>> credentials = [];
      credentialsData.forEach((key, value) {
        credentials.add(jsonDecode(value));
      });

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> categories = prefs.getStringList('category') ?? ["Personal", "Work"];
      String userName = prefs.getString('myName') ?? "";

      Map<String, dynamic> appData = {
        "credentials": credentials,
        "categories": categories,
        "userName": userName,
      };

      String jsonData = jsonEncode(appData);
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory == null) return;
      
      String filePath = '$selectedDirectory/app_data_export.json';
      await File(filePath).writeAsString(jsonData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('App data exported to $filePath'),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting app data: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> importAppDataFromFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(

      );
      if (result != null && result.files.single.path != null) {
        String filePath = result.files.single.path!;
        String jsonData = await File(filePath).readAsString();
        await importAppData(jsonData);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing app data: $e'),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    }
  }

  Future<void> importAppData(String jsonData) async {
    try {
      Map<String, dynamic> appData = jsonDecode(jsonData);

      if (appData.containsKey('credentials')) {
        for (var cred in appData['credentials']) {
          String uniqueName = cred['userName'];
          await storage.write(key: uniqueName, value: jsonEncode(cred));
        }
      }

      if (appData.containsKey('categories')) {
        List<String> categoryList = (appData['categories'] as List).cast<String>();
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setStringList('category', categoryList);
        setState(() {
          _categoryList = categoryList;
          _filteredCategoryList = List.from(categoryList);
        });
      }

      if (appData.containsKey('userName')) {
        String importedName = appData['userName'];
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('myName', importedName);
        setState(() {
          _myName = importedName;
          _nameController.text = importedName;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('App data imported successfully'),
          backgroundColor: Theme.of(context).colorScheme.surface,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error importing app data: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
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
        SnackBar(
          content: Text('Error loading categories: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> loadName() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _myName = pref.getString('myName') ?? "";
      _isEditingName = _myName.isEmpty;
      _nameController.text = _myName;
    });
  }

  void _filterCategories(String query) {
    setState(() {
      _filteredCategoryList = _categoryList
          .where((category) => category.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> saveCredential(String uniqueName, String email, String password, String category) async {
    if (_selectedCategory == null || _selectedCategory!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a category'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }
    
    final String? existingEntry = await storage.read(key: uniqueName);
    if (existingEntry != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This unique name already exists'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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
      SnackBar(
        content: const Text('Credential saved successfully!'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  void addCategory() async {
    if (_categoryController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Category name cannot be empty'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
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
      SnackBar(
        content: const Text('Category saved successfully!'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Future<void> onDeleteIconTap(BuildContext context, String categoryName, int index) async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Delete', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text('Delete all credentials in "$categoryName" category?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
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
        SnackBar(
          content: Text('Error deleting category: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Widget _buildAddOptionCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.secondary,
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.onSecondary),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSecondary,
          ),
        ),
        trailing: Icon(Icons.arrow_forward, color: Theme.of(context).colorScheme.onSecondary),
        onTap: onTap,
      ),
    );
  }

  Widget _buildAddFragment() {
    if (_selectedAddOption == AddOption.none) {
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
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [    
                  MyBackButton(onBack: () {
                    setState(() {
                      _selectedAddOption = AddOption.none;
                    });
                  }),
              
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
                      SnackBar(
                        content: const Text('Please select a category'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
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
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.primary),
                title: Text(
                  "Back",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedAddOption = AddOption.none;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                "Add Category",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
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
              hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              prefixIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.onSurface),
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary.withOpacity(0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
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
                              builder: (context) => CredentialsPage(_categoryList[index]),
                            ),
                          );
                        },
                        onIconTap: () => onDeleteIconTap(context, _categoryList[index], index),
                        dragHandle: ReorderableDragStartListener(
                          index: index,
                          child: Icon(Icons.drag_handle, color: Theme.of(context).colorScheme.onPrimary),
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
                            builder: (context) => CredentialsPage(_filteredCategoryList[index]),
                          ),
                        );
                      },
                      onIconTap: () {
                        int actualIndex = _categoryList.indexOf(_filteredCategoryList[index]);
                        onDeleteIconTap(context, _filteredCategoryList[index], actualIndex);
                      },
                      dragHandle: Container(),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildNameSection() {
    if (_myName.isNotEmpty && !_isEditingName) {
      return ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
        title: Text(
          "Hi, $_myName",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
        ),
        trailing: TextButton(
          onPressed: () {
            setState(() {
              _isEditingName = true;
              _nameController.text = _myName;
            });
          },
          child: Text(
            "Edit",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
      );
    } else {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        color: Theme.of(context).colorScheme.surface,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _nameController,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: "My Name",
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              MyButton(
                onBtnPress: () async {
                  final SharedPreferences pref = await SharedPreferences.getInstance();
                  await pref.setString('myName', _nameController.text);
                  setState(() {
                    _myName = _nameController.text;
                    _isEditingName = false;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Name saved successfully!'),
                      backgroundColor: Theme.of(context).colorScheme.surface,
                    ),
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

  Widget _buildSettingsFragment() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "User Settings",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surface,
              margin: const EdgeInsets.only(bottom: 20),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildNameSection(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                "Data Management",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.file_download, color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'Export App Data',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    onTap: exportAppData,
                  ),
                  ListTile(
                    leading: Icon(Icons.file_upload, color: Theme.of(context).colorScheme.primary),
                    title: Text(
                      'Import App Data',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    onTap: importAppDataFromFile,
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error),
                    title: Text(
                      'Delete All Data',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    ),
                    onTap: () async {
                      bool confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            'Confirm Deletion',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          content: Text(
                            'Are you sure you want to delete all data? This action cannot be undone.',
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                          ),
                          backgroundColor: Theme.of(context).colorScheme.surface,
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text(
                                'Delete',
                                style: TextStyle(color: Theme.of(context).colorScheme.error),
                              ),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        deleteAllData();
                      }
                    },
                  ),
                ],
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
      _categoryList = ["Personal", "Work"];
      _filteredCategoryList = List.from(_categoryList);
      _myName = "";
      _nameController.clear();
      _isEditingName = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('All data deleted successfully!'),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  Widget _buildBody(int selectedTabIndex) {
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
          title: _myName.isEmpty ? "Key Master" : "Key Master - $_myName",
          isHomePage: true,
          myIcon: Icon(Icons.settings, color: Theme.of(context).colorScheme.onSurface),
          onTap: () {
            setState(() {
              _selectedTabIndex = 2;
            });
          },
        ),
        body: _buildBody(_selectedTabIndex),
        bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: MyNavBar(
            selectedIndex: _selectedTabIndex,
            badgeCounts: null,  // or [count1, count2, count3] if you want badges
            onTabChange: (index) {
              setState(() {
                _selectedTabIndex = index;
                if (index != 0) _selectedAddOption = AddOption.none;
              });
            },
          ),
        ),
      ),
      ),
    );
  }
}