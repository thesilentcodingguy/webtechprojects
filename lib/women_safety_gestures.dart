import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SafetyApp(),
  ));
}

class SafetyApp extends StatefulWidget {
  const SafetyApp({super.key});

  @override
  State<SafetyApp> createState() => _SafetyAppState();
}

class _SafetyAppState extends State<SafetyApp> {
  // Shake detection
  double lastX = 0, lastY = 0, lastZ = 0;
  int shakeCount = 0;
  DateTime lastShake = DateTime.now();

  // Tap detection
  int tapCount = 0;
  Timer? tapTimer;

  // Modes
  bool silentMode = false;
  bool tracking = false;

  // Data
  String location = "Lat: 11.01, Lon: 77.02";
  List<String> alertHistory = [];

  OverlayEntry? banner;

  List<Map<String, String>> nearby = [
    {"name": "City Police Station", "type": "Police"},
    {"name": "Apollo Hospital", "type": "Hospital"},
    {"name": "Emergency Care Center", "type": "Hospital"},
  ];

  /* ---------------------- CORE FEATURES ---------------------- */

  void triggerSOS() {
    String msg = "🚨 SOS SENT\n$location";
    alertHistory.insert(0, msg);
    showBanner(msg);
  }

  void fakeCall() {
    showBanner("📞 Incoming Call... (Fake)");
  }

  void shareLocation() {
    showBanner("📤 Location Shared\n$location");
  }

  void toggleTracking() {
    setState(() {
      tracking = !tracking;
    });

    showBanner(tracking ? "📡 Live Tracking ON" : "📡 Tracking OFF");
  }

  void toggleSilentMode() {
    setState(() {
      silentMode = !silentMode;
    });

    showBanner(silentMode ? "🔇 Silent Mode ON" : "🔊 Silent Mode OFF");
  }

  /* ---------------------- GESTURES ---------------------- */

  void handleTap() {
    tapCount++;
    tapTimer?.cancel();

    tapTimer = Timer(const Duration(milliseconds: 600), () {
      tapCount = 0;
    });

    if (tapCount == 3) {
      triggerSOS(); // triple tap
      tapCount = 0;
    }
  }

  void handleLongPress() {
    toggleSilentMode(); // long press
  }

  void handleDoubleTap() {
    fakeCall(); // double tap
  }

  void handleSwipeUp() {
    shareLocation(); // swipe up
  }

  void handleSwipeDown() {
    triggerSOS(); // swipe down
  }

  /* ---------------------- SHAKE (SIMULATED) ---------------------- */

  void simulateShake() {
    double x = Random().nextDouble() * 20;
    double y = Random().nextDouble() * 20;
    double z = Random().nextDouble() * 20;

    double delta = (x + y + z) - (lastX + lastY + lastZ);

    if (delta.abs() > 25) {
      if (DateTime.now().difference(lastShake).inMilliseconds > 500) {
        shakeCount++;
        lastShake = DateTime.now();
      }
    }

    if (shakeCount >= 2) {
      triggerSOS();
      shakeCount = 0;
    }

    lastX = x;
    lastY = y;
    lastZ = z;
  }

  /* ---------------------- LOCATION ---------------------- */

  void updateLocation() {
    setState(() {
      location =
      "Lat: ${(11 + Random().nextDouble()).toStringAsFixed(4)}, "
          "Lon: ${(77 + Random().nextDouble()).toStringAsFixed(4)}";
    });

    showBanner("📍 Location Updated\n$location");
  }

  /* ---------------------- UI UTIL ---------------------- */

  void showBanner(String message) {
    if (!mounted) return;

    banner?.remove();

    final overlay = Overlay.of(context, rootOverlay: true);
    if (overlay == null) return;

    banner = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.black87,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(banner!);

    Future.delayed(const Duration(seconds: 3), () {
      banner?.remove();
      banner = null;
    });
  }

  /* ---------------------- BUILD ---------------------- */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Women Safety")),

      body: GestureDetector(
        onTap: handleTap,
        onDoubleTap: handleDoubleTap,
        onLongPress: handleLongPress,
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            handleSwipeUp(); // swipe up
          } else {
            handleSwipeDown(); // swipe down
          }
        },

        child: Column(
          children: [
            const SizedBox(height: 20),

            Text("Location: $location"),

            ElevatedButton(
              onPressed: updateLocation,
              child: const Text("Update Location"),
            ),

            ElevatedButton(
              onPressed: toggleTracking,
              child: Text(tracking ? "Stop Tracking" : "Start Tracking"),
            ),

            ElevatedButton(
              onPressed: fakeCall,
              child: const Text("Fake Call"),
            ),

            ElevatedButton(
              onPressed: shareLocation,
              child: const Text("Share Location"),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              color: silentMode ? Colors.red : Colors.grey,
              child: const Text(
                "Long Press Anywhere → Silent Mode\n"
                    "Triple Tap → SOS\n"
                    "Double Tap → Fake Call\n"
                    "Swipe Up → Share Location\n"
                    "Swipe Down → SOS",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 10),

            const Text("Nearby Help"),

            Expanded(
              child: ListView.builder(
                itemCount: nearby.length,
                itemBuilder: (_, i) {
                  var place = nearby[i];
                  return ListTile(
                    leading: Icon(
                      place["type"] == "Police"
                          ? Icons.local_police
                          : Icons.local_hospital,
                    ),
                    title: Text(place["name"]!),
                    subtitle: Text(place["type"]!),
                  );
                },
              ),
            ),

            const Divider(),

            const Text("Alert History"),

            Expanded(
              child: ListView.builder(
                itemCount: alertHistory.length,
                itemBuilder: (_, i) {
                  return ListTile(
                    title: Text(alertHistory[i]),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: simulateShake,
        child: const Icon(Icons.warning),
      ),
    );
  }
}
