import 'package:flutter/material.dart';

void main() {
  runApp(const GestureDetectionApp());
}

class GestureDetectionApp extends StatelessWidget {
  const GestureDetectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Detection Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GestureHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GestureHomePage extends StatefulWidget {
  const GestureHomePage({super.key});

  @override
  State<GestureHomePage> createState() => _GestureHomePageState();
}

class _GestureHomePageState extends State<GestureHomePage> {
  // --- Weather-like Slider State (Color & Temperature) ---
  double _temperature = 22.0; // Celsius
  Color _backgroundColor = Colors.blue.shade200;

  // Update color based on temperature value
  void _updateTemperature(double value) {
    setState(() {
      _temperature = value;
      // Map temperature range 0-40 to colors: cold (blue) -> warm (orange) -> hot (red)
      if (_temperature < 15) {
        _backgroundColor = Colors.blue.shade300;
      } else if (_temperature < 25) {
        _backgroundColor = Colors.green.shade200;
      } else if (_temperature < 35) {
        _backgroundColor = Colors.orange.shade300;
      } else {
        _backgroundColor = Colors.red.shade300;
      }
    });
  }

  // --- Card 1: Tap, Double Tap, Long Press ---
  int _tapCount = 0;
  String _card1Feedback = "Tap, Double tap, or Long press me!";

  void _onCard1Tap() {
    setState(() {
      _tapCount++;
      _card1Feedback = "✨ Single tapped $_tapCount time(s)";
    });
  }

  void _onCard1DoubleTap() {
    setState(() {
      _card1Feedback = "⚡ Double tapped! Magic energy!";
      // Bonus: reset tap count for fun
      _tapCount = 0;
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _card1Feedback = "Tap, Double tap, or Long press me!";
          });
        }
      });
    });
  }

  void _onCard1LongPress() {
    setState(() {
      _card1Feedback = "🔥 Long pressed! You held me down!";
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _card1Feedback = "Tap, Double tap, or Long press me!";
        });
      }
    });
  }

  // --- Card 2: Horizontal Swipe (Left/Right) ---
  String _card2Feedback = "Swipe me left or right!";
  double _card2XOffset = 0.0;

  void _onHorizontalSwipe(String direction) {
    setState(() {
      _card2Feedback = direction == 'left'
          ? "👈 Swiped LEFT! Cool breeze."
          : "👉 Swiped RIGHT! Sunny side.";
      // Animate swipe effect
      _card2XOffset = direction == 'left' ? -200 : 200;
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _card2XOffset = 0.0;
        });
      }
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _card2Feedback = "Swipe me left or right!";
        });
      }
    });
  }

  // --- Card 3: Vertical Swipe (Up/Down) + Drag details ---
  String _card3Feedback = "Swipe up/down or drag me!";
  double _dragY = 0.0;

  void _onVerticalSwipe(String direction) {
    setState(() {
      _card3Feedback = direction == 'up'
          ? "⬆️ Swiped UP! Altitude increased."
          : "⬇️ Swiped DOWN! Dive deeper.";
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _card3Feedback = "Swipe up/down or drag me!";
        });
      }
    });
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      _dragY += details.delta.dy;
      _card3Feedback = "Dragging: ${_dragY.toStringAsFixed(1)}px vertically";
    });
  }

  void _onDragEnd(DragEndDetails details) {
    setState(() {
      _dragY = 0.0;
      _card3Feedback = "Drag ended! Try swiping too.";
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _card3Feedback = "Swipe up/down or drag me!";
        });
      }
    });
  }

  // --- Card 4: Combined Gestures (Scale, Rotate, Pan) ---
  String _card4Feedback = "Pinch, rotate, or pan me!";
  double _scale = 1.0;
  double _rotation = 0.0;
  Offset _panOffset = Offset.zero;

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      _scale = details.scale.clamp(0.5, 2.0);
      _rotation = details.rotation;
      _panOffset = details.focalPoint - details.localFocalPoint;
      _card4Feedback =
      "Scale: ${_scale.toStringAsFixed(2)} | Rotate: ${(_rotation * 57.3).toStringAsFixed(0)}°";
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      // Reset after a moment for clean UI
      _scale = 1.0;
      _rotation = 0.0;
      _panOffset = Offset.zero;
      _card4Feedback = "Reset! Pinch/rotate again?";
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _card4Feedback = "Pinch, rotate, or pan me!";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Gesture Detection Studio'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _backgroundColor.withOpacity(0.8),
              Colors.blue.shade900.withOpacity(0.9),
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                // --- Weather Slider (Color changing gesture) ---
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.thermostat, size: 32),
                            Text(
                              '${_temperature.toStringAsFixed(1)}°C',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              _temperature > 30
                                  ? Icons.wb_sunny
                                  : _temperature < 15
                                  ? Icons.ac_unit
                                  : Icons.cloud,
                              size: 32,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Slider(
                          value: _temperature,
                          min: 0,
                          max: 45,
                          divisions: 90,
                          label: _temperature.round().toString(),
                          onChanged: _updateTemperature,
                          activeColor: _temperature > 30
                              ? Colors.red
                              : _temperature < 15
                              ? Colors.blue
                              : Colors.green,
                        ),
                        const Text(
                          'Slide to change temperature & background color',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Card 1: Tap, Double Tap, Long Press ---
                GestureDetector(
                  onTap: _onCard1Tap,
                  onDoubleTap: _onCard1DoubleTap,
                  onLongPress: _onCard1LongPress,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.amber.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.touch_app, color: Colors.amber),
                              SizedBox(width: 8),
                              Text(
                                'Tap, Double Tap, Long Press',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _card1Feedback,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '(Try each gesture!)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Card 2: Horizontal Swipe ---
                Dismissible(
                  key: const Key('swipeCard'),
                  direction: DismissDirection.horizontal,
                  onDismissed: (direction) {
                    if (direction == DismissDirection.startToEnd) {
                      _onHorizontalSwipe('right');
                    } else {
                      _onHorizontalSwipe('left');
                    }
                  },
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.orange,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.arrow_forward, color: Colors.white),
                  ),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(_card2XOffset, 0, 0),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.lightBlue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.swipe, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Horizontal Swipe (Left/Right)',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _card2Feedback,
                              style: const TextStyle(fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Swipe card left or right',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Card 3: Vertical Swipe + Drag ---
                GestureDetector(
                  onVerticalDragUpdate: _onDragUpdate,
                  onVerticalDragEnd: _onDragEnd,
                  onPanUpdate: (details) {
                    // Also capture vertical swipe direction
                    if (details.delta.dy.abs() > 20) {
                      if (details.delta.dy > 0) {
                        _onVerticalSwipe('down');
                      } else {
                        _onVerticalSwipe('up');
                      }
                    }
                  },
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.swipe_vertical, color: Colors.teal),
                              SizedBox(width: 8),
                              Text(
                                'Vertical Swipe & Drag',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _card3Feedback,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Swipe up/down or drag vertically',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // --- Card 4: Scale, Rotate, Pan (Advanced) ---
                GestureDetector(
                  onScaleUpdate: _onScaleUpdate,
                  onScaleEnd: _onScaleEnd,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.purple.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.transform, color: Colors.purple),
                              SizedBox(width: 8),
                              Text(
                                'Pinch, Rotate & Pan',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..translate(_panOffset.dx, _panOffset.dy)
                              ..scale(_scale)
                              ..rotateZ(_rotation),
                            child: Container(
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.purple),
                              ),
                              child: const Center(
                                child: Text(
                                  '🤸‍♂️',
                                  style: TextStyle(fontSize: 48),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _card4Feedback,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Use two fingers to pinch, rotate, or pan',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Extra tip card
                Card(
                  color: Colors.grey.shade900,
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Icon(Icons.lightbulb, color: Colors.yellow),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Pro tip: Combine gestures! Use the slider for color change, tap cards, swipe, drag, pinch — all gestures are live.',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
