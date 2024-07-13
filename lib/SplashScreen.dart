import 'package:flutter/material.dart';


class Splashscreen extends StatelessWidget {
  const Splashscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Vest',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w200,
                color: Colors.white
              ),

            ),
            Container(
                height: 100,
                width: 200,
                child: Card(
                  child: Center(child: Text("Something"))
                ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.pop(context);
        },
        child: Icon(Icons.navigate_next),),
    );
  }
}
