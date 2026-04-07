import 'package:flutter/material.dart';

void main() {
  runApp(const MusicApp());
}

class MusicApp extends StatelessWidget {
  const MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gesture Music Player',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const MusicScreen(),
    );
  }
}

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  int currentIndex = 0;
  bool isPlaying = false;
  bool isMuted = false;
  double volume = 0.5;

  final List<Map<String, String>> playlist = [
    {
      "title": "Song One",
      "artist": "Artist A",
      "image":
      "https://picsum.photos/300?random=1"
    },
    {
      "title": "Song Two",
      "artist": "Artist B",
      "image":
      "https://picsum.photos/300?random=2"
    },
    {
      "title": "Song Three",
      "artist": "Artist C",
      "image":
      "https://picsum.photos/300?random=3"
    },
  ];

  void nextSong() {
    setState(() {
      currentIndex = (currentIndex + 1) % playlist.length;
    });
  }

  void prevSong() {
    setState(() {
      currentIndex =
          (currentIndex - 1 + playlist.length) % playlist.length;
    });
  }

  void togglePlay() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void toggleMute() {
    setState(() {
      isMuted = !isMuted;
    });
  }

  void changeVolume(double delta) {
    setState(() {
      volume = (volume - delta).clamp(0.0, 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final song = playlist[currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gesture Music Player"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: togglePlay,
        onLongPress: toggleMute,
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            nextSong();
          } else {
            prevSong();
          }
        },
        onVerticalDragUpdate: (details) {
          changeVolume(details.delta.dy / 300);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🎵 Album Art
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: isPlaying ? 20 : 5,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  song["image"]!,
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🎶 Song Info
            Text(
              song["title"]!,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              song["artist"]!,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),

            /// ▶️ Controls Indicator
            Icon(
              isPlaying ? Icons.pause_circle : Icons.play_circle,
              size: 70,
              color: Colors.deepPurple,
            ),

            const SizedBox(height: 20),

            /// 🔊 Volume Indicator
            Column(
              children: [
                const Text("Volume"),
                LinearProgressIndicator(
                  value: isMuted ? 0 : volume,
                  minHeight: 8,
                ),
                Text(
                  isMuted
                      ? "Muted"
                      : "${(volume * 100).toInt()}%",
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// 📝 Instructions
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "👉 Swipe → Next/Previous\n"
                    "👆 Tap → Play/Pause\n"
                    "✋ Long Press → Mute\n"
                    "⬆️⬇️ Drag → Volume",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
