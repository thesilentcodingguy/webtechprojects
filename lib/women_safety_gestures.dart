import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: SafetyApp()));
}

class SafetyApp extends StatefulWidget {
  @override
  State<SafetyApp> createState() => _SafetyAppState();
}

class _SafetyAppState extends State<SafetyApp> with SingleTickerProviderStateMixin {
  double lastX = 0, lastY = 0, lastZ = 0;
  int shakeCount = 0;
  DateTime lastShake = DateTime.now();
  int tapCount = 0;
  Timer? tapTimer;
  bool silentMode = false;

  String location = "Lat: 11.01, Lon: 77.02";

  OverlayEntry? banner;

  List<Map<String, String>> nearby = [
    {"name": "City Police Station", "type": "Police"},
    {"name": "Apollo Hospital", "type": "Hospital"},
    {"name": "Emergency Care Center", "type": "Hospital"},
  ];

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

  void handleTap() {
    tapCount++;
    tapTimer?.cancel();

    tapTimer = Timer(Duration(milliseconds: 600), () {
      tapCount = 0;
    });

    if (tapCount == 3) {
      triggerSOS();
      tapCount = 0;
    }
  }

  void triggerSOS() {
    showBanner("🚨 SOS Alert Sent!\nLocation: $location");
  }

  void toggleSilentMode() {
    setState(() {
      silentMode = !silentMode;
    });
    showBanner(silentMode ? "🔇 Silent Emergency Mode ON" : "🔊 Silent Mode OFF");
  }

  void showBanner(String message) {
    banner?.remove();

    banner = OverlayEntry(
      builder: (context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(16),
            color: Colors.black87,
            child: SafeArea(
              child: Text(message, style: TextStyle(color: Colors.white)),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(banner!);

    Future.delayed(Duration(seconds: 3), () {
      banner?.remove();
    });
  }

  void updateLocation() {
    setState(() {
      location = "Lat: ${11 + Random().nextDouble()}, Lon: ${77 + Random().nextDouble()}";
    });
    showBanner("📍 Location Updated\n$location");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Women Safety")),
      body: GestureDetector(
        onTap: handleTap,
        onDoubleTap: simulateShake,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Current Location", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text(location, style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: updateLocation,
              child: Text("Update Location"),
            ),
            SizedBox(height: 20),
            GestureDetector(
              onLongPress: toggleSilentMode,
              child: Container(
                padding: EdgeInsets.all(20),
                color: silentMode ? Colors.red : Colors.grey,
                child: Text(
                  "Hold for Silent Emergency",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text("Nearby Help", style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: nearby.length,
                itemBuilder: (_, i) {
                  var place = nearby[i];
                  return ListTile(
                    leading: Icon(
                      place["type"] == "Police" ? Icons.local_police : Icons.local_hospital,
                      color: place["type"] == "Police" ? Colors.blue : Colors.red,
                    ),
                    title: Text(place["name"]!),
                    subtitle: Text(place["type"]!),
                  );
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: simulateShake,
        child: Icon(Icons.warning),
      ),
    );
  }
}
