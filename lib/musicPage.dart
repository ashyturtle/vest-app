import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';

class MusicPage extends StatefulWidget {
  const MusicPage({Key? key}) : super(key: key);

  @override
  State<MusicPage> createState() => _MusicPageState();
}

class _MusicPageState extends State<MusicPage> {
  late AudioPlayer _audioPlayer;
  String? _artworkUrl;

  late ConcatenatingAudioSource _playlist;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _audioPlayer = AudioPlayer();

    // Define your playlist with multiple tracks using AudioSource.uri
    _playlist = ConcatenatingAudioSource(children: [
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
        Uri.parse('asset:///assets/Logic - Paul Rodriguez.mp3'),
        tag: MediaItem(
          id: '2',
          title: 'Sample Track 2',
          artUri: Uri.parse(
              'https://images.genius.com/7822428a3d878d476d3549c9619c29f6.1000x1000x1.png'),
        ),
      ),
      AudioSource.uri(
        Uri.parse('asset:///assets/Logic - Sayonara.mp3'),
        tag: MediaItem(
          id: '3',
          title: 'Sample Track 3',
          artUri: Uri.parse(
              'https://images.genius.com/7822428a3d878d476d3549c9619c29f6.1000x1000x1.png'),
        ),
      ),
    ]);

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    // Load the playlist
    try {
      await _audioPlayer.setAudioSource(_playlist);
    } catch (e) {
      print("Error loading audio source: $e");
    }

    // Listen for playback completion to reset the player
    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _audioPlayer.seek(Duration.zero, index: 0);
        _audioPlayer.pause();
      }
    });

    // Update artwork URL when the current track changes
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && _audioPlayer.sequence != null) {
        final tag = _audioPlayer.sequence![index].tag as MediaItem;
        setState(() {
          _artworkUrl = tag.artUri.toString();
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  // Stream to update the position and duration
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest2<Duration, Duration, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.durationStream
            .map((duration) => duration ?? Duration.zero),
            (position, duration) => PositionData(position, duration),
      );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(16.0),
        children: [
          if (_artworkUrl != null)
            Image.network(
              _artworkUrl!,
              width: 300,
              height: 300,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error),
            ),
          StreamBuilder<PositionData>(
            stream: _positionDataStream,
            builder: (context, snapshot) {
              final positionData = snapshot.data;
              return Column(
                children: [
                  Slider(
                    min: 0.0,
                    max:
                    positionData?.duration.inMilliseconds.toDouble() ?? 0.0,
                    value:
                    positionData?.position.inMilliseconds.toDouble() ?? 0.0,
                    onChanged: (value) {
                      _audioPlayer
                          .seek(Duration(milliseconds: value.round()));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(
                            positionData?.position ?? Duration.zero),
                      ),
                      Text(
                        _formatDuration(
                            positionData?.duration ?? Duration.zero),
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
                icon: const Icon(Icons.skip_previous),
                iconSize: 64.0,
                onPressed:
                _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null,
              ),
              StreamBuilder<bool>(
                stream: _audioPlayer.playingStream,
                builder: (context, snapshot) {
                  bool isPlaying = snapshot.data ?? false;
                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    iconSize: 64.0,
                    onPressed: () {
                      if (isPlaying) {
                        _audioPlayer.pause();
                      } else {
                        _audioPlayer.play();
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 64.0,
                onPressed:
                _audioPlayer.hasNext ? _audioPlayer.seekToNext : null,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Upcoming Tracks',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          // Track List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _audioPlayer.sequence?.length ?? 0,
            itemBuilder: (context, index) {
              final sequence = _audioPlayer.sequence;
              if (sequence == null || index >= sequence.length)
                return Container();
              final track = sequence[index];
              final tag = track.tag as MediaItem;
              return ListTile(
                leading: Image.network(
                  tag.artUri.toString(),
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.music_note),
                ),
                title: Text(tag.title),
                onTap: () {
                  _audioPlayer.seek(Duration.zero, index: index);
                  _audioPlayer.play();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper method to format duration
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}

// Class to hold position data
class PositionData {
  final Duration position;
  final Duration duration;

  PositionData(this.position, this.duration);
}
