import 'package:flutter/material.dart';
import 'package:vest1/accountInformation.dart';
import 'package:vest1/deviceSettings.dart';
import 'package:vest1/helpPage.dart';
import 'package:vest1/main.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  String name = "Jack";
  String account = "ashyjacklin@gmail.com";
  String firstInitial = 'J';
  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyApp.surfaceColor,
      child: ListView(
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.all(8),
          children: [
            Center(
              child: SizedBox(
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
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountInformation()));
              },
              child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline_rounded),
                            SizedBox(width: 8,),
                            Text(
                              "Account information",
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                    Icon(Icons.chevron_right)
                  ])),
            ),
            SizedBox(height:16),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => HelpPage()));
              },
              child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.lightbulb_outline),
                            SizedBox(width: 8,),
                            Text(
                              "Help",
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right)
                      ])),
            ),
            SizedBox(height:16),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountInformation()));
              },
              child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings_outlined),
                            SizedBox(width: 8,),
                            Text(
                              "Settings",
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right)
                      ])),
            ),
            SizedBox(height: 16,),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DeviceSettingsPage()));
              },
              child: Container(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.settings_bluetooth),
                            SizedBox(width: 8,),
                            Text(
                              "Pair your Device",
                              style: TextStyle(
                                fontWeight: FontWeight.w200,
                                fontSize: 25,
                              ),
                            ),
                          ],
                        ),
                        Icon(Icons.chevron_right)
                      ])),
            ),
          ]),
    );
  }
}
