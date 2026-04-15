import 'package:flutter/material.dart';

void main() {
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Health Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const BMIDashboard(),
    );
  }
}

class BMIDashboard extends StatefulWidget {
  const BMIDashboard({super.key});

  @override
  State<BMIDashboard> createState() => _BMIDashboardState();
}

class _BMIDashboardState extends State<BMIDashboard> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _selectedUnit = 'Metric';
  double? _bmiValue;
  String _category = '';
  String _advice = '';
  Color _backgroundColor = Colors.white;
  IconData _categoryIcon = Icons.fitness_center;
  Color _iconColor = Colors.blue;

  // Advanced BMI Categories with thresholds
  final List<BMICategory> _categories = [
    BMICategory(
      range: const Range(start: 0, end: 16),
      name: 'Severe Thinness',
      advice: 'Urgent medical consultation required. Please seek professional healthcare advice immediately.',
      color: Colors.red.shade900,
      icon: Icons.health_and_safety,
      iconColor: Colors.red.shade900,
    ),
    BMICategory(
      range: const Range(start: 16, end: 17),
      name: 'Moderate Thinness',
      advice: 'Significantly underweight. Consult a dietitian for a weight gain plan.',
      color: Colors.red.shade700,
      icon: Icons.local_hospital,
      iconColor: Colors.red.shade700,
    ),
    BMICategory(
      range: const Range(start: 17, end: 18.5),
      name: 'Mild Thinness',
      advice: 'Slightly underweight. Focus on nutrient-rich foods and strength training.',
      color: Colors.orange.shade700,
      icon: Icons.restaurant,
      iconColor: Colors.orange.shade700,
    ),
    BMICategory(
      range: const Range(start: 18.5, end: 25),
      name: 'Normal Weight',
      advice: 'Excellent! Maintain with balanced diet and regular exercise (150 mins/week).',
      color: Colors.green.shade600,
      icon: Icons.emoji_events,
      iconColor: Colors.green.shade600,
    ),
    BMICategory(
      range: const Range(start: 25, end: 30),
      name: 'Overweight',
      advice: 'Moderate risk. Start with walking 30 mins daily and reduce processed foods.',
      color: Colors.orange.shade800,
      icon: Icons.directions_walk,
      iconColor: Colors.orange.shade800,
    ),
    BMICategory(
      range: const Range(start: 30, end: 35),
      name: 'Obese Class I',
      advice: 'High risk. Consult a doctor for personalized weight loss strategy.',
      color: Colors.deepOrange.shade700,
      icon: Icons.warning_amber,
      iconColor: Colors.deepOrange.shade700,
    ),
    BMICategory(
      range: const Range(start: 35, end: 40),
      name: 'Obese Class II',
      advice: 'Very high risk. Professional medical intervention recommended.',
      color: Colors.red.shade800,
      icon: Icons.medical_services,
      iconColor: Colors.red.shade800,
    ),
    BMICategory(
      range: const Range(start: 40, end: 100),
      name: 'Obese Class III',
      advice: 'Severe risk. Immediate medical consultation and lifestyle intervention needed.',
      color: Colors.red.shade900,
      icon: Icons.emergency,
      iconColor: Colors.red.shade900,
    ),
  ];

  void _calculateBMI() {
    double? height = double.tryParse(_heightController.text);
    double? weight = double.tryParse(_weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid height and weight values'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    double bmi;
    if (_selectedUnit == 'Metric') {
      // Height in meters
      bmi = weight / (height * height);
    } else {
      // Imperial: weight(lbs) / (height(inches))^2 * 703
      bmi = (weight / (height * height)) * 703;
    }

    setState(() {
      _bmiValue = bmi;
      _updateCategory(bmi);
    });
  }

  void _updateCategory(double bmi) {
    BMICategory? foundCategory = _categories.firstWhere(
          (cat) => bmi >= cat.range.start && bmi < cat.range.end,
      orElse: () => _categories.last,
    );

    _category = foundCategory.name;
    _advice = foundCategory.advice;
    _backgroundColor = foundCategory.color;
    _categoryIcon = foundCategory.icon;
    _iconColor = foundCategory.iconColor;
  }

  void _resetForm() {
    _heightController.clear();
    _weightController.clear();
    setState(() {
      _bmiValue = null;
      _category = '';
      _advice = '';
      _backgroundColor = Colors.white;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.blue.shade100,
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: true,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'BMI Health Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.blue.shade700,
                          Colors.cyan.shade600,
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _resetForm,
                    tooltip: 'Reset',
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Unit Selection Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Measurement System',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<String>(
                              segments: const [
                                ButtonSegment(value: 'Metric', label: Text('Metric (kg/m)')),
                                ButtonSegment(value: 'Imperial', label: Text('Imperial (lbs/in)')),
                              ],
                              selected: {_selectedUnit},
                              onSelectionChanged: (Set<String> selection) {
                                setState(() {
                                  _selectedUnit = selection.first;
                                  _resetForm();
                                });
                              },
                              style: SegmentedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Input Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Enter Your Details',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _heightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: _selectedUnit == 'Metric' ? 'Height (meters)' : 'Height (inches)',
                                prefixIcon: const Icon(Icons.height),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextField(
                              controller: _weightController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: _selectedUnit == 'Metric' ? 'Weight (kilograms)' : 'Weight (pounds)',
                                prefixIcon: const Icon(Icons.monitor_weight),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _calculateBMI,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  backgroundColor: Colors.blue.shade700,
                                ),
                                child: const Text(
                                  'Calculate BMI',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Results Dashboard
                    if (_bmiValue != null) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        child: Card(
                          elevation: 12,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          color: _backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              children: [
                                // Header with Logo
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _categoryIcon,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // BMI Value
                                Text(
                                  _bmiValue!.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 56,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black26,
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'BMI Score',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white.withOpacity(0.9),
                                    letterSpacing: 1,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // Category Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Text(
                                    _category,
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: _backgroundColor,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Health Advice
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Column(
                                    children: [
                                      const Row(
                                        children: [
                                          Icon(Icons.health_and_safety, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'Health Recommendation',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        _advice,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          height: 1.5,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),

                                // BMI Scale Indicator
                                Container(
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: (_bmiValue! / 40 * 100).toInt(),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Underweight', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                                    Text('Normal', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                                    Text('Overweight', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                                    Text('Obese', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Additional Health Metrics Card
                      Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.insights, color: Colors.blue),
                                  SizedBox(width: 8),
                                  Text(
                                    'Health Insights',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildHealthInsight(
                                'Ideal BMI Range',
                                '18.5 - 24.9',
                                Icons.analytics,
                              ),
                              const Divider(),
                              _buildHealthInsight(
                                'Recommended Daily Steps',
                                '8,000 - 10,000',
                                Icons.directions_walk,
                              ),
                              const Divider(),
                              _buildHealthInsight(
                                'Hydration Goal',
                                '2-3 Liters/Day',
                                Icons.water_drop,
                              ),
                              const Divider(),
                              _buildHealthInsight(
                                'Sleep Duration',
                                '7-9 Hours',
                                Icons.bedtime,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthInsight(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blue.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BMICategory {
  final Range range;
  final String name;
  final String advice;
  final Color color;
  final IconData icon;
  final Color iconColor;

  const BMICategory({
    required this.range,
    required this.name,
    required this.advice,
    required this.color,
    required this.icon,
    required this.iconColor,
  });
}

class Range {
  final double start;
  final double end;

  const Range({required this.start, required this.end});
}
