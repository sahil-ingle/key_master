import 'package:flutter/material.dart';
import 'package:key_master/Components/my_button.dart';
import 'package:key_master/Components/my_card.dart';
import 'package:key_master/Components/my_textfield.dart';
import 'package:key_master/Pages/credentials_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void saveCredential() {}

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
              child: Container(
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
                    MyButton(saveCredential, "Save")
                  ],
                ),
              ),
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
          MyCard("ex", () => onCardTap(context)),
          MyCard("username", () => onCardTap(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: showDialogBox, child: Icon(Icons.add)),
    );
  }
}
