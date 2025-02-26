import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nowplaying/nowplaying.dart';
import 'package:nowplaying/nowplaying_track.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';
import 'package:vest1/main.dart';

class MusicPlayerPage extends StatelessWidget {
  const MusicPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: NowPlayingTrackWidget()),
    );
  }
}

class NowPlayingTrackWidget extends StatefulWidget {
  @override
  _NowPlayingTrackState createState() => _NowPlayingTrackState();
}

class _NowPlayingTrackState extends State<NowPlayingTrackWidget> {
  late AudioHandler _audioHandler;

  @override
  void initState() {
    super.initState();
    _initAudioService();
    _checkPermissions();
  }

  // Initialize Audio Service
  Future<void> _initAudioService() async {
    _audioHandler = await AudioService.init(
      builder: () => SystemMediaControlHandler(),
      config: AudioServiceConfig(
        androidNotificationChannelId: 'com.codingmind.pulsepath.channel.audio',
        androidNotificationChannelName: 'PulsePath Audio',
        androidNotificationOngoing: true,
      ),
    );
  }

  // Check permissions for NowPlaying
  Future<void> _checkPermissions() async {
    bool isEnabled = await NowPlaying.instance.isEnabled();
    if (!isEnabled) {
      final shown = await NowPlaying.instance.requestPermissions();
      print('MANAGED TO SHOW PERMS PAGE: $shown');
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamProvider<NowPlayingTrack>.value(
      initialData: NowPlayingTrack.loading,
      value: NowPlaying.instance.stream,
      child: Consumer<NowPlayingTrack>(
        builder: (context, track, _) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (track.isStopped)
                  Text('Nothing playing',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                if (!track.isStopped) ...[
                  if (track.title != null)
                    Text(track.title!.trim(),
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  if (track.artist != null)
                    Text(track.artist!.trim(),
                        style: TextStyle(fontSize: 20, color: Colors.grey)),
                  if (track.album != null)
                    Text(track.album!.trim(),
                        style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 10),
                  Text(track.duration.truncToSecond.toShortString(),
                      style: TextStyle(fontSize: 16)),
                  TrackProgressIndicator(track),
                  LinearProgressIndicator(
                    value: track.progress.inSeconds / track.duration.inSeconds,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(MyApp.primaryColor),
                  ),
                  Text(track.state.toString(),
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                        width: 200,
                        height: 200,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 350),
                          child: _imageFrom(track),
                        ),
                      ),
                      Positioned(top: 0, right: 0, child: _iconFrom(track)),
                      Positioned(
                          top: 0,
                          left: 8,
                          child: Text(track.source!.trim(),
                              style: TextStyle(fontSize: 14, color: Colors.grey))),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous),
                        onPressed: () async {
                          try {
                            await _audioHandler.skipToPrevious();
                          } catch (e) {
                            print("Previous failed: $e");
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(track.state == NowPlayingState.playing
                            ? Icons.pause
                            : Icons.play_arrow),
                        onPressed: () async {
                          try {
                            if (track.state == NowPlayingState.playing) {
                              await _audioHandler.pause();
                            } else {
                              await _audioHandler.play();
                            }
                          } catch (e) {
                            print("Play/pause failed: $e");
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next),
                        onPressed: () async {
                          try {
                            await _audioHandler.skipToNext();
                          } catch (e) {
                            print("Next failed: $e");
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _imageFrom(NowPlayingTrack track) {
    if (track.hasImage)
      return Image(
        key: Key(track.id),
        image: track.image!,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      );

    if (track.isResolvingImage) {
      return SizedBox(
        width: 50.0,
        height: 50.0,
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple)),
      );
    }

    return Text('NO\nARTWORK\nFOUND',
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, color: Colors.white));
  }

  Widget _iconFrom(NowPlayingTrack track) {
    if (track.hasIcon)
      return Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(blurRadius: 5, color: Colors.black)],
            shape: BoxShape.circle),
        child: Image(
          image: track.icon!,
          width: 25,
          height: 25,
          fit: BoxFit.contain,
          color: _fgColorFor(track),
          colorBlendMode: BlendMode.srcIn,
        ),
      );
    return Container();
  }

  Color _fgColorFor(NowPlayingTrack track) {
    switch (track.source) {
      case "com.apple.music":
        return Colors.blue;
      case "com.hughesmedia.big_finish":
        return Colors.red;
      case "com.spotify.music":
        return Colors.green;
      default:
        return Colors.purpleAccent;
    }
  }
}

// Audio handler for system media control
class SystemMediaControlHandler extends BaseAudioHandler {
  @override
  Future<void> play() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.pause, MediaControl.skipToNext, MediaControl.skipToPrevious],
      playing: true,
    ));
    await platformInvoke('play');
  }

  @override
  Future<void> pause() async {
    playbackState.add(playbackState.value.copyWith(
      controls: [MediaControl.play, MediaControl.skipToNext, MediaControl.skipToPrevious],
      playing: false,
    ));
    await platformInvoke('pause');
  }

  @override
  Future<void> skipToNext() async {
    await platformInvoke('next');
  }

  @override
  Future<void> skipToPrevious() async {
    await platformInvoke('previous');
  }

  // Platform-specific invocation (simplified; actual implementation may vary)
  Future<void> platformInvoke(String action) async {
    // try {
    //   await AudioService.(action);
    // } catch (e) {
    //   print("System media action $action failed: $e");
    // }
  }
}

class TrackProgressIndicator extends StatefulWidget {
  final NowPlayingTrack track;

  TrackProgressIndicator(this.track);

  @override
  _TrackProgressIndicatorState createState() => _TrackProgressIndicatorState();
}

class _TrackProgressIndicatorState extends State<TrackProgressIndicator> {
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.track.progress.truncToSecond;
    final countdown =
        widget.track.duration - progress + const Duration(seconds: 1);
    return Column(
      children: [
        Text(progress.toShortString(), style: TextStyle(fontSize: 16)),
        Text(countdown.toShortString(), style: TextStyle(fontSize: 16)),
      ],
    );
  }
}

extension DurationExtension on Duration {
  Duration get truncToSecond {
    final ms = this.inMilliseconds;
    return Duration(milliseconds: ms - ms % 1000);
  }

  String toShortString() => toString().split(".").first;
}