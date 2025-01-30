import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:key_master/Components/my_button.dart';
import 'package:key_master/Components/my_card.dart';
import 'package:key_master/Components/my_dropdown.dart';
import 'package:key_master/Components/my_textfield.dart';
import 'package:key_master/Pages/credentials_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _uniqeNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  late List<String> _categoryList;
  String? _selectedCategory;

  @override
  void initState() {
    loadData();
    super.initState();
  }

  final storage = FlutterSecureStorage();

  void storeData(String uniqeName, Map<String, String> userCredentials) async {
    String jsonString = jsonEncode(userCredentials);
    await storage.write(key: uniqeName, value: jsonString);
  }

  void onChanged(String? selectedValue) {
    _selectedCategory = selectedValue!;
  }

  void loadData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _categoryList = pref.getStringList('category') ?? ["Personal", "Work"];
    });
  }

  void saveCredential(
      String uniqeName, String email, String password, String category) async {
    Map<String, String> userCredentials = {
      'userName': uniqeName,
      'email': email,
      'password': password,
      'category': category
    };

    storeData(uniqeName, userCredentials);
    _uniqeNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    Navigator.pop(context);
  }

  void deleteAllData() async {
    await storage.deleteAll();
  }

  void addCategory() async {
    setState(() {
      _categoryList.add(_categoryController.text);
      _categoryController.clear();
    });

    Navigator.pop(context);
    final SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setStringList('category', _categoryList);
  }

  void addCategoryBtn() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(child:
                StatefulBuilder(builder: (BuildContext context, setState) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter Category",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    MyTextfield(_categoryController, false, 'Enter Category'),
                    SizedBox(
                      height: 20,
                    ),
                    MyButton(addCategory, "Save")
                  ],
                ),
              );
            })));
  }

  Future onCardTap(BuildContext context, String title) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CredentialsPage(title)),
    );
  }

  void onDeleteIconTap(context, String categoryName, int index) async {
    try {
      Map<String, String> allData = await storage.readAll();

      for (String key in allData.keys) {
        String? jsonString = allData[key];
        if (jsonString != null) {
          Map<String, dynamic> credentials = jsonDecode(jsonString);
          if (credentials['category'] == categoryName) {
            setState(() {
              storage.delete(key: key);
            });
          }
        }
      }

      setState(() {
        _categoryList.removeAt(index);
      });
    } catch (e) {
      // Handle errors (e.g., log or show a message)
      print('Error loading usernames: $e');
    }
  }

  void showDialogBox() {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              child: StatefulBuilder(builder: (BuildContext context, setState) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Enter Credentials",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      MyTextfield(_uniqeNameController, false, "Uniqe Name"),
                      MyTextfield(_emailController, false, 'Email'),
                      MyTextfield(_passwordController, true, 'Password'),
                      SizedBox(
                        height: 20,
                      ),
                      MyDropdown(
                        _selectedCategory,
                        _categoryList,
                        (String? selectedValue) {
                          setState(() {
                            onChanged(
                                selectedValue); // Update selected value and trigger rebuild
                          });
                        },
                      ),
                      MyButton(
                          () => saveCredential(
                              _uniqeNameController.text,
                              _emailController.text,
                              _passwordController.text,
                              _selectedCategory!),
                          "Save")
                    ],
                  ),
                );
              }),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Key Master",
          textAlign: TextAlign.center,
        ),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: addCategoryBtn,
            child: Text(
              "Add category",
              style: TextStyle(fontSize: 20),
            ),
          ),
          MyButton(deleteAllData, "delete data"),
          Expanded(
            child: ReorderableListView(
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex)
                    newIndex--; // Adjust for list shifting
                  final item = _categoryList.removeAt(oldIndex);
                  _categoryList.insert(newIndex, item);
                });
              },
              children: [
                for (int index = 0; index < _categoryList.length; index++)
                  MyCard(
                    key: ValueKey(
                        _categoryList[index]), // Required for reorderable list
                    username: _categoryList[index],
                    onTap: () => onCardTap(context, _categoryList[index]),
                    onIconTap: () =>
                        onDeleteIconTap(context, _categoryList[index], index),
                    dragHandle: ReorderableDragStartListener(
                      index: index,
                      child: Icon(Icons.drag_handle, color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: showDialogBox, child: Icon(Icons.add)),
    );
  }
}
