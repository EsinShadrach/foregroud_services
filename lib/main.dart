import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

void main() async {
  // Initialize JustAudioBackground
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String _imgUrl =
      "https://fastly.picsum.photos/id/866/200/300.jpg?hmac=rcadCENKh4rD6MAp6V_ma-AyWv641M4iiOpe1RyFHeI";
  final String _audioUrl =
      "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

  late AudioPlayer _player;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.setAudioSource(
        AudioSource.uri(
          Uri.parse(_audioUrl),
          tag: MediaItem(
            id: '1',
            album: "Album name",
            title: "Song name",
            artUri: Uri.parse(_imgUrl),
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error initializing player: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo Music Player'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              width: 400,
              height: 400,
              clipBehavior: Clip.antiAlias,
              child: Image.network(
                _imgUrl,
                fit: BoxFit.cover,
              ),
            ),
            const Spacer(),
            StreamBuilder<Duration>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                final position = snapshot.data ?? Duration.zero;
                return Slider(
                  min: 0,
                  max: _player.duration?.inSeconds.toDouble() ?? 1.0,
                  value: position.inSeconds.toDouble(),
                  onChanged: (value) {
                    _player.seek(Duration(seconds: value.toInt()));
                  },
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.play_arrow),
                  onPressed: () {
                    _player.play();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.pause),
                  onPressed: () {
                    _player.pause();
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () {
                    _player.stop();
                  },
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
