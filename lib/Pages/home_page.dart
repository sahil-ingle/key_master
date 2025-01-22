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
  Map<String, String>? _allCredential;
  late List<String> _categoryList;
  String? selectedCategory;

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
    selectedCategory = selectedValue;
  }

  void loadData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _categoryList = pref.getStringList('category') ?? ["Personal", "Work"];
    });
  }

  void saveCredential(String uniqeName, String email, String password) async {
    Map<String, String> userCredentials = {
      'userName': uniqeName,
      'email': email,
      'password': password
    };

    storeData(uniqeName, userCredentials);
    _uniqeNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    Navigator.pop(context);
  }

  void retriveCredential() async {
    String? storedData = await storage.read(key: 'sahil333');

    if (storedData != null) {
      // Decode the JSON string back into a Map
      _allCredential = Map<String, String>.from(jsonDecode(storedData));
    }
    print(_allCredential);
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
                        selectedCategory,
                        _categoryList,
                        (String? selectedValue) {
                          setState(() {
                            onChanged(
                                selectedValue); // Update selected value and trigger rebuild
                          });
                        },
                      ),
                      MyButton(
                          () => saveCredential(_uniqeNameController.text,
                              _emailController.text, _passwordController.text),
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
          MyButton(retriveCredential, "retive data"),
          MyButton(deleteAllData, "delete data"),
          Expanded(
            child: ListView.builder(
              itemCount: _categoryList.length,
              itemBuilder: (context, index) {
                return MyCard(_categoryList[index],
                    () => onCardTap(context, _categoryList[index]));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: showDialogBox, child: Icon(Icons.add)),
    );
  }
}
