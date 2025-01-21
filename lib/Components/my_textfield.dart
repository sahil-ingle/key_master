import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final TextEditingController controller;
  final bool obsureText;
  final String hint;

  const MyTextfield(this.controller, this.obsureText, this.hint, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(5),
      child: TextField(
        controller: controller,
        obscureText: obsureText,
        decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                borderSide: BorderSide(color: Colors.black)),
            hintText: hint),
      ),
    );
  }
}
