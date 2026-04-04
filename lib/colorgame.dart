import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: GamePage()));
}

class GamePage extends StatefulWidget {
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple
  ];

  Color targetColor = Colors.red;
  Color currentColor = Colors.blue;

  int score = 0;
  int timeLeft = 30;
  Timer? timer;
  Random random = Random();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    targetColor = colors[random.nextInt(colors.length)];
    currentColor = colors[random.nextInt(colors.length)];
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      if (timeLeft == 0) {
        t.cancel();
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  title: Text("Game Over"),
                  content: Text("Score: $score"),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          resetGame();
                        },
                        child: Text("Restart"))
                  ],
                ));
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  void resetGame() {
    setState(() {
      score = 0;
      timeLeft = 30;
    });
    startGame();
  }

  void changeColor() {
    setState(() {
      currentColor = colors[random.nextInt(colors.length)];
      if (currentColor == targetColor) {
        score++;
        targetColor = colors[random.nextInt(colors.length)];
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Color Match Game"),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Target Color", style: TextStyle(fontSize: 18)),
          SizedBox(height: 10),
          Container(
            height: 80,
            width: 80,
            color: targetColor,
          ),
          SizedBox(height: 30),
          GestureDetector(
            onTap: changeColor,
            child: Container(
              height: 150,
              width: 150,
              color: currentColor,
            ),
          ),
          SizedBox(height: 30),
          Text("Score: $score", style: TextStyle(fontSize: 20)),
          SizedBox(height: 10),
          Text("Time: $timeLeft", style: TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}
