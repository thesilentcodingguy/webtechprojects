import 'package:flutter/material.dart';
import 'dart:math';
import 'animated_object.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  int score = 0;
  int misses = 0;
  bool isGameRunning = true;
  final Random random = Random();
  final List<AnimatedObject> objects = [];
  late AnimationController gameLoopController;
  int objectIdCounter = 0;

  @override
  void initState() {
    super.initState();
    gameLoopController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..addListener(() {
      if (isGameRunning) {
        updateGame();
      }
    });
    gameLoopController.repeat();
    
    // Spawn objects periodically
    spawnObjects();
  }

  void spawnObjects() {
    Future.delayed(Duration(milliseconds: 800), () {
      if (!isGameRunning) return;
      
      setState(() {
        if (objects.length < 8) {
          final position = Offset(
            random.nextDouble() * (MediaQuery.of(context).size.width - 60),
            50.0,
          );
          objects.add(AnimatedObject(
            id: objectIdCounter++,
            position: position,
            animationController: AnimationController(
              vsync: this,
              duration: const Duration(seconds: 3),
            )..forward(),
          ));
        }
      });
      
      if (isGameRunning) {
        spawnObjects();
      }
    });
  }

  void updateGame() {
    if (!isGameRunning) return;
    
    setState(() {
      for (int i = objects.length - 1; i >= 0; i--) {
        final obj = objects[i];
        obj.position = Offset(
          obj.position.dx,
          obj.position.dy + 3,
        );
        
        // Check if object reached bottom
        if (obj.position.dy > MediaQuery.of(context).size.height - 100) {
          objects.removeAt(i);
          misses++;
          if (misses >= 10) {
            endGame();
          }
        }
      }
    });
  }

  void catchObject(AnimatedObject object) {
    if (!isGameRunning) return;
    
    setState(() {
      objects.remove(object);
      score++;
      
      // Visual feedback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('+1 Point!', textAlign: TextAlign.center),
          duration: const Duration(milliseconds: 200),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void endGame() {
    setState(() {
      isGameRunning = false;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Game Over!'),
        content: Text('Your Score: $score\nMisses: $misses'),
        actions: [
          ElevatedButton(
            onPressed: () {
              resetGame();
              Navigator.pop(context);
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      score = 0;
      misses = 0;
      isGameRunning = true;
      objects.clear();
      objectIdCounter = 0;
    });
    spawnObjects();
  }

  @override
  void dispose() {
    for (var obj in objects) {
      obj.animationController.dispose();
    }
    gameLoopController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          // Check if tap hits any object
          for (var obj in objects.reversed) {
            final tapPosition = details.localPosition;
            if (tapPosition.dx >= obj.position.dx &&
                tapPosition.dx <= obj.position.dx + 60 &&
                tapPosition.dy >= obj.position.dy &&
                tapPosition.dy <= obj.position.dy + 60) {
              catchObject(obj);
              break;
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.deepPurple.shade700, Colors.purple.shade300],
            ),
          ),
          child: Column(
            children: [
              // Score Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Text('SCORE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('$score', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.yellow)),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('MISSES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('$misses/10', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Game Area
              Expanded(
                child: Stack(
                  children: objects.map((obj) {
                    return Positioned(
                      left: obj.position.dx,
                      top: obj.position.dy,
                      child: GestureDetector(
                        onTap: () => catchObject(obj),
                        child: AnimatedBuilder(
                          animation: obj.animationController,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 0.8 + (obj.animationController.value * 0.4),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    colors: [
                                      Colors.orange.shade400,
                                      Colors.red.shade600,
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.yellow.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(Icons.star, color: Colors.white, size: 30),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Instructions
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white),
                    SizedBox(width: 10),
                    Text('Tap on the moving stars to catch them!', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
