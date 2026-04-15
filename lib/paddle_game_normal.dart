import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  runApp(const PaddleGameApp());
}

class PaddleGameApp extends StatelessWidget {
  const PaddleGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
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
  late Ticker _ticker;

  double screenWidth = 0;
  double screenHeight = 0;

  // Paddle
  double paddleWidth = 100;
  double paddleHeight = 15;
  double paddleX = 0;

  // Ball
  double ballSize = 15;
  double ballX = 0;
  double ballY = 0;

  double ballSpeedX = 4;
  double ballSpeedY = 4;

  int score = 0;
  bool isGameOver = false;

  @override
  void initState() {
    super.initState();

    _ticker = createTicker((_) {
      updateGame();
    });

    _ticker.start();
  }

  void startGame() {
    setState(() {
      score = 0;
      isGameOver = false;
      ballSpeedX = 4;
      ballSpeedY = 4;
      ballX = screenWidth / 2;
      ballY = screenHeight / 3;
      paddleX = screenWidth / 2 - paddleWidth / 2;
    });
  }

  void updateGame() {
    if (isGameOver) return;

    setState(() {
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      // Left & Right wall bounce
      if (ballX <= 0 || ballX + ballSize >= screenWidth) {
        ballSpeedX *= -1;
      }

      // Top bounce
      if (ballY <= 0) {
        ballSpeedY *= -1;
      }

      // Paddle collision
      if (ballY + ballSize >= screenHeight - 100 &&
          ballX + ballSize >= paddleX &&
          ballX <= paddleX + paddleWidth) {
        ballSpeedY *= -1;

        // Direction change based on hit position
        double hitPos = (ballX + ballSize / 2) - (paddleX + paddleWidth / 2);
        ballSpeedX = hitPos * 0.1;

        score++;
      }

      // Game Over (missed paddle)
      if (ballY > screenHeight) {
        isGameOver = true;
        _ticker.stop();
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          setState(() {
            paddleX += details.delta.dx;

            if (paddleX < 0) paddleX = 0;
            if (paddleX + paddleWidth > screenWidth) {
              paddleX = screenWidth - paddleWidth;
            }
          });
        },
        child: Stack(
          children: [
            // Score
            Positioned(
              top: 40,
              left: 20,
              child: Text(
                "Score: $score",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Ball
            Positioned(
              left: ballX,
              top: ballY,
              child: Container(
                width: ballSize,
                height: ballSize,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Paddle
            Positioned(
              bottom: 80,
              left: paddleX,
              child: Container(
                width: paddleWidth,
                height: paddleHeight,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // Game Over UI
            if (isGameOver)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "GAME OVER",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Final Score: $score",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        _ticker.start();
                        startGame();
                      },
                      child: const Text("Restart"),
                    )
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
