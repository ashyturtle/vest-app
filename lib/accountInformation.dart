import 'package:flutter/material.dart';
class AccountInformation extends StatelessWidget {
  const AccountInformation({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title:Text("Account information")),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Full Name",
            style: TextStyle(fontSize: 36),
            ),
            Container(
              height: 75,
              child: Card(
                child: Text("Someone Someoneyian",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 3,
                      color: Colors.white,
                      fontSize: 24
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text("Registered Email",
            style: TextStyle(fontSize: 36)),
            Container(
              height: 75,
              child: Card(
                child: Text("someone@gmail.com",
                style: TextStyle(fontSize: 24,
                height:3,
                color: Colors.white),
                textAlign: TextAlign.center)
              )
            ),
            SizedBox(height: 10),
            Text("Registered Device ID",
                style: TextStyle(fontSize: 36)),
            Container(
                height: 75,
                child: Card(
                    child: Text("Registered Device ID",
                        style: TextStyle(fontSize: 24,
                            height:3,
                            color: Colors.white),
                        textAlign: TextAlign.center)
                )
            ),
            SizedBox(height: 10),
            Text("Date of Birth",
                style: TextStyle(fontSize: 36)),
            Container(
                height: 75,
                child: Card(
                    child: Text("Birthda",
                        style: TextStyle(fontSize: 24,
                            height:3,
                            color: Colors.white),
                        textAlign: TextAlign.center)
                )
            ),

          ],
        ),
      ),
    );
  }
}
