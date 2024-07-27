import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio_background/just_audio_background.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({super.key});

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  late AudioPlayer _audioPlayer;
  String? _artworkUrl;

  final _playlist = ConcatenatingAudioSource(children: [
    AudioSource.asset(
      'assets/sample3s.mp3',
      tag: MediaItem(
        id: '1',
        album: 'Album Name',
        title: 'Sample Song',
      ),
    ),
  ]);

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    await _audioPlayer.setAudioSource(_playlist);
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        final tag = _audioPlayer.sequence![index].tag as MediaItem;
        setState(() {
          _artworkUrl = tag.artUri?.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.durationStream.map((duration) => duration ?? Duration.zero),
            (position, duration) => PositionData(position, duration),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_artworkUrl != null)
              Image.network(
                _artworkUrl!,
                width: 300,
                height: 300,
                errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
              ),
            StreamBuilder<PositionData>(
              stream: _positionDataStream,
              builder: (context, snapshot) {
                final positionData = snapshot.data;
                return Column(
                  children: [
                    Slider(
                      min: 0.0,
                      max: positionData?.duration.inMilliseconds.toDouble() ?? 0.0,
                      value: positionData?.position.inMilliseconds.toDouble() ?? 0.0,
                      onChanged: (value) {
                        _audioPlayer.seek(Duration(milliseconds: value.round()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(positionData?.position ?? Duration.zero),
                        ),
                        Text(
                          _formatDuration(positionData?.duration ?? Duration.zero),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.skip_previous),
                  onPressed: _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null,
                ),
                IconButton(
                  icon: _audioPlayer.playing ? Icon(Icons.pause) : Icon(Icons.play_arrow),
                  onPressed: _audioPlayer.playing ? _audioPlayer.pause : _audioPlayer.play,
                ),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  onPressed: _audioPlayer.hasNext ? _audioPlayer.seekToNext : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

class PositionData {
  final Duration position;
  final Duration duration;

  PositionData(this.position, this.duration);
}
