import 'package:flutter/material.dart';

import 'main.dart';

class MyAccount extends StatelessWidget {
  const MyAccount({super.key});

  @override
  Widget build(BuildContext context) {
    String name = "Jack";
    String account = "ashyjacklin@gmail.com";
    String firstInitial = name[0];
    return Scaffold(
        appBar: AppBar(title: Text("My Account")),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.start, children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      //decoration: BoxDecoration(
                      //shape: BoxShape.circle),
                      child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50)),
                          margin: EdgeInsets.all(0),
                          child: Center(
                            child: Text(firstInitial,
                                style: TextStyle(
                                  fontSize: 50,
                                )),
                          )),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                    child: Text(account,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w100,
                        ))),
              ]),
              SizedBox(
                height: 5,
              ),
              Container(
                height: 2,
                color: MyApp.surfaceColor,
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyAccount()));
                },
                child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Text(
                        "Account information",
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 25,
                        ),
                      ),
                      Icon(Icons.chevron_right)
                    ])),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyAccount()));
                },
                child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Text(
                        "Add an another account",
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 25,
                        ),
                      ),
                      Icon(Icons.chevron_right)
                    ])),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyAccount()));
                },
                child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Text(
                        "Recent activities",
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 25,
                        ),
                      ),
                      Icon(Icons.chevron_right)
                    ])),
              ),
              SizedBox(height: 20),
              InkWell(
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyAccount()));
                },
                child: Container(
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                      Text(
                        "Friends",
                        style: TextStyle(
                          fontWeight: FontWeight.w200,
                          fontSize: 25,
                        ),
                      ),
                      Icon(Icons.chevron_right)
                    ])),
              ),
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => MyAccount()));
                    },
                    child: Container(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Log out",
                                style: TextStyle(
                                  fontWeight: FontWeight.w200,
                                  fontSize: 25,
                                ),
                              ),
                              Icon(Icons.chevron_right)
                            ])),
                  )
            ])));
  }
}
