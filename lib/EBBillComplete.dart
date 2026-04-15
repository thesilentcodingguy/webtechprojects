import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Electricity Bill Calculator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const BillCalculatorScreen(),
    );
  }
}

class BillCalculatorScreen extends StatefulWidget {
  const BillCalculatorScreen({super.key});

  @override
  State<BillCalculatorScreen> createState() => _BillCalculatorScreenState();
}

class _BillCalculatorScreenState extends State<BillCalculatorScreen> {
  // Appliance data
  final List<Appliance> appliances = [
    Appliance(name: 'Fan', basePower: 75, icon: Icons.add_card_rounded),
    Appliance(name: 'AC', basePower: 1500, icon: Icons.ac_unit),
    Appliance(name: 'Refrigerator', basePower: 200, icon: Icons.kitchen),
    Appliance(name: 'Washing Machine', basePower: 500, icon: Icons.local_laundry_service),
  ];

  // Selected appliance index
  int selectedApplianceIndex = 0;

  // User input values
  double power = 75.0;      // Watts
  double usage = 8.0;       // Hours per day
  double days = 30.0;       // Days per month
  double cost = 7.0;        // Cost per unit (Rs/kWh)

  // Energy calculation results
  double energyUsed = 0.0;    // kWh per month
  double monthlyBill = 0.0;   // Rs
  double yearlyProjection = 0.0; // Rs

  // Counter for animation effect
  int counterValue = 0;
  static const int maxCounter = 999;

  @override
  void initState() {
    super.initState();
    updateCalculations();
  }

  void updateCalculations() {
    setState(() {
      // Energy used (kWh) = (Power in Watts * Hours per day * Days) / 1000
      energyUsed = (power * usage * days) / 1000;

      // Monthly bill = Energy used * Cost per unit
      monthlyBill = energyUsed * cost;

      // Yearly projection = Monthly bill * 12
      yearlyProjection = monthlyBill * 12;

      // Update counter (increment effect)
      if (counterValue < maxCounter) {
        counterValue = (energyUsed * 10).toInt().clamp(0, maxCounter);
      }
    });
  }

  void onSliderChange() {
    updateCalculations();
  }

  void onApplianceChange(int? index) {
    if (index != null && index != selectedApplianceIndex) {
      setState(() {
        selectedApplianceIndex = index;
        power = appliances[index].basePower.toDouble();
      });
      updateCalculations();
    }
  }

  Color getUsageColor() {
    double avgMonthlyUsage = energyUsed;
    if (avgMonthlyUsage >= 300) return Colors.red;
    if (avgMonthlyUsage >= 150) return Colors.orange;
    return Colors.green;
  }

  String getUsageLabel() {
    double avgMonthlyUsage = energyUsed;
    if (avgMonthlyUsage >= 300) return 'High Usage';
    if (avgMonthlyUsage >= 150) return 'Medium Usage';
    return 'Low Usage';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.grey.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                floating: false,
                pinned: true,
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Electricity Bill Calculator',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.green.shade700, Colors.green.shade900],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.electric_bolt, size: 50, color: Colors.white70),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        power = appliances[selectedApplianceIndex].basePower.toDouble();
                        usage = 8.0;
                        days = 30.0;
                        cost = 7.0;
                      });
                      updateCalculations();
                    },
                    tooltip: 'Reset to defaults',
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Appliance Dropdown
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Select Appliance',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              DropdownButtonFormField<int>(
                                value: selectedApplianceIndex,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  prefixIcon: Icon(appliances[selectedApplianceIndex].icon),
                                ),
                                items: appliances.asMap().entries.map((entry) {
                                  int idx = entry.key;
                                  Appliance app = entry.value;
                                  return DropdownMenuItem<int>(
                                    value: idx,
                                    child: Row(
                                      children: [
                                        Icon(app.icon, size: 20),
                                        const SizedBox(width: 12),
                                        Text(app.name),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: onApplianceChange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Power Slider
                      _buildSliderCard(
                        title: 'Power (Watts)',
                        icon: Icons.flash_on,
                        value: power,
                        min: 10,
                        max: 2500,
                        unit: 'W',
                        onChanged: (val) {
                          setState(() => power = val);
                          onSliderChange();
                        },
                      ),

                      // Usage Slider (Hours per day)
                      _buildSliderCard(
                        title: 'Daily Usage',
                        icon: Icons.schedule,
                        value: usage,
                        min: 0.5,
                        max: 24,
                        unit: 'hours/day',
                        onChanged: (val) {
                          setState(() => usage = val);
                          onSliderChange();
                        },
                      ),

                      // Days Slider
                      _buildSliderCard(
                        title: 'Days per Month',
                        icon: Icons.calendar_today,
                        value: days,
                        min: 1,
                        max: 30,
                        unit: 'days',
                        onChanged: (val) {
                          setState(() => days = val);
                          onSliderChange();
                        },
                      ),

                      // Cost Slider
                      _buildSliderCard(
                        title: 'Electricity Cost',
                        icon: Icons.currency_rupee,
                        value: cost,
                        min: 2,
                        max: 15,
                        unit: 'Rs/kWh',
                        onChanged: (val) {
                          setState(() => cost = val);
                          onSliderChange();
                        },
                      ),

                      const SizedBox(height: 24),

                      // Energy Meter Card
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              colors: [
                                getUsageColor().withOpacity(0.1),
                                getUsageColor().withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Energy Meter',
                                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: getUsageColor(),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        getUsageLabel(),
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Animated Energy Used
                                _buildMetricRow(
                                  'Energy Used (Monthly)',
                                  '${energyUsed.toStringAsFixed(1)} kWh',
                                  Icons.energy_savings_leaf,
                                  getUsageColor(),
                                ),
                                const Divider(height: 32),

                                // Monthly Bill
                                _buildMetricRow(
                                  'Monthly Bill',
                                  '₹ ${monthlyBill.toStringAsFixed(2)}',
                                  Icons.receipt,
                                  Colors.blue.shade700,
                                ),
                                const Divider(height: 32),

                                // Yearly Projection
                                _buildMetricRow(
                                  'Yearly Projection',
                                  '₹ ${yearlyProjection.toStringAsFixed(2)}',
                                  Icons.trending_up,
                                  Colors.purple.shade700,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Counter Animation Card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              const Text(
                                'Energy Counter (kWh x 10)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 12),
                              TweenAnimationBuilder<int>(
                                tween: IntTween(begin: 0, end: counterValue),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, value, child) {
                                  return Text(
                                    value.toString().padLeft(3, '0'),
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      color: getUsageColor(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              LinearProgressIndicator(
                                value: counterValue / maxCounter,
                                backgroundColor: Colors.grey.shade200,
                                color: getUsageColor(),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Max: $maxCounter',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 80), // Extra padding at bottom
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

  Widget _buildSliderCard({
    required String title,
    required IconData icon,
    required double value,
    required double min,
    required double max,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${value.toStringAsFixed(1)} $unit',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min) ~/ 0.5 > 100 ? 100 : ((max - min) * 2).toInt(),
              activeColor: Colors.green.shade700,
              label: '$value $unit',
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class Appliance {
  final String name;
  final int basePower;
  final IconData icon;

  Appliance({
    required this.name,
    required this.basePower,
    required this.icon,
  });
}
