import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final String text;
  final void Function()? onBtnPress;
  const MyButton(this.onBtnPress, this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onBtnPress,
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(Colors.blueAccent)),
      label: Text(
        text,
        style: TextStyle(color: Colors.white),
      ),
      icon: Icon(
        Icons.save,
        color: Colors.white,
      ),
    );
  }
}
