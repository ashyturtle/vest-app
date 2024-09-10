import "package:flutter/material.dart";


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InkWell(
               onTap: (){//Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
                  },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),//why doesn't it work
                      ),
                      child: Card(
                    ),
                    ),
                    Container(
                      child: Text("Connected",
                      style: TextStyle(fontSize: 40)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width:100,
                height:10,
                child: Card(),
              ),
              InkWell(
                onTap: (){//Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),//why doesn't it work
                      ),
                      child: Card(
                      ),
                    ),
                    Container(
                      child: Text("Battery",
                          style: TextStyle(fontSize: 40)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width:100,
                height:10,
                child: Card(),
              ),
              InkWell(
                onTap: (){//Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),//why doesn't it work
                      ),
                      child: Card(
                      ),
                    ),
                    Container(
                      child: Text("Vibration Patterns",
                          style: TextStyle(fontSize: 29.
                          )),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width:100,
                height:10,
                child: Card(),
              ),
              InkWell(
                onTap: (){//Navigator.push(context, MaterialPageRoute(builder: (context) => HelpPage()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),//why doesn't it work
                      ),
                      child: Card(
                      ),
                    ),
                    Container(
                      child: Text("Updates",
                          style: TextStyle(fontSize: 40)),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                width:100,
                height:10,
                child: Card(),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
