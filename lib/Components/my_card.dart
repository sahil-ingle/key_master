import 'package:flutter/material.dart';

class MyCard extends StatelessWidget {
  final String username;
  final Function()? onTap;
  final Function()? onIconTap;
  final Widget? dragHandle;
  const MyCard(
      {required this.username,
      required this.onTap,
      required this.onIconTap,
      this.dragHandle,
      super.key});

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              username,
              style: TextStyle(fontSize: 20),
            ),
            Container(
                child: Row(
              children: [
                GestureDetector(
                    onTap: onIconTap,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                    )),
                SizedBox(
                  width: 10,
                ),
                if (dragHandle != null) dragHandle!,
              ],
            )),
          ],
        ),
      ),
    );
  }
}
