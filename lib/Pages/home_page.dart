import 'package:flutter/material.dart';
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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  late List<String> _categoryList;
  String? selectedCategory;

  @override
  void initState() {
    loadData();
    super.initState();
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

  void saveCredential() {}

  void addCategory() async {
    _categoryList.add(_categoryController.text);
    _categoryController.clear();
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

  Future onCardTap(BuildContext context) {
    return Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CredentialsPage("Credentials Page Title")),
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
                      MyButton(saveCredential, "Save")
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
        children: [
          GestureDetector(
            onTap: addCategoryBtn,
            child: Text(
              "Add category",
              style: TextStyle(fontSize: 20),
            ),
          ),
          Column(
            children: [
              MyCard("ex", () => onCardTap(context)),
              MyCard("username", () => onCardTap(context)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: showDialogBox, child: Icon(Icons.add)),
    );
  }
}
