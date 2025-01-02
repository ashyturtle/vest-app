import 'package:flutter/material.dart';
import 'package:vest1/components/SlidingAppbar.dart';
import 'package:vest1/homePage.dart';
import 'package:vest1/musicPlayerPage.dart';
import 'package:vest1/navigationPage.dart';
import 'package:vest1/userPage.dart';

// Import audio service and just_audio_background

class RoutePage extends StatefulWidget {
  const RoutePage({super.key});

  @override
  State<RoutePage> createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> with SingleTickerProviderStateMixin {
  int selectedPageIndex = 0;
  late final AnimationController _controller;

  List<Widget> pages = [
    HomePage(),
    MapPage(),
    MusicPlayerPage(),
    UserPage(),
  ];

  @override
  void initState() {
    super.initState();

    // Set up the animation controller for the sliding appbar
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Initialize Audio Service and Handler
    //_initAudio();
  }

//   Future<void> _initAudio() async {
//     // Initialize JustAudioBackground for metadata and lock screen controls
//     await JustAudioBackground.init(
//       androidNotificationChannelId: 'com.codingmind.pulsepath.audio',
//       androidNotificationChannelName: 'Audio Playback',
//       androidNotificationOngoing: true,
//     );
//
//     // Initialize the AudioHandler
//     final handler = await AudioService.init(
//       builder: () => MyAudioHandler(),
//       config: const AudioServiceConfig(
//         androidNotificationChannelId: 'com.codingmind.pulsepath.audio',
//         androidNotificationChannelName: 'Music Playback',
//         androidNotificationOngoing: true,
//       ),
//     );
//
// // Cast the handler to MyAudioHandler
//     final myHandler = handler;
//
//     setState(() {
//       _audioHandler = myHandler; // _audioHandler should be of type MyAudioHandler?
//
//       pages = [
//         HomePage(),
//         MapPage(),
//         MusicPage(audioHandler: _audioHandler as MyAudioHandler), // Pass MyAudioHandler here
//         UserPage(),
//       ];
//     });
//
//   }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide AppBar only for NavigationPage
    bool isAppbarVisible = selectedPageIndex != 1;

    // If _audioHandler is not ready yet, show a loading indicator
    // if (_audioHandler == null) {
    //   return Scaffold(
    //     body: Center(child: CircularProgressIndicator()),
    //   );
    // }

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
          : null,
      body: pages[selectedPageIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            selectedPageIndex = index;
            if (index == 1) {
              isAppbarVisible = false;
            } else {
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
