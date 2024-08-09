import 'package:flutter/material.dart';
import 'package:vest1/helpPage.dart';
import 'package:vest1/main.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Color C = Colors.blue;
  @override
  Widget build(BuildContext context) {
    return ListView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(8),
        children: [
          Container(
            height: 150,
            child: InkWell(
              onTap:(){
                setState(() {
                });
              },
            child: Card(
              color: MyApp.accentColor,
              child: Row(
                children:[
                  SizedBox(width:8),
                  Icon(Icons.person, size:30),
                  Text(
                    "My Account",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize:30,
                    ),
                  ),
                ]
              ),
            ),
          ),
          ),

          Container(
            height: 150,
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width:8),
                  Icon(Icons.fitness_center_rounded, size:30),
                  Text("Fitness",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 30)
                  ),
                ],
              ),
              color: MyApp.accentColor,
            ),
          ),
          Container(
            height: 150,
            child: InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
              },
              child: Card(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width:8),
                    Icon(Icons.lightbulb_outline, size:30),
                    Text("Help",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                            fontSize: 30)
                    ),
                  ],
                ),
                color: MyApp.accentColor,
              ),
            ),
          ),
          Container(
            height: 150,
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width:8),
                  Icon(Icons.settings, size:30),
                  Text("Settings",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          fontSize: 30)
                  ),
                ],
              ),
              color: MyApp.accentColor,
            ),
          ),


        ]);
  }
}
