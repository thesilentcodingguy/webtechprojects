import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const SnakeGameApp());
}

class SnakeGameApp extends StatelessWidget {
  const SnakeGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snake Game',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const SnakeGameHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SnakeGameHome extends StatefulWidget {
  const SnakeGameHome({super.key});

  @override
  State<SnakeGameHome> createState() => _SnakeGameHomeState();
}

class _SnakeGameHomeState extends State<SnakeGameHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Snake Game', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.green.shade700,
      ),
      body: const SnakeGame(),
    );
  }
}

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  State<SnakeGame> createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> with SingleTickerProviderStateMixin {
  // Game configuration
  static const int gridSize = 20; // 20x20 grid
  static const int cellSize = 20; // pixels per cell
  static const int initialSnakeLength = 3;
  
  // Game state variables
  List<Point<int>> snake = [];
  Point<int> food = const Point(0, 0);
  String direction = 'RIGHT';
  String nextDirection = 'RIGHT';
  bool isGameRunning = false;
  bool isGameOver = false;
  int score = 0;
  int highScore = 0;
  
  // Animation and timing
  late Timer gameTimer;
  late AnimationController animationController;
  double animationValue = 0;
  
  // Swipe detection
  Offset? swipeStart;
  
  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    )..addListener(() {
      setState(() {});
    });
    initGame();
  }
  
  void initGame() {
    setState(() {
      // Initialize snake in the middle of the grid
      snake = [
        Point(gridSize ~/ 2, gridSize ~/ 2),
        Point(gridSize ~/ 2 - 1, gridSize ~/ 2),
        Point(gridSize ~/ 2 - 2, gridSize ~/ 2),
      ];
      direction = 'RIGHT';
      nextDirection = 'RIGHT';
      isGameRunning = true;
      isGameOver = false;
      score = 0;
      generateFood();
      startGameLoop();
    });
  }
  
  void startGameLoop() {
    gameTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (isGameRunning && !isGameOver) {
        moveSnake();
        setState(() {});
      }
    });
  }
  
  void generateFood() {
    Random random = Random();
    do {
      food = Point(random.nextInt(gridSize), random.nextInt(gridSize));
    } while (snake.contains(food));
  }
  
  void moveSnake() {
    if (!isGameRunning || isGameOver) return;
    
    // Apply the queued direction
    direction = nextDirection;
    
    // Calculate new head position
    Point<int> newHead = snake.first;
    switch (direction) {
      case 'UP':
        newHead = Point(newHead.x, newHead.y - 1);
        break;
      case 'DOWN':
        newHead = Point(newHead.x, newHead.y + 1);
        break;
      case 'LEFT':
        newHead = Point(newHead.x - 1, newHead.y);
        break;
      case 'RIGHT':
        newHead = Point(newHead.x + 1, newHead.y);
        break;
    }
    
    // Check for food collision
    bool ateFood = (newHead.x == food.x && newHead.y == food.y);
    
    // Insert new head
    snake.insert(0, newHead);
    if (!ateFood) {
      snake.removeLast();
    } else {
      // Increase score and generate new food
      setState(() {
        score++;
        if (score > highScore) {
          highScore = score;
        }
      });
      generateFood();
      // Play animation
      animationController.forward(from: 0);
    }
    
    // Check for collisions
    if (isCollision(newHead)) {
      gameOver();
    }
  }
  
  bool isCollision(Point<int> head) {
    // Wall collision
    if (head.x < 0 || head.x >= gridSize || head.y < 0 || head.y >= gridSize) {
      return true;
    }
    
    // Self collision (check if head position exists in body, excluding head)
    for (int i = 1; i < snake.length; i++) {
      if (snake[i].x == head.x && snake[i].y == head.y) {
        return true;
      }
    }
    return false;
  }
  
  void gameOver() {
    setState(() {
      isGameRunning = false;
      isGameOver = true;
    });
    gameTimer.cancel();
  }
  
  void resetGame() {
    gameTimer.cancel();
    initGame();
  }
  
  void changeDirection(String newDirection) {
    if (!isGameRunning || isGameOver) return;
    
    // Prevent 180-degree turns
    if ((direction == 'UP' && newDirection == 'DOWN') ||
        (direction == 'DOWN' && newDirection == 'UP') ||
        (direction == 'LEFT' && newDirection == 'RIGHT') ||
        (direction == 'RIGHT' && newDirection == 'LEFT')) {
      return;
    }
    nextDirection = newDirection;
  }
  
  void handleSwipe(DragUpdateDetails details) {
    if (swipeStart == null) {
      swipeStart = details.globalPosition;
      return;
    }
    
    final delta = details.globalPosition - swipeStart!;
    if (delta.distance < 20) return;
    
    if (delta.dx.abs() > delta.dy.abs()) {
      // Horizontal swipe
      if (delta.dx > 0) {
        changeDirection('RIGHT');
      } else {
        changeDirection('LEFT');
      }
    } else {
      // Vertical swipe
      if (delta.dy > 0) {
        changeDirection('DOWN');
      } else {
        changeDirection('UP');
      }
    }
    swipeStart = null;
  }
  
  @override
  void dispose() {
    gameTimer.cancel();
    animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.delta.dy.abs() > 20) {
          if (details.delta.dy > 0) {
            changeDirection('DOWN');
          } else {
            changeDirection('UP');
          }
        }
      },
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx.abs() > 20) {
          if (details.delta.dx > 0) {
            changeDirection('RIGHT');
          } else {
            changeDirection('LEFT');
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Column(
          children: [
            // Score Board
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              color: Colors.grey.shade800,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('SCORE', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text('$score', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('SNAKE GAME', style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold)),
                      const Text('Swipe to move', style: TextStyle(color: Colors.white38, fontSize: 10)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('HIGH SCORE', style: TextStyle(color: Colors.white54, fontSize: 12)),
                      Text('$highScore', style: const TextStyle(color: Colors.amber, fontSize: 24, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            
            // Game Grid
            Expanded(
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.green.shade700, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      childAspectRatio: 1,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      int x = index % gridSize;
                      int y = index ~/ gridSize;
                      Point<int> cell = Point(x, y);
                      
                      // Determine cell color
                      Color cellColor;
                      if (snake.contains(cell)) {
                        // Snake body with gradient effect
                        int snakeIndex = snake.indexOf(cell);
                        if (snakeIndex == 0) {
                          cellColor = Colors.green.shade300; // Head
                        } else {
                          cellColor = Colors.green.shade700;
                        }
                      } else if (cell == food) {
                        cellColor = Colors.red.shade400;
                      } else {
                        cellColor = Colors.grey.shade850;
                      }
                      
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        margin: const EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: cellColor,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: snake.contains(cell) && snake.indexOf(cell) == 0
                              ? [BoxShadow(color: Colors.green.shade200, blurRadius: 2)]
                              : null,
                        ),
                        child: cell == food
                            ? Icon(Icons.circle, color: Colors.red.shade200, size: 14)
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ),
            
            // Game Over Overlay
            if (isGameOver)
              Container(
                color: Colors.black87,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.sentiment_very_dissatisfied, color: Colors.white, size: 50),
                      const SizedBox(height: 10),
                      const Text('GAME OVER', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text('Score: $score', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: resetGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                        child: const Text('PLAY AGAIN', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Control Buttons (for non-swipe devices)
            Container(
              padding: const EdgeInsets.all(10),
              color: Colors.grey.shade800,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _controlButton('UP', Icons.arrow_upward),
                  const SizedBox(width: 10),
                  _controlButton('LEFT', Icons.arrow_back),
                  const SizedBox(width: 10),
                  _controlButton('DOWN', Icons.arrow_downward),
                  const SizedBox(width: 10),
                  _controlButton('RIGHT', Icons.arrow_forward),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _controlButton(String dir, IconData icon) {
    return ElevatedButton(
      onPressed: isGameRunning && !isGameOver ? () => changeDirection(dir) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade600,
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(12),
      ),
      child: Icon(icon, color: Colors.white, size: 24),
    );
  }
}
