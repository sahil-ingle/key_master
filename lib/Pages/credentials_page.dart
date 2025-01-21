import 'package:flutter/material.dart';
import 'package:key_master/Components/my_card.dart';

class CredentialsPage extends StatefulWidget {
  final String title;
  const CredentialsPage(this.title, {super.key});

  @override
  State<CredentialsPage> createState() => _CredentialsPageState();
}

class _CredentialsPageState extends State<CredentialsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          MyCard("ex", () {}),
        ],
      ),
    );
  }
}
