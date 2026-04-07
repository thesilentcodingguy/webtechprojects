import 'package:flutter/material.dart';

void main() {
  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gesture Food Delivery',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: const FoodScreen(),
    );
  }
}

class FoodScreen extends StatefulWidget {
  const FoodScreen({super.key});

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  int statusIndex = 0;
  double scale = 1.0;

  final List<String> statuses = [
    "Order Placed",
    "Preparing Food",
    "Out for Delivery",
    "Arriving Soon",
    "Delivered"
  ];

  final List<int> etaMinutes = [30, 25, 15, 5, 0];

  void nextStatus() {
    if (statusIndex < statuses.length - 1) {
      setState(() => statusIndex++);
    }
  }

  void reorder() {
    setState(() {
      statusIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Reordered your favorite food!")),
    );
  }

  void cancelOrder() {
    setState(() {
      statusIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Order Cancelled")),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress = (statusIndex + 1) / statuses.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Delivery Tracker"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (_) => nextStatus(),
        onDoubleTap: reorder,
        onLongPress: cancelOrder,
        onScaleUpdate: (details) {
          setState(() {
            scale = details.scale.clamp(1.0, 4.0);
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// 🍔 Food Card
            Card(
              margin: const EdgeInsets.all(16),
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(Icons.fastfood,
                        size: 50, color: Colors.orange),
                    const SizedBox(height: 10),
                    const Text(
                      "Cheese Burger",
                      style:
                      TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      statuses[statusIndex],
                      style: const TextStyle(
                          fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "ETA: ${etaMinutes[statusIndex]} mins",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),

            /// 📊 Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            const SizedBox(height: 30),

            /// 🗺️ Delivery Map (Zoomable)
            const Text("Pinch to Zoom Delivery Location"),
            const SizedBox(height: 10),
            Transform.scale(
              scale: scale,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  "https://maps.gstatic.com/tactile/basepage/pegman_sherlock.png",
                  height: 150,
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// 📝 Instructions
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                "👉 Swipe → Next Status\n"
                    "👆 Double Tap → Reorder\n"
                    "✋ Long Press → Cancel\n"
                    "🤏 Pinch → Zoom Map",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }
}
