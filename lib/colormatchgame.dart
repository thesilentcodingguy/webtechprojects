import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const ColorMatchGameApp());
}

class ColorMatchGameApp extends StatelessWidget {
  const ColorMatchGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Color Match Game',
      theme: ThemeData.dark(),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  final Random random = Random();

  late Color targetColor;
  late Color playerColor;

  int score = 0;
  int timeLeft = 30;
  int combo = 0;

  Timer? timer;
  bool gameOver = false;

  late AnimationController targetAnimController;
  late AnimationController playerAnimController;
  late Animation<double> scaleAnim;
  late Animation<double> rotateAnim;

  final List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();

    targetAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    playerAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    scaleAnim = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(parent: targetAnimController, curve: Curves.easeOutBack),
    );

    rotateAnim = Tween<double>(begin: 0, end: pi * 2).animate(
      CurvedAnimation(parent: playerAnimController, curve: Curves.easeInOut),
    );

    startGame();
  }

  void startGame() {
    score = 0;
    timeLeft = 30;
    combo = 0;
    gameOver = false;

    targetColor = getRandomColor();
    playerColor = getRandomColor();

    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (timeLeft <= 0) {
        endGame();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });

    targetAnimController.repeat(reverse: true);
  }

  Color getRandomColor() {
    return colors[random.nextInt(colors.length)];
  }

  void changePlayerColor() {
    if (gameOver) return;

    setState(() {
      playerColor = getRandomColor();
    });

    playerAnimController.forward(from: 0);
    checkMatch();
  }

  void checkMatch() {
    if (playerColor.value == targetColor.value) {
      setState(() {
        score += 1 + combo;
        combo++;
        targetColor = getRandomColor();
      });
    } else {
      combo = 0;
    }
  }

  void endGame() {
    timer?.cancel();
    setState(() {
      gameOver = true;
    });
  }

  void restart() {
    startGame();
  }

  @override
  void dispose() {
    timer?.cancel();
    targetAnimController.dispose();
    playerAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎨 Color Match Game"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// Background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  playerColor.withOpacity(0.2),
                  Colors.black
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Score & Timer
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              "Score: $score",
              style: const TextStyle(fontSize: 22),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Text(
              "Time: $timeLeft",
              style: const TextStyle(fontSize: 22),
            ),
          ),

          /// Combo
          Positioned(
            top: 60,
            left: 20,
            child: Text(
              "Combo: $combo",
              style: const TextStyle(fontSize: 18, color: Colors.orange),
            ),
          ),

          /// Target Box
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Target Color",
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                ScaleTransition(
                  scale: scaleAnim,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: targetColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: targetColor.withOpacity(0.8),
                          blurRadius: 20,
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                const Text("Your Box",
                    style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),

                /// Player Box with Gestures
                GestureDetector(
                  onTap: changePlayerColor,
                  onDoubleTap: () {
                    changePlayerColor();
                    changePlayerColor();
                  },
                  onLongPress: () {
                    setState(() {
                      playerColor = targetColor; // cheat mode 😎
                    });
                    checkMatch();
                  },
                  onHorizontalDragEnd: (_) => changePlayerColor(),
                  onVerticalDragEnd: (_) => changePlayerColor(),
                  child: RotationTransition(
                    turns: rotateAnim,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: playerColor,
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                            color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: playerColor.withOpacity(0.7),
                            blurRadius: 25,
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text(
                  "Tap / Swipe / Long Press",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          /// Game Over
          if (gameOver)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Game Over",
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Text("Final Score: $score",
                        style: const TextStyle(fontSize: 24)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: restart,
                      child: const Text("Restart"),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
