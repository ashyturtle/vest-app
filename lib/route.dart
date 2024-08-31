import 'package:flutter/material.dart';
import 'package:vest1/components/SlidingAppbar.dart';
import 'package:vest1/homePage.dart';
import 'package:vest1/musicPage.dart';
import 'package:vest1/navigationPage.dart';
import 'package:vest1/userPage.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> with SingleTickerProviderStateMixin {
  int selectedPageIndex = 0;
  final List<Widget> pages = [
    HomePage(),
    NavigationPage(),
    MusicPage(),
    UserPage()
  ];
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide AppBar only for NavigationPage
    bool isAppbarVisible = selectedPageIndex != 1;

    return Scaffold(
      appBar: isAppbarVisible
          ? SlidingAppbar(
        controller: _controller,
        visible: isAppbarVisible,
        child: AppBar(
          title: const Text("Vest"),
          elevation: 2,
        ),
      )
          : null, // Set appBar to null for full screen on NavigationPage
      body: pages[selectedPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            selectedPageIndex = index;
            if(index == 1){
              isAppbarVisible = false;
            }else {
              isAppbarVisible = true;
            }
          });
        },
        elevation: 2,
        destinations: [
          NavigationDestination(
              icon: Icon(selectedPageIndex == 0 ? Icons.home : Icons.home_outlined),
              label: "Home"
          ),
          NavigationDestination(
              icon: Icon(selectedPageIndex == 1 ? Icons.navigation : Icons.navigation_outlined),
              label: "Navigation"

          ),
          NavigationDestination(
              icon: Icon(selectedPageIndex == 2 ? Icons.music_note : Icons.music_note_outlined),
              label: "Music"
          ),
          NavigationDestination(
              icon: Icon(selectedPageIndex == 3 ? Icons.grid_view_rounded : Icons.grid_view_outlined),
              label: "Me"
          )
        ],
      ),
    );
  }
}
