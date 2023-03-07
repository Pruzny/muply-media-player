import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final OnAudioQuery _onAudioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    requestSongs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muply'),
        centerTitle: true,
      ),
      body: Container(
        alignment: Alignment.center,
        child: FutureBuilder<List<SongModel>>(
          future: _onAudioQuery.querySongs(),
          builder:(context, snapshot) {
            if (snapshot.data == null) {
              return const CircularProgressIndicator();
            }
            List<SongModel> songs = snapshot.data!;
            if (songs.isEmpty) {
              return const Text('No songs available');
            }
            return ListView.builder(
              itemCount: songs.length,
              itemBuilder:(context, index) {
                SongModel song = songs[index];
                return ListTile(
                  title: Text(song.title),
                  subtitle: Text(song.displayName),
                  trailing: const Icon(Icons.more_vert),
                  leading: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.AUDIO,
                  ),
                  onTap: () async {
                    String? uri = song.uri;
                    await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(uri!)));
                    await _audioPlayer.play();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  void requestSongs() async {
    bool permissionStatus = await _onAudioQuery.permissionsStatus();
    if (!permissionStatus) {
      await _onAudioQuery.permissionsRequest();
    }
  }
}