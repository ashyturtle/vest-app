import 'package:flutter/material.dart';
import 'package:vest1/helpPage.dart';
import 'package:vest1/main.dart';
import 'package:vest1/myAccount.dart';

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
            height: 75,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 8),
                Icon(Icons.fitness_center_rounded, size: 24),
                SizedBox(width: 8,),
                Text("Fitness",
                    style: TextStyle(
                        fontSize: 24)),
              ],
            ),
          ),
          Container(
            height: 75,
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HelpPage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  Icon(Icons.lightbulb_outline, size: 24),
                  SizedBox(width: 8,),
                  Text("Help",
                      style: TextStyle(
                          fontSize: 24)),
                ],
              ),
            ),
          ),
          Container(
            height: 75,
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HelpPage()));
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 8),
                  Icon(Icons.settings, size: 24),
                  SizedBox(width: 8),
                  Text("Settings",
                      style: TextStyle(
                          fontSize: 24)),
                ],
              ),
            ),
          ),
        ]);
  }
}
