import "package:flutter/material.dart";
import "package:vest1/main.dart";


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isConnected = true;
  double batteryPercentage = 0.67;
  final List<String> vibrationPatterns = [
    'Pattern 1',
    'Pattern 2',
    'Pattern 3',
    'Pattern 4',
    'Pattern 5',
  ];

  // Variables to store selected IDs for each category
  String? leftRightProximityAlertID;
  String? navigationAlertID;
  String? crashDetectionAlertID;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyApp.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.count(
            primary: false,

            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              InkWell(
                onTap: (){
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 500,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text('Modal BottomSheet'),
                              ElevatedButton(
                                child: const Text('Close BottomSheet'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Connection",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,

                            ),
                            ),
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: MyApp.accentColor),
                              width: 40,
                              height: 40,
                              child: isConnected ? Icon(Icons.signal_cellular_alt): Icon(Icons.signal_cellular_null),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Device Name",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18
                                ),
                            ),
                            Text("12:00",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24
                            ),)

                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: (){
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 500,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text('Modal BottomSheet'),
                              ElevatedButton(
                                child: const Text('Close BottomSheet'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Battery",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,

                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: MyApp.accentColor),
                              width: 40,
                              height: 40,
                              child: Builder(builder: (context) {
                                if(batteryPercentage > .85){
                                  return Icon(Icons.battery_full);
                                }else if(batteryPercentage > .70){
                                  return Icon(Icons.battery_5_bar);
                                }else if(batteryPercentage > .50){
                                  return Icon(Icons.battery_4_bar);
                                }else if(batteryPercentage > .30){
                                  return Icon(Icons.battery_3_bar);
                                }else if(batteryPercentage > .15){
                                  return Icon(Icons.battery_2_bar);
                                }else{
                                  return Icon(Icons.battery_1_bar);
                                }
                              }),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Time Remaining",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18
                              ),
                            ),
                            Text("5 Hours",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24
                              ),)

                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
        InkWell(
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Vibration\n Pattern",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: MyApp.accentColor,
                        ),
                        width: 40,
                        height: 40,
                        child: Icon(Icons.vibration),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Left/Right Proximity Alert: ${leftRightProximityAlertID ?? "Not Set"}",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "Navigation Alert: ${navigationAlertID ?? "Not Set"}",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      Text(
                        "Crash Detection Alert: ${crashDetectionAlertID ?? "Not Set"}",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        onTap: () {
      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return SizedBox(
            height: 350,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Dropdown for Left/Right Proximity Alerts
                  Text(
                    "Left/Right Proximity Alerts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: leftRightProximityAlertID,
                    hint: Text("Select Pattern"),
                    items: vibrationPatterns.map((String pattern) {
                      return DropdownMenuItem<String>(
                        value: pattern,
                        child: Text(pattern),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        leftRightProximityAlertID = newValue;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 20),

                  // Dropdown for Navigation Alerts
                  Text(
                    "Navigation Alerts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: navigationAlertID,
                    hint: Text("Select Pattern"),
                    items: vibrationPatterns.map((String pattern) {
                      return DropdownMenuItem<String>(
                        value: pattern,
                        child: Text(pattern),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        navigationAlertID = newValue;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  SizedBox(height: 20),

                  // Dropdown for Crash Detection Alerts
                  Text(
                    "Crash Detection Alerts",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  DropdownButton<String>(
                    value: crashDetectionAlertID,
                    hint: Text("Select Pattern"),
                    items: vibrationPatterns.map((String pattern) {
                      return DropdownMenuItem<String>(
                        value: pattern,
                        child: Text(pattern),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        crashDetectionAlertID = newValue;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );}),
              InkWell(
                onTap: (){
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return SizedBox(
                        height: 500,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text('Modal BottomSheet'),
                              ElevatedButton(
                                child: const Text('Close BottomSheet'),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                child: Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Updates",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,

                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(40), color: MyApp.accentColor),
                              width: 40,
                              height: 40,
                              child: Icon(Icons.notifications_active),
                            )
                          ],
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("New",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18
                              ),
                            ),
                            Text("12",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24
                              ),)
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
        ]),
      ),
    );
  }
}
