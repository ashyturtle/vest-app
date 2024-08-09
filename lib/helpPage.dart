import 'package:flutter/material.dart';
import 'package:vest1/main.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Help"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            InkWell(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              onTap: (){},
              child: Container(
                height: 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Instructions",
                    style: TextStyle(fontSize: 20),
                    ),
                    IconButton(onPressed: (){}, icon: Icon(Icons.chevron_right))
                  ],
                )
              ),
            ),
            Container(
              height: 2,
              color: MyApp.surfaceColor,              
            )
          ],
        ),
      ),
    );
  }
}
