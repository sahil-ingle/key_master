import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String username;
  final Function()? onTap;
  const MyCard(this.username, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(23)),
            color: Colors.lightGreen),
        child: Text(
          username,
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
