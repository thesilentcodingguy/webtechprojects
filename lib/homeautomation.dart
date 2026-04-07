import 'package:flutter/material.dart';

void main() {
  runApp(const HomeAutomationApp());
}

class HomeAutomationApp extends StatelessWidget {
  const HomeAutomationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Home Automation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      debugShowCheckedModeBanner: false,
      home: const AutomationHomePage(),
    );
  }
}

class AutomationHomePage extends StatefulWidget {
  const AutomationHomePage({super.key});

  @override
  State<AutomationHomePage> createState() => _AutomationHomePageState();
}

class _AutomationHomePageState extends State<AutomationHomePage> {
  // --- AC Control ---
  double _acTemperature = 22.0;
  bool _acPower = false;

  // --- TV Control ---
  int _tvChannel = 1;
  int _tvVolume = 15;
  bool _tvPower = false;

  // --- Fan Control ---
  int _fanSpeed = 0; // 0=off, 1=low, 2=medium, 3=high
  bool _fanOscillate = false;

  // --- Light Control ---
  double _lightBrightness = 0.0;
  Color _lightColor = Colors.white;
  bool _lightPower = false;

  // --- Additional State for Animations ---
  String _globalFeedback = "Use gestures to control your home!";
  double _gesturePanX = 0.0;

  // --- AC Methods ---
  void _toggleAC() {
    setState(() {
      _acPower = !_acPower;
      _globalFeedback = _acPower ? "AC turned ON" : "AC turned OFF";
    });
    _resetFeedback();
  }

  void _increaseAC() {
    if (_acPower) {
      setState(() {
        _acTemperature = (_acTemperature + 1).clamp(16, 30);
        _globalFeedback = "AC Temp: ${_acTemperature.toStringAsFixed(0)}°C";
      });
    } else {
      setState(() {
        _globalFeedback = "Turn ON AC first! (Tap power icon)";
      });
      _resetFeedback();
    }
  }

  void _decreaseAC() {
    if (_acPower) {
      setState(() {
        _acTemperature = (_acTemperature - 1).clamp(16, 30);
        _globalFeedback = "AC Temp: ${_acTemperature.toStringAsFixed(0)}°C";
      });
    } else {
      setState(() {
        _globalFeedback = "Turn ON AC first!";
      });
      _resetFeedback();
    }
  }

  void _acSwipeLeft() {
    if (_acPower) {
      setState(() {
        _acTemperature = (_acTemperature - 2).clamp(16, 30);
        _globalFeedback = "❄️ Swipe left: Cooled to ${_acTemperature.toStringAsFixed(0)}°C";
      });
      _resetFeedback();
    }
  }

  void _acSwipeRight() {
    if (_acPower) {
      setState(() {
        _acTemperature = (_acTemperature + 2).clamp(16, 30);
        _globalFeedback = "🔥 Swipe right: Warmed to ${_acTemperature.toStringAsFixed(0)}°C";
      });
      _resetFeedback();
    }
  }

  // --- TV Methods ---
  void _toggleTV() {
    setState(() {
      _tvPower = !_tvPower;
      _globalFeedback = _tvPower ? "TV turned ON" : "TV turned OFF";
    });
    _resetFeedback();
  }

  void _channelUp() {
    if (_tvPower) {
      setState(() {
        _tvChannel = (_tvChannel % 100) + 1;
        _globalFeedback = "📺 Channel: $_tvChannel";
      });
      _resetFeedback();
    }
  }

  void _channelDown() {
    if (_tvPower) {
      setState(() {
        _tvChannel = _tvChannel > 1 ? _tvChannel - 1 : 100;
        _globalFeedback = "📺 Channel: $_tvChannel";
      });
      _resetFeedback();
    }
  }

  void _volumeUp() {
    if (_tvPower) {
      setState(() {
        _tvVolume = (_tvVolume + 5).clamp(0, 100);
        _globalFeedback = "🔊 Volume: $_tvVolume";
      });
      _resetFeedback();
    }
  }

  void _volumeDown() {
    if (_tvPower) {
      setState(() {
        _tvVolume = (_tvVolume - 5).clamp(0, 100);
        _globalFeedback = "🔉 Volume: $_tvVolume";
      });
      _resetFeedback();
    }
  }

  void _tvLongPress() {
    if (_tvPower) {
      setState(() {
        _tvChannel = 1;
        _tvVolume = 15;
        _globalFeedback = "📺 TV Reset to default!";
      });
      _resetFeedback();
    }
  }

  void _tvDoubleTap() {
    if (_tvPower) {
      setState(() {
        _tvVolume = (_tvVolume + 10).clamp(0, 100);
        _globalFeedback = "⚡ Double Tap: Volume boost! $_tvVolume";
      });
      _resetFeedback();
    }
  }

  // --- Fan Methods ---
  void _fanSwipeUp() {
    setState(() {
      _fanSpeed = (_fanSpeed + 1) % 4;
      if (_fanSpeed == 0) {
        _globalFeedback = "Fan OFF";
      } else if (_fanSpeed == 1) {
        _globalFeedback = "🌀 Fan Speed: Low";
      } else if (_fanSpeed == 2) {
        _globalFeedback = "🌀 Fan Speed: Medium";
      } else {
        _globalFeedback = "🌀 Fan Speed: High";
      }
    });
    _resetFeedback();
  }

  void _fanSwipeDown() {
    setState(() {
      _fanSpeed = (_fanSpeed - 1) % 4;
      if (_fanSpeed < 0) _fanSpeed = 3;
      if (_fanSpeed == 0) {
        _globalFeedback = "Fan OFF";
      } else if (_fanSpeed == 1) {
        _globalFeedback = "🌀 Fan Speed: Low";
      } else if (_fanSpeed == 2) {
        _globalFeedback = "🌀 Fan Speed: Medium";
      } else {
        _globalFeedback = "🌀 Fan Speed: High";
      }
    });
    _resetFeedback();
  }

  void _toggleOscillate() {
    if (_fanSpeed > 0) {
      setState(() {
        _fanOscillate = !_fanOscillate;
        _globalFeedback = _fanOscillate ? "Fan Oscillation ON" : "Fan Oscillation OFF";
      });
      _resetFeedback();
    } else {
      setState(() {
        _globalFeedback = "Turn ON fan first! (Swipe up)";
      });
      _resetFeedback();
    }
  }

  void _fanLongPress() {
    setState(() {
      _fanSpeed = 2; // Medium speed on long press
      _fanOscillate = true;
      _globalFeedback = "✨ Fan set to Medium + Oscillation";
    });
    _resetFeedback();
  }

  // --- Light Methods ---
  void _toggleLight() {
    setState(() {
      _lightPower = !_lightPower;
      _globalFeedback = _lightPower ? "Light ON" : "Light OFF";
    });
    _resetFeedback();
  }

  void _lightPanUpdate(DragUpdateDetails details) {
    if (_lightPower) {
      setState(() {
        _gesturePanX += details.delta.dx;
        double newBrightness = (_gesturePanX / 300).clamp(0.0, 1.0);
        _lightBrightness = newBrightness;
        _globalFeedback = "💡 Brightness: ${(_lightBrightness * 100).toInt()}%";
      });
    }
  }

  void _lightPanEnd(DragEndDetails details) {
    _gesturePanX = _lightBrightness * 300;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _globalFeedback = "Light controlled by pan gesture!";
        });
        _resetFeedback();
      }
    });
  }

  void _lightDoubleTap() {
    if (_lightPower) {
      setState(() {
        _lightBrightness = 1.0;
        _gesturePanX = 300;
        _globalFeedback = "✨ Double Tap: Max Brightness!";
      });
      _resetFeedback();
    }
  }

  void _lightLongPress() {
    setState(() {
      _lightPower = true;
      _lightBrightness = 0.5;
      _lightColor = Colors.amber;
      _gesturePanX = 150;
      _globalFeedback = "🎨 Light set to cozy warm!";
    });
    _resetFeedback();
  }

  void _lightHorizontalSwipe(String direction) {
    if (_lightPower) {
      setState(() {
        if (direction == 'left') {
          _lightBrightness = (_lightBrightness - 0.2).clamp(0.0, 1.0);
          _globalFeedback = "⬅️ Dimming: ${(_lightBrightness * 100).toInt()}%";
        } else {
          _lightBrightness = (_lightBrightness + 0.2).clamp(0.0, 1.0);
          _globalFeedback = "➡️ Brightening: ${(_lightBrightness * 100).toInt()}%";
        }
        _gesturePanX = _lightBrightness * 300;
      });
      _resetFeedback();
    }
  }

  void _resetFeedback() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _globalFeedback = "Ready for gestures!";
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        title: const Text('🏠 Gesture Home Automation'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Global feedback bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.blue.shade700,
            child: Text(
              _globalFeedback,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // AC Control Card
                _buildACCard(),
                const SizedBox(height: 16),
                // TV Control Card
                _buildTVCard(),
                const SizedBox(height: 16),
                // Fan Control Card
                _buildFanCard(),
                const SizedBox(height: 16),
                // Light Control Card
                _buildLightCard(),
                const SizedBox(height: 16),
                // Gesture Legend
                _buildGestureLegend(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildACCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.blue.shade900.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.ac_unit, size: 32, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Air Conditioner',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleAC,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _acPower ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _acPower ? Icons.power_settings_new : Icons.power_off,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_acPower) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Temperature', style: TextStyle(fontSize: 16)),
                  Text(
                    '${_acTemperature.toStringAsFixed(0)}°C',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              Slider(
                value: _acTemperature,
                min: 16,
                max: 30,
                divisions: 14,
                onChanged: _acPower ? (v) => setState(() => _acTemperature = v) : null,
                activeColor: Colors.blue,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGestureButton(Icons.arrow_left, 'Swipe Left', _acSwipeLeft),
                  _buildGestureButton(Icons.arrow_right, 'Swipe Right', _acSwipeRight),
                  _buildGestureButton(Icons.remove, 'Tap -1°C', _decreaseAC),
                  _buildGestureButton(Icons.add, 'Tap +1°C', _increaseAC),
                ],
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Tap power button to turn ON', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTVCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.purple.shade900.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.tv, size: 32, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Smart TV',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleTV,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _tvPower ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _tvPower ? Icons.power_settings_new : Icons.power_off,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tvPower) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      const Text('Channel', style: TextStyle(fontSize: 14)),
                      Text(
                        '$_tvChannel',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Volume', style: TextStyle(fontSize: 14)),
                      Text(
                        '$_tvVolume',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGestureButton(Icons.arrow_downward, 'Ch -', _channelDown),
                  _buildGestureButton(Icons.arrow_upward, 'Ch +', _channelUp),
                  _buildGestureButton(Icons.volume_down, 'Vol -', _volumeDown),
                  _buildGestureButton(Icons.volume_up, 'Vol +', _volumeUp),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGestureButton(Icons.touch_app, 'Double Tap\n(Vol Boost)', _tvDoubleTap, isDoubleTap: true),
                  _buildGestureButton(Icons.fiber_manual_record, 'Long Press\n(Reset)', _tvLongPress, isLongPress: true),
                ],
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Tap power button to turn ON', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFanCard() {
    String speedText = 'OFF';
    Color speedColor = Colors.grey;
    if (_fanSpeed == 1) {
      speedText = 'LOW';
      speedColor = Colors.green;
    } else if (_fanSpeed == 2) {
      speedText = 'MEDIUM';
      speedColor = Colors.orange;
    } else if (_fanSpeed == 3) {
      speedText = 'HIGH';
      speedColor = Colors.red;
    }

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.teal.shade900.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.toys, size: 32, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Ceiling Fan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text('Speed', style: TextStyle(fontSize: 14)),
                    Text(
                      speedText,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: speedColor),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _toggleOscillate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _fanOscillate ? Colors.blue : Colors.grey,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(_fanOscillate ? Icons.sync : Icons.sync_disabled, size: 20),
                        const SizedBox(width: 4),
                        Text(_fanOscillate ? 'Oscillating' : 'Oscillate OFF'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGestureButton(Icons.swipe_up, 'Swipe Up\n(Speed+)', _fanSwipeUp),
                _buildGestureButton(Icons.swipe_down, 'Swipe Down\n(Speed-)', _fanSwipeDown),
                _buildGestureButton(Icons.touch_app, 'Long Press\n(Medium+Osc)', _fanLongPress, isLongPress: true),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: GestureDetector(
                onTap: _toggleOscillate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Tap to Toggle Oscillation'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: Colors.amber.shade900.withOpacity(0.8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, size: 32, color: Colors.white),
                const SizedBox(width: 12),
                const Text(
                  'Smart Light',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _toggleLight,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _lightPower ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Icon(
                      _lightPower ? Icons.power_settings_new : Icons.power_off,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_lightPower) ...[
              Container(
                height: 100,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _lightColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _lightColor.withOpacity(_lightBrightness),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.lightbulb,
                    size: 50,
                    color: _lightColor.withOpacity(_lightBrightness),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Brightness', style: TextStyle(fontSize: 14)),
                  Text('${(_lightBrightness * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              Slider(
                value: _lightBrightness,
                onChanged: (v) => setState(() => _lightBrightness = v),
                activeColor: Colors.amber,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGestureButton(Icons.swipe, 'Swipe Left/Right\n(Brightness)', () => _lightHorizontalSwipe('left'), extraAction: () => _lightHorizontalSwipe('right')),
                  _buildGestureButton(Icons.touch_app, 'Double Tap\n(Max Brightness)', _lightDoubleTap, isDoubleTap: true),
                  _buildGestureButton(Icons.fiber_manual_record, 'Long Press\n(Warm Light)', _lightLongPress, isLongPress: true),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 60,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: GestureDetector(
                  onPanUpdate: _lightPanUpdate,
                  onPanEnd: _lightPanEnd,
                  child: const Center(
                    child: Text(
                      '← Pan horizontally to dim/brighten →',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ] else ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Tap power button to turn ON', style: TextStyle(fontSize: 14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGestureButton(IconData icon, String label, VoidCallback onTap, {bool isDoubleTap = false, bool isLongPress = false, VoidCallback? extraAction}) {
    return GestureDetector(
      onTap: isDoubleTap ? null : onTap,
      onDoubleTap: isDoubleTap ? onTap : null,
      onLongPress: isLongPress ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGestureLegend() {
    return Card(
      elevation: 4,
      color: Colors.grey.shade800,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🎮 Gesture Controls Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: const [
                Text('• Tap: Power/Adjust'),
                Text('• Double Tap: Boost/Reset'),
                Text('• Long Press: Special modes'),
                Text('• Swipe: Temp/Speed'),
                Text('• Pan: Light brightness'),
                Text('• Slider: Fine control'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
