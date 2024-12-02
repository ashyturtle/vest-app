import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

// Define a custom AudioPlayerHandler
class MyAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player = AudioPlayer();

  MyAudioHandler() {
    // Listen for current index changes to update media item
    _player.currentIndexStream.listen((index) {
      if (index != null && _player.sequence != null) {
        final mediaItem = _player.sequence![index].tag as MediaItem;
        mediaItemSubject.add(mediaItem); // Update the currently playing media item
      }
    });

    // Listen for playback state changes
    _player.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          _player.playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
        },
        playing: _player.playing,
        processingState: {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> skipToNext() => _player.seekToNext();
  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();
  @override
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> loadPlaylist() async {
    final playlist = ConcatenatingAudioSource(children: [
      AudioSource.uri(
        Uri.parse('asset:///assets/sample3s.mp3'),
        tag: MediaItem(
          id: '1',
          title: 'Sample Track 1',
          artUri: Uri.parse(
              'https://images.genius.com/7822428a3d878d476d3549c9619c29f6.1000x1000x1.png'),
        ),
      ),
      AudioSource.uri(
        Uri.parse('asset:///assets/Logic-PaulRodriguez.mp3'),
        tag: MediaItem(
          id: '2',
          title: 'Sample Track 2',
          artUri: Uri.parse(
              'https://images.genius.com/7822428a3d878d476d3549c9619c29f6.1000x1000x1.png'),
        ),
      ),
      AudioSource.uri(
        Uri.parse('asset:///assets/Logic-Sayonara.mp3'),
        tag: MediaItem(
          id: '3',
          title: 'Sample Track 3',
          artUri: Uri.parse(
              'https://images.genius.com/7822428a3d878d476d3549c9619c29f6.1000x1000x1.png'),
        ),
      ),
    ]);

    try {
      await _player.setAudioSource(playlist);
    } catch (e) {
      print("Error loading playlist: $e");
    }
  }
}

// Background task entrypoint
void _audioTaskEntrypoint() {
  AudioServiceBackground.run(() => MyAudioHandler());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Audio Service Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MusicPage(),
    );
  }
}

class MusicPage extends StatelessWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            if (AudioService.running) {
              await AudioService.stop();
            } else {
              await AudioService.start(
                backgroundTaskEntrypoint: _audioTaskEntrypoint,
                androidNotificationChannelName: 'Music Player',
                androidNotificationOngoing: true,
              );
              final handler = AudioServiceBackground.handler as MyAudioHandler;
              await handler.loadPlaylist();
              await handler.play();
            }
          },
          child: const Text('Play Music'),
        ),
      ),
    );
  }
}
