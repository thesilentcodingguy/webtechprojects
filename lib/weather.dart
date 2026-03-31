import 'package:flutter/material.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  double _temperature = 20.0;
  String _season = 'Spring';
  
  final Map<String, IconData> _seasonIcons = {
    'Spring': Icons.flower,
    'Summer': Icons.wb_sunny,
    'Autumn': Icons.leaves,
    'Winter': Icons.ac_unit,
  };

  Color _getBackgroundColor() {
    if (_temperature <= 0) return Colors.blue.shade900;
    if (_temperature <= 10) return Colors.blue.shade700;
    if (_temperature <= 20) return Colors.blue.shade400;
    if (_temperature <= 30) return Colors.orange.shade300;
    if (_temperature <= 40) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  String _getTemperatureDescription() {
    if (_temperature <= 0) return 'Freezing ❄️';
    if (_temperature <= 10) return 'Cold 🧥';
    if (_temperature <= 20) return 'Cool 🍃';
    if (_temperature <= 30) return 'Warm ☀️';
    if (_temperature <= 40) return 'Hot 🔥';
    return 'Extreme Heat 🌡️';
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
              _getBackgroundColor(),
              _getBackgroundColor().withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Weather Icon based on season
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _seasonIcons[_season]!,
                      size: 80,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Temperature Display
                  Text(
                    '${_temperature.toStringAsFixed(0)}°C',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Text(
                    _getTemperatureDescription(),
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Temperature Slider
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Text(
                          'Adjust Temperature',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Slider(
                          value: _temperature,
                          min: -10,
                          max: 45,
                          divisions: 55,
                          activeColor: Colors.white,
                          inactiveColor: Colors.white.withOpacity(0.3),
                          label: '${_temperature.toStringAsFixed(0)}°C',
                          onChanged: (value) {
                            setState(() {
                              _temperature = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Season Buttons
                  const Text(
                    'Select Season',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSeasonButton('Spring', Icons.flower),
                      const SizedBox(width: 10),
                      _buildSeasonButton('Summer', Icons.wb_sunny),
                      const SizedBox(width: 10),
                      _buildSeasonButton('Autumn', Icons.leaves),
                      const SizedBox(width: 10),
                      _buildSeasonButton('Winter', Icons.ac_unit),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSeasonButton(String season, IconData icon) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _season = season;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: _season == season 
            ? Colors.white 
            : Colors.white.withOpacity(0.3),
        foregroundColor: _season == season 
            ? _getBackgroundColor() 
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(season, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
