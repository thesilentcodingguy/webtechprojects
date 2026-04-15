import 'dart:async';
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
  late Timer _gameTimer;

  double screenWidth = 0;
  double screenHeight = 0;

  // Paddle
  double paddleWidth = 100;
  double paddleHeight = 15;
  double paddleX = 0;
  double paddleTouchX = 0;
  bool isDragging = false;

  // Ball
  double ballSize = 15;
  double ballX = 0;
  double ballY = 0;
  double ballSpeedX = 4;
  double ballSpeedY = 4;
  double initialBallSpeed = 4;

  // Power-ups
  bool isPowerUpActive = false;
  double originalBallSpeedX = 4;
  double originalBallSpeedY = 4;
  int powerUpTimer = 0;

  // Scoring & Game Stats
  int score = 0;
  int highScore = 0;
  int combo = 0;
  int perfectHits = 0;
  int totalHits = 0;
  bool isGameOver = false;
  int timeLeft = 60; // 60 seconds game
  bool isGameStarted = false;

  // Difficulty
  double difficultyMultiplier = 1.0;
  int level = 1;

  // Special effects
  double shakeOffset = 0;
  double ballTrail = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    _ticker = createTicker((_) {
      updateGame();
    });
  }

  void _loadHighScore() async {
    // Simulate loading high score (in real app, use SharedPreferences)
    highScore = 0;
  }

  void _saveHighScore() {
    if (score > highScore) {
      highScore = score;
    }
  }

  void startGame() {
    setState(() {
      score = 0;
      combo = 0;
      perfectHits = 0;
      totalHits = 0;
      isGameOver = false;
      isGameStarted = true;
      timeLeft = 60;
      level = 1;
      difficultyMultiplier = 1.0;
      ballSpeedX = initialBallSpeed;
      ballSpeedY = initialBallSpeed;
      ballX = screenWidth / 2;
      ballY = screenHeight / 3;
      paddleX = screenWidth / 2 - paddleWidth / 2;
      isPowerUpActive = false;
      shakeOffset = 0;
      ballTrail = 0;

      _ticker.start();
      _startTimer();
    });
  }

  void _startTimer() {
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isGameOver && isGameStarted) {
        setState(() {
          if (timeLeft > 0) {
            timeLeft--;

            // Increase difficulty every 15 seconds
            if (timeLeft % 15 == 0 && timeLeft < 60) {
              level++;
              difficultyMultiplier = 1 + (level - 1) * 0.2;
              _increaseDifficulty();
            }
          } else {
            // Time's up - Game Over with victory
            timer.cancel();
            isGameOver = true;
            isGameStarted = false;
            _ticker.stop();
            _saveHighScore();
          }
        });
      }
    });
  }

  void _increaseDifficulty() {
    // Increase ball speed
    double speedIncrease = 1 + (level - 1) * 0.15;
    ballSpeedX = ballSpeedX > 0
        ? initialBallSpeed * speedIncrease
        : -initialBallSpeed * speedIncrease;
    ballSpeedY = ballSpeedY > 0
        ? initialBallSpeed * speedIncrease
        : -initialBallSpeed * speedIncrease;

    // Slightly reduce paddle size at higher levels
    if (level >= 3 && paddleWidth > 60) {
      paddleWidth = max(60, 100 - (level - 2) * 8);
    }
  }

  void _activatePowerUp() {
    if (!isPowerUpActive) {
      isPowerUpActive = true;
      powerUpTimer = 10; // 10 seconds power-up
      originalBallSpeedX = ballSpeedX.abs();
      originalBallSpeedY = ballSpeedY.abs();

      // Random power-up effect
      int powerType = Random().nextInt(3);
      switch (powerType) {
        case 0: // Slow motion
          ballSpeedX = ballSpeedX > 0 ? 2 : -2;
          ballSpeedY = ballSpeedY > 0 ? 2 : -2;
          break;
        case 1: // Speed boost (temporary)
          ballSpeedX = ballSpeedX > 0 ? 7 : -7;
          ballSpeedY = ballSpeedY > 0 ? 7 : -7;
          break;
        case 2: // Mega paddle
          paddleWidth = min(200, paddleWidth * 1.5);
          break;
      }

      // Auto disable power-up after duration
      Future.delayed(const Duration(seconds: 10), () {
        if (isPowerUpActive) {
          setState(() {
            isPowerUpActive = false;
            ballSpeedX = ballSpeedX > 0 ? originalBallSpeedX : -originalBallSpeedX;
            ballSpeedY = ballSpeedY > 0 ? originalBallSpeedY : -originalBallSpeedY;
            if (paddleWidth > 100) {
              paddleWidth = 100;
            }
          });
        }
      });
    }
  }

  void updateGame() {
    if (isGameOver || !isGameStarted) return;

    setState(() {
      ballX += ballSpeedX;
      ballY += ballSpeedY;

      // Left & Right wall bounce with screen shake effect
      if (ballX <= 0) {
        ballSpeedX = ballSpeedX.abs();
        shakeOffset = 5;
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() => shakeOffset = 0);
        });
      }
      if (ballX + ballSize >= screenWidth) {
        ballSpeedX = -ballSpeedX.abs();
        shakeOffset = 5;
        Future.delayed(const Duration(milliseconds: 100), () {
          setState(() => shakeOffset = 0);
        });
      }

      // Top bounce
      if (ballY <= 0) {
        ballSpeedY = ballSpeedY.abs();
      }

      // Paddle collision with enhanced scoring
      if (ballY + ballSize >= screenHeight - 100 &&
          ballY + ballSize <= screenHeight - 80 &&
          ballX + ballSize >= paddleX &&
          ballX <= paddleX + paddleWidth) {

        totalHits++;

        // Calculate hit position for angle
        double hitPos = (ballX + ballSize / 2) - (paddleX + paddleWidth / 2);
        double normalizedHit = hitPos / (paddleWidth / 2);

        // Change ball direction based on hit position
        ballSpeedY = -ballSpeedY.abs();
        ballSpeedX = normalizedHit * 6 * difficultyMultiplier;

        // Clamp speed to prevent too slow/fast
        ballSpeedX = ballSpeedX.clamp(-8, 8);

        // Combo system
        combo++;
        int pointsEarned = 10 * combo;

        // Perfect hit bonus (hit near center)
        if (normalizedHit.abs() < 0.2) {
          perfectHits++;
          pointsEarned = (pointsEarned * 1.5).toInt();
        }

        score += pointsEarned;

        // Random power-up chance (10% on each hit)
        if (!isPowerUpActive && Random().nextDouble() < 0.1) {
          _activatePowerUp();
        }

        // Level up every 100 points
        int newLevel = 1 + (score ~/ 100);
        if (newLevel > level) {
          level = newLevel;
          _increaseDifficulty();
        }
      }

      // Game Over (missed paddle)
      if (ballY > screenHeight) {
        isGameOver = true;
        isGameStarted = false;
        _ticker.stop();
        _gameTimer.cancel();
        _saveHighScore();
        combo = 0;
      }
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    if (_gameTimer.isActive) {
      _gameTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    // Initialize ball and paddle positions if not started
    if (ballX == 0 && !isGameStarted) {
      ballX = screenWidth / 2;
      ballY = screenHeight / 3;
      paddleX = screenWidth / 2 - paddleWidth / 2;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Transform.translate(
        offset: Offset(shakeOffset, 0),
        child: GestureDetector(
          onHorizontalDragStart: (details) {
            isDragging = true;
            paddleTouchX = details.localPosition.dx;
          },
          onHorizontalDragUpdate: (details) {
            if (!isGameOver && isGameStarted) {
              setState(() {
                double newPaddleX = details.localPosition.dx - paddleWidth / 2;
                paddleX = newPaddleX.clamp(0.0, screenWidth - paddleWidth);
              });
            }
          },
          onHorizontalDragEnd: (details) {
            isDragging = false;
          },
          child: Stack(
            children: [
              // Game Stats Panel
              Positioned(
                top: 40,
                left: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Score: $score",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "High Score: $highScore",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),

              // Timer and Combo
              Positioned(
                top: 40,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: timeLeft < 10 ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "Time: ${timeLeft}s",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    if (combo > 1)
                      Text(
                        "Combo: x$combo!",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 5,
                              color: Colors.orange.withOpacity(0.5),
                            )
                          ],
                        ),
                      ),
                    if (isPowerUpActive)
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "POWER UP!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Level Indicator
              Positioned(
                bottom: 150,
                left: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Level $level",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Accuracy Indicator
              Positioned(
                bottom: 150,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: totalHits > 0 ? Colors.amber : Colors.grey,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    totalHits > 0
                        ? "Perfect: ${((perfectHits / totalHits) * 100).toInt()}%"
                        : "Perfect: 0%",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Ball Trail Effect
              if (ballTrail > 0)
                for (int i = 1; i <= 3; i++)
                  Positioned(
                    left: ballX - ballSpeedX * i * 0.5,
                    top: ballY - ballSpeedY * i * 0.5,
                    child: Container(
                      width: ballSize * (1 - i * 0.2),
                      height: ballSize * (1 - i * 0.2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3 - i * 0.1),
                        shape: BoxShape.circle,
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
                  decoration: BoxDecoration(
                    color: isPowerUpActive ? Colors.purple : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isPowerUpActive ? Colors.purple : Colors.white).withOpacity(0.5),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),

              // Paddle
              Positioned(
                bottom: 80,
                left: paddleX,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: paddleWidth,
                  height: paddleHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isPowerUpActive
                          ? [Colors.purple, Colors.pink]
                          : [Colors.blue, Colors.lightBlue],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),

              // Start Screen
              if (!isGameStarted && !isGameOver)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "PADDLE GAME",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Drag to move paddle",
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                      const Text(
                        "Keep the ball in play for 60 seconds!",
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        onPressed: startGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          backgroundColor: Colors.blue,
                        ),
                        child: const Text(
                          "START GAME",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),

              // Game Over UI
              if (isGameOver)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red, width: 2),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                          timeLeft == 0 ? "TIME'S UP!" : "YOU MISSED!",
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Final Score: $score",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "High Score: $highScore",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Perfect Hits: ${perfectHits}/$totalHits",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Max Combo: $combo",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          "Level Reached: $level",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            _ticker.stop();
                            if (_gameTimer.isActive) _gameTimer.cancel();
                            startGame();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          ),
                          child: const Text("PLAY AGAIN"),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
