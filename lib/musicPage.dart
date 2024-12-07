import 'package:flutter/material.dart';
import 'package:vest1/audioHandler.dart';

class MusicPage extends StatelessWidget {
  final MyAudioHandler audioHandler; // Must be MyAudioHandler

  const MusicPage({Key? key, required this.audioHandler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await audioHandler.loadPlaylist(); // Should work now
            await audioHandler.play();         // Also accessible
          },
          child: const Text('Play Music'),
        ),
      ),
    );
  }
}
