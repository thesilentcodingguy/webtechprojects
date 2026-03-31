import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
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
  final List<String> _cities = [
    'Chennai', 'Mumbai', 'Kolkata', 'Delhi', 'Bangalore',
    'Hyderabad', 'Ahmedabad', 'Pune', 'Jaipur', 'Lucknow',
    'Nagpur', 'Indore'
  ];
  
  String _selectedCity = 'Chennai';
  Map<String, dynamic>? _weatherData;
  bool _isLoading = false;
  String _error = '';

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      // Using Open-Meteo API (free, no API key required)
      // First get coordinates for the city
      final geoResponse = await http.get(
        Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=$_selectedCity&count=1&language=en&format=json'),
      );
      
      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        if (geoData['results'] != null && geoData['results'].isNotEmpty) {
          final lat = geoData['results'][0]['latitude'];
          final lon = geoData['results'][0]['longitude'];
          
          // Get weather data using coordinates
          final weatherResponse = await http.get(
            Uri.parse('https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true&hourly=temperature_2m&timezone=auto'),
          );
          
          if (weatherResponse.statusCode == 200) {
            setState(() {
              _weatherData = json.decode(weatherResponse.body);
              _isLoading = false;
            });
          } else {
            setState(() {
              _error = 'Failed to fetch weather data';
              _isLoading = false;
            });
          }
        } else {
          setState(() {
            _error = 'City not found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch location data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  String _getWeatherIcon(String weatherCode) {
    // Based on WMO Weather interpretation codes (WW)
    final code = int.parse(weatherCode);
    if (code == 0) return '☀️';
    if (code == 1 || code == 2 || code == 3) return '⛅';
    if (code >= 45 && code <= 49) return '🌫️';
    if (code >= 51 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 99) return '⛈️';
    return '🌡️';
  }

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weather App'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // City Selector
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButton<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: _cities.map((city) {
                    return DropdownMenuItem(
                      value: city,
                      child: Text(city, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
                  onChanged: (city) {
                    setState(() {
                      _selectedCity = city!;
                    });
                    _fetchWeather();
                  },
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Weather Display
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_error.isNotEmpty)
                Column(
                  children: [
                    const Icon(Icons.error_outline, size: 50, color: Colors.red),
                    const SizedBox(height: 10),
                    Text(_error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _fetchWeather,
                      child: const Text('Retry'),
                    ),
                  ],
                )
              else if (_weatherData != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade300, Colors.blue.shade700],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selectedCity,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getWeatherIcon(_weatherData!['current_weather']['weathercode'].toString()),
                        style: const TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${_weatherData!['current_weather']['temperature'].toStringAsFixed(1)}°C',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getWeatherDescription(_weatherData!['current_weather']['weathercode'].toString()),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                const Icon(Icons.air, color: Colors.white),
                                const SizedBox(height: 5),
                                Text(
                                  '${_weatherData!['current_weather']['windspeed']} km/h',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Icon(Icons.compass, color: Colors.white),
                                const SizedBox(height: 5),
                                Text(
                                  '${_weatherData!['current_weather']['winddirection']}°',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 30),
              
              // Refresh Button
              if (!_isLoading)
                TextButton.icon(
                  onPressed: _fetchWeather,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Weather'),
                  style: TextButton.styleFrom(foregroundColor: Colors.blue),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWeatherDescription(String code) {
    final weatherCode = int.parse(code);
    switch (weatherCode) {
      case 0: return 'Clear sky';
      case 1: return 'Mainly clear';
      case 2: return 'Partly cloudy';
      case 3: return 'Overcast';
      case 45:
      case 48: return 'Fog';
      case 51:
      case 53:
      case 55: return 'Drizzle';
      case 61:
      case 63:
      case 65: return 'Rain';
      case 71:
      case 73:
      case 75: return 'Snow';
      case 80:
      case 81:
      case 82: return 'Rain showers';
      case 95:
      case 96:
      case 99: return 'Thunderstorm';
      default: return 'Unknown';
    }
  }
}
