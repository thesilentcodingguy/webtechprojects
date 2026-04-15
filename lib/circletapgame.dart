import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CircleTapGameApp());
}

class CircleTapGameApp extends StatelessWidget {
  const CircleTapGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Circle Tap Game',
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
    with SingleTickerProviderStateMixin {
  final Random random = Random();

  double circleX = 100;
  double circleY = 100;
  double circleSize = 80;

  int score = 0;
  int timeLeft = 30;

  Timer? gameTimer;
  Timer? spawnTimer;

  bool gameOver = false;
  bool _isInitialized = false;

  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  double screenWidth = 0;
  double screenHeight = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
  }

  /// ✅ SAFE place to access MediaQuery
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      final size = MediaQuery.of(context).size;

      screenWidth = size.width;
      screenHeight = size.height;

      startGame();
      _isInitialized = true;
    }
  }

  void startGame() {
    score = 0;
    timeLeft = 30;
    gameOver = false;

    moveCircle();

    gameTimer?.cancel();
    spawnTimer?.cancel();

    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft <= 0) {
        endGame();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });

    spawnTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      moveCircle();
    });
  }

  void moveCircle() {
    setState(() {
      circleX = random.nextDouble() * (screenWidth - circleSize);
      circleY = random.nextDouble() * (screenHeight - circleSize - 150);

      _controller.forward(from: 0);
    });
  }

  void onCircleTap() {
    if (gameOver) return;

    setState(() {
      score++;
    });

    moveCircle();
  }

  void endGame() {
    gameTimer?.cancel();
    spawnTimer?.cancel();

    setState(() {
      gameOver = true;
    });
  }

  void restartGame() {
    startGame();
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    spawnTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("🎯 Circle Tap Game"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          /// Background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Colors.deepPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          /// Score
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              "Score: $score",
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          /// Timer
          Positioned(
            top: 20,
            right: 20,
            child: Text(
              "Time: $timeLeft",
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),

          /// Circle
          if (!gameOver)
            Positioned(
              left: circleX,
              top: circleY,
              child: GestureDetector(
                onTap: onCircleTap,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: circleSize,
                    height: circleSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.pinkAccent,
                          Colors.deepPurple.shade900
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withOpacity(0.7),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),

          /// Game Over Screen
          if (gameOver)
            Container(
              color: Colors.black.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Game Over",
                      style: TextStyle(
                          fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Final Score: $score",
                      style: const TextStyle(fontSize: 28),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: restartGame,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                      ),
                      child: const Text(
                        "Restart",
                        style: TextStyle(fontSize: 20),
                      ),
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
