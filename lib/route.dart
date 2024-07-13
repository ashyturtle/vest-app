import 'package:flutter/material.dart';

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  int selectedPageIndex = 0;
  final List<Widget> pages = [
    Text("Home"),
    Text("Navigation"),
    Text("Music"),
    Text("Me")
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vest"),
        elevation: 2,
      ),
      body: Center(child: pages[selectedPageIndex],),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPageIndex,
        onDestinationSelected: (int index){
          setState(() {
            selectedPageIndex = index;
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
