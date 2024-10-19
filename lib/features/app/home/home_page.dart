

import 'package:flutter/material.dart';
import 'package:vest1/features/app/bottom_navbar/bottom_navbar.dart';
import 'package:vest1/features/contribute/presentation/pages/contribute_page.dart';
import 'package:vest1/features/explore/presentation/pages/explore_page.dart';
import 'package:vest1/features/save/presentation/pages/saved_page.dart';
import 'package:vest1/features/update/presentation/pages/update_page.dart';

class MapHomePage extends StatefulWidget {
  const MapHomePage({super.key});

  @override
  State<MapHomePage> createState() => _MapHomePageState();
}

class _MapHomePageState extends State<MapHomePage> {


  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavbar(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          }
      ),
      body: _switchPageOnIndex(currentIndex),
    );
  }

  _switchPageOnIndex(int index) {
    switch(index) {
      case 0: {
        return const ExplorePage(currentIndex: 0);
      }
      case 1: {
        return const ExplorePage(currentIndex: 1);
      }
      case 2: {
        return const SavedPage();
      }
      case 3: {
        return const ContributePage();
      }
      case 4: {
        return const UpdatePage();
      }
    }
  }
}
