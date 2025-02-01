import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:key_master/Components/credential_card.dart';
import 'package:key_master/Components/my_app_bar.dart';
//import 'package:key_master/Components/my_card.dart';

class CredentialsPage extends StatefulWidget {
  final String title;
  const CredentialsPage(this.title, {super.key});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  final storage = FlutterSecureStorage();
  // ignore: unused_field
  List<String> _usernames = [];
  Map<String, String>? _allCredential;

  @override
  void initState() {
    getUserNameList(widget.title);
    super.initState();
  }

  void onTap(context, String userName) async {
    try {
      String? email;
      String? password;

      String? storedData = await storage.read(key: userName);
      if (storedData != null) {
        // Decode the JSON string back into a Map
        _allCredential = Map<String, String>.from(jsonDecode(storedData));
        email = _allCredential?['email'];
        password = _allCredential?['password'];
      }

      showDialogBox(userName, email, password);
    } catch (e) {
      // Handle errors (e.g., log or show a message)
      print('Error loading usernames: $e');
    }
  }

  void showDialogBox(String userName, String? email, String? password) {
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
                        "Your Credentials",
                        style: TextStyle(fontSize: 20),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(userName),
                      SizedBox(
                        height: 20,
                      ),
                      Text(email!),
                      Text(password!),
                    ],
                  ),
                );
              }),
            ));
  }

  void getUserNameList(String categoryName) async {
    try {
      Map<String, String> allData = await storage.readAll();
      List<String> usernames = [];

      for (String key in allData.keys) {
        String? jsonString = allData[key];
        if (jsonString != null) {
          Map<String, dynamic> credentials = jsonDecode(jsonString);
          if (credentials.containsKey('userName') &&
              credentials['category'] == categoryName) {
            usernames.add(credentials['userName']);
          }
        }
      }

      setState(() {
        _usernames = usernames;
      });
    } catch (e) {
      // Handle errors (e.g., log or show a message)
      print('Error loading usernames: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(title: widget.title),
      body: ListView.builder(
        itemCount: _usernames.length,
        itemBuilder: (context, index) {
          return CredentialCard(
            username: _usernames[index],
            onTap: () => onTap(context, _usernames[index]),
            onIconTap: () {},
          );
        },
      ),
    );
  }
}
