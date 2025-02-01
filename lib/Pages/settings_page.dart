import 'package:flutter/material.dart';
import 'package:key_master/Components/my_app_bar.dart';
import 'package:key_master/Components/my_button.dart';
import 'package:key_master/Components/my_textfield.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final TextEditingController _categoryController = TextEditingController();
  late List<String> _categoryList;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: "Work in progress"),
      body: Column(
        children: [
          GestureDetector(
              onTap: addCategoryBtn,
              child: Text("click me, might break the app"))
        ],
      ),
    );
  }

  @override
  void initState() {
    loadData();
    super.initState();
  }

  void loadData() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      _categoryList = pref.getStringList('category') ?? ["Personal", "Work"];
    });
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
                    MyButton(
                      onBtnPress: addCategory,
                      text: 'Save',
                      icon: Icons.save_rounded,
                    )
                  ],
                ),
              );
            })));
  }
}
