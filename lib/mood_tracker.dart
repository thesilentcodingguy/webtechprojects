import 'package:flutter/material.dart';

void main() {
  runApp(const MoodApp());
}

class MoodApp extends StatelessWidget {
  const MoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentMood = "None";
  Color bgColor = Colors.white;

  Map<String, int> weeklyMood = {
    "Happy": 1,
    "Sad": 2,
    "Angry": 6,
    "Relaxed": 3
  };

  void setMood(String mood, Color color) {
    setState(() {
      currentMood = mood;
      bgColor = color.withOpacity(0.3);
      weeklyMood[mood] = weeklyMood[mood]! + 1;
    });
  }

  Color getColor(String mood) {
    switch (mood) {
      case "Happy":
        return Colors.yellow;
      case "Sad":
        return Colors.blue;
      case "Angry":
        return Colors.red;
      case "Relaxed":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget buildBar(String mood, int value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(value.toString(),
            style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          height: value * 25.0 + 20,
          width: 30,
          decoration: BoxDecoration(
            color: getColor(mood),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(mood),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Mood Tracker"),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Current Mood: $currentMood",
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              children: [
                ElevatedButton(
                  onPressed: () => setMood("Happy", Colors.yellow),
                  child: const Text("Happy"),
                ),
                ElevatedButton(
                  onPressed: () => setMood("Sad", Colors.blue),
                  child: const Text("Sad"),
                ),
                ElevatedButton(
                  onPressed: () => setMood("Angry", Colors.red),
                  child: const Text("Angry"),
                ),
                ElevatedButton(
                  onPressed: () => setMood("Relaxed", Colors.green),
                  child: const Text("Relaxed"),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Text(
              "Weekly Mood Report",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: weeklyMood.entries
                    .map((e) => buildBar(e.key, e.value))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
