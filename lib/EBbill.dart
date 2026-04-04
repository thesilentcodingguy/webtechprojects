import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ElectricityCalculator(),
    );
  }
}

class ElectricityCalculator extends StatefulWidget {
  const ElectricityCalculator({super.key});

  @override
  State<ElectricityCalculator> createState() =>
      _ElectricityCalculatorState();
}

class _ElectricityCalculatorState extends State<ElectricityCalculator> {
  String selectedAppliance = "Fan";

  final Map<String, double> appliancePower = {
    "Fan": 75,
    "AC": 1500,
    "Refrigerator": 300,
    "Washing Machine": 500,
  };

  double power = 75;
  double hours = 5;
  double days = 30;
  double costPerUnit = 6;

  double energy = 0;
  double monthlyBill = 0;
  double yearlyBill = 0;

  @override
  void initState() {
    super.initState();
    calculate();
  }

  void calculate() {
    energy = (power * hours * days) / 1000;
    monthlyBill = energy * costPerUnit;
    yearlyBill = monthlyBill * 12;
    setState(() {});
  }

  Color getUsageColor() {
    if (energy > 300) return Colors.red;
    if (energy > 150) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Electricity Calculator"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// Dropdown
            DropdownButton<String>(
              dropdownColor: Colors.grey[900],
              value: selectedAppliance,
              items: appliancePower.keys.map((e) {
                return DropdownMenuItem(
                  value: e,
                  child: Text(e, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                selectedAppliance = value!;
                power = appliancePower[value]!;
                calculate();
              },
            ),

            const SizedBox(height: 20),

            /// Power Input
            buildInput("Power (Watts)", power, (val) {
              power = val;
              calculate();
            }),

            /// Days Input
            buildInput("Days", days, (val) {
              days = val;
              calculate();
            }),

            /// Cost Input
            buildInput("Cost per unit", costPerUnit, (val) {
              costPerUnit = val;
              calculate();
            }),

            const SizedBox(height: 20),

            /// Slider (Usage hours)
            Column(
              children: [
                const Text("Usage Hours",
                    style: TextStyle(color: Colors.white)),
                Slider(
                  value: hours,
                  min: 1,
                  max: 24,
                  divisions: 23,
                  label: hours.toStringAsFixed(0),
                  onChanged: (val) {
                    hours = val;
                    calculate();
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Energy Meter Display
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: getUsageColor(),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text("Energy Used: ${energy.toStringAsFixed(2)} kWh"),
                  Text("Monthly Bill: ₹${monthlyBill.toStringAsFixed(2)}"),
                  Text("Yearly: ₹${yearlyBill.toStringAsFixed(2)}"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Graph
            SizedBox(
              height: 200,
              child: CustomPaint(
                painter: UsageGraphPainter(hours, energy),
                child: Container(),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget buildInput(String label, double value, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        keyboardType: TextInputType.number,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
          border: const OutlineInputBorder(),
        ),
        onChanged: (val) {
          onChanged(double.tryParse(val) ?? value);
        },
      ),
    );
  }
}

/// ================= GRAPH SECTION =================
///
/// This is a reusable Custom Painter graph
///
/// HOW IT WORKS:
/// - We manually draw graph using Canvas
/// - X axis → Hours
/// - Y axis → Energy
///
/// WHY THIS IS IMPORTANT:
/// - You can reuse this in ANY Flutter app
/// - No external library needed
/// - Full control over UI
///
/// STEPS:
/// 1. Draw axes
/// 2. Generate points
/// 3. Connect with lines
///
/// Replace "energy formula" → you can reuse for:
/// - Stock charts
/// - Fitness tracking
/// - App analytics
///
class UsageGraphPainter extends CustomPainter {
  final double hours;
  final double energy;

  UsageGraphPainter(this.hours, this.energy);

  @override
  void paint(Canvas canvas, Size size) {
    final paintAxis = Paint()
      ..color = Colors.white
      ..strokeWidth = 2;

    final paintLine = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3;

    /// Draw X and Y axis
    canvas.drawLine(
        Offset(30, size.height - 20),
        Offset(size.width, size.height - 20),
        paintAxis);

    canvas.drawLine(
        const Offset(30, 0),
        Offset(30, size.height - 20),
        paintAxis);

    /// Generate graph points
    ///
    /// We simulate energy growth with hours
    /// You can replace formula with real dataset
    List<Offset> points = [];

    for (int i = 1; i <= hours.toInt(); i++) {
      double x = 30 + (i * (size.width - 40) / 24);
      double y = size.height -
          20 -
          ((energy * (i / hours)) % size.height);

      points.add(Offset(x, y));
    }

    /// Draw lines between points
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(points[i], points[i + 1], paintLine);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
