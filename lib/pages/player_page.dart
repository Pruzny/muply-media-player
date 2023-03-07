import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:rxdart/rxdart.dart';

class Player extends StatefulWidget {
  const Player({super.key});
  @override
  State<Player> createState() => _PlayerState();
}

class _PlayerState extends State<Player> {
  final AudioPlayer _audioPlayer = GlobalPlayer.getPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muply'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              GlobalPlayer.songName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold
              ),
            ),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: AspectRatio(
                aspectRatio: 1,
                child: QueryArtworkWidget(
                  id: GlobalPlayer.songId ?? 0,
                  type: ArtworkType.AUDIO,
                  size: 1000,
                  artworkBorder: BorderRadius.circular(20),
                ),
              ),
            ),
            Column(
              children: [
                FractionallySizedBox(
                  widthFactor: 0.8,
                  child: StreamBuilder(
                    stream: GlobalPlayer._seekBarStream,
                    builder: (context, snapshot) {
                      final SeekBar? seekBarState = snapshot.data;
                      final Duration total = seekBarState?.duration ?? Duration.zero;
                      Duration progress = seekBarState?.pos ?? Duration.zero;

                      // Fix low duration progress bar
                      if (progress > total) {
                        progress = total;
                      }
                      
                
                      return ProgressBar(
                        progress: progress,
                        total: total,
                        onSeek: _audioPlayer.seek,
                      );
                    },
                  ),
                ),
                StreamBuilder(
                  stream: _audioPlayer.playerStateStream,
                  builder:(context, snapshot) {
                    final PlayerState? playerState = snapshot.data;
                    final ProcessingState? processingState = playerState?.processingState;
                    final bool? isPlaying = playerState?.playing;
                    if (!(isPlaying ?? false)) {
                      return IconButton(
                        onPressed: _audioPlayer.play,
                        icon: const Icon(Icons.play_arrow_rounded),
                        iconSize: 80,
                        color: Colors.blueAccent,
                      );
                    }
                    else if (processingState != ProcessingState.completed) {
                      return IconButton(
                        onPressed: _audioPlayer.pause,
                        icon: const Icon(Icons.pause_rounded),
                        iconSize: 80,
                        color: Colors.blueAccent,
                      );
                    }
                    return const Icon(
                      Icons.play_arrow_rounded,
                      size: 80,
                      color: Colors.grey,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class GlobalPlayer {
  static final AudioPlayer _player = AudioPlayer();
  static String songName = '';
  static int? songId;
  static Stream<SeekBar> get _seekBarStream => Rx.combineLatest2(
    _player.positionStream, _player.durationStream, (pos, duration) => SeekBar(pos: pos, duration: duration ?? Duration.zero)
  );

  static AudioPlayer getPlayer() {
    return _player;
  }
}

class SeekBar {
  final Duration pos;
  final Duration duration;

  const SeekBar({required this.pos, required this.duration});
}