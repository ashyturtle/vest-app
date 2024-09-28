import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vest1/main.dart';

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: MyApp.backgroundColor,
            padding: const EdgeInsets.all(20),
            height: double.infinity,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF144771), Color(0xFF071A2C)],
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [],
          )
    );
  }
}
