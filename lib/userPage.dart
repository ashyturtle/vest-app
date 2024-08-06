import 'package:flutter/material.dart';
import 'package:vest1/main.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    return ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(8),
        children: [
          Container(
            height: 150,
            child: Card(
              color: MyApp.accentColor,
              child: Center(
                child: Text(
                  "My Account",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              //Icon()
            ),
          ),
          Container(
            height: 150,
            child: Card(
              color: MyApp.accentColor,
              child: Center(child: Text("My Account")),
            ),
          ),
          Container(
            height: 150,
            child: Card(
              color: MyApp.accentColor,
              child: Center(
                child: Text("Something"),
              ),
            ),
          ),
          Container(
            height: 150,
            child: Card(
              color: MyApp.accentColor,
              child: Center(
                child: Text("Settings"),
              ),
            ),
          ),
        ]);
  }
}
