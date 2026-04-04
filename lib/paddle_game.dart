import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GamePage(),
    );
  }
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  double ballX = 0;
  double ballY = -0.9;
  double paddleX = 0;

  double speed = 0.01;
  int score = 0;

  final double paddleWidth = 0.3;
  final double paddleHeight = 0.05;

  Timer? gameTimer;

  final Random random = Random();

  @override
  void initState() {
    super.initState();
    startGame();
  }

  void startGame() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      setState(() {
        ballY += speed;

        // Ball reaches bottom
        if (ballY >= 0.9) {
          if ((ballX >= paddleX - paddleWidth / 2) &&
              (ballX <= paddleX + paddleWidth / 2)) {
            // Catch
            score++;
          } else {
            // Miss
            score--;
          }

          // Reset ball
          ballY = -0.9;
          ballX = random.nextDouble() * 2 - 1;
        }
      });
    });
  }

  void movePaddle(double dx) {
    setState(() {
      paddleX += dx;
      if (paddleX > 1) paddleX = 1;
      if (paddleX < -1) paddleX = -1;
    });
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          movePaddle(details.delta.dx / MediaQuery.of(context).size.width * 2);
        },
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Score
            Text(
              "Score: $score",
              style: const TextStyle(color: Colors.white, fontSize: 24),
            ),

            // Speed Control
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Speed", style: TextStyle(color: Colors.white)),
                Slider(
                  value: speed,
                  min: 0.005,
                  max: 0.03,
                  onChanged: (value) {
                    setState(() {
                      speed = value;
                    });
                  },
                ),
              ],
            ),

            Expanded(
              child: Stack(
                children: [
                  // Ball
                  Align(
                    alignment: Alignment(ballX, ballY),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Paddle
                  Align(
                    alignment: Alignment(paddleX, 0.9),
                    child: Container(
                      width: MediaQuery.of(context).size.width * paddleWidth,
                      height: 20,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
