import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Get your free API key from: https://home.openweathermap.org/api_keys
const String OPENWEATHER_API_KEY = "3322487c80596927a5730e595092c27e";

// Flag to use mock data when API fails or for testing
// Set to false to use real API, true to always use mock data
const bool FORCE_USE_MOCK_DATA = false;

void main() {
  runApp(const MyWeatherApp());
}

class MyWeatherApp extends StatelessWidget {
  const MyWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeatherWise',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF03DAC6),
          surface: Color(0xFF1A1F38),
          background: Color(0xFF0A0E21),
        ),
      ),
      home: const WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _isUsingMockData = false;
  String _errorMessage = '';
  WeatherData? _weatherData;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  Future<void> _fetchWeather() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
      _isUsingMockData = false;
    });

    try {
      WeatherData? fetchedData;

      // Try to fetch from API first (unless forced to use mock)
      if (!FORCE_USE_MOCK_DATA) {
        fetchedData = await _fetchFromAPI();
      }

      // If API failed or returned null, use mock data
      if (fetchedData == null) {
        fetchedData = await _getMockWeatherData();
        setState(() {
          _isUsingMockData = true;
        });
      }

      setState(() {
        _weatherData = fetchedData;
        _isLoading = false;
      });
    } catch (e) {
      // Final fallback - use mock data even if there was an error
      try {
        final mockData = await _getMockWeatherData();
        setState(() {
          _weatherData = mockData;
          _isLoading = false;
          _isUsingMockData = true;
          _hasError = false; // Clear error since we have mock data
        });
      } catch (fallbackError) {
        setState(() {
          _hasError = true;
          _errorMessage = "Unable to load weather data. Please check your connection.";
          _isLoading = false;
        });
      }
    }
  }

  Future<WeatherData?> _fetchFromAPI() async {
    try {
      // Using New York coordinates as default location
      const double lat = 40.7128;
      const double lon = -74.0060;

      final String apiUrl = "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$OPENWEATHER_API_KEY&units=metric";

      final response = await http.get(Uri.parse(apiUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Connection timeout'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid API key. Please check your OpenWeatherMap API key.');
      } else {
        throw Exception('API returned error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('API Error: $e');
      return null; // Return null to trigger mock data fallback
    }
  }

  Future<WeatherData> _getMockWeatherData() async {
    // Simulate network delay for realistic experience
    await Future.delayed(const Duration(milliseconds: 500));

    // Return different mock data based on time of day or random selection
    final random = Random();
    final conditions = [
      'Clear Sky', 'Few Clouds', 'Scattered Clouds', 'Broken Clouds',
      'Light Rain', 'Moderate Rain', 'Thunderstorm', 'Snow', 'Mist', 'Haze'
    ];
    final randomCondition = conditions[random.nextInt(conditions.length)];

    // Generate realistic mock data
    return WeatherData(
      locationName: "Sample City",
      country: "Demo",
      latLong: "40.71°N, 74.01°W",
      temperature: 22.5 + (random.nextDouble() * 10 - 5),
      feelsLike: 21.8 + (random.nextDouble() * 8 - 4),
      humidity: 45 + random.nextInt(40),
      windSpeed: 5.5 + random.nextDouble() * 8,
      pressure: 1013 + random.nextInt(20) - 10,
      visibility: 8000 + random.nextInt(5000),
      mainCondition: randomCondition,
      sunrise: "06:30",
      sunset: "19:45",
      isMockData: true,
    );
  }

  Future<void> _refreshWeather() async {
    await _fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _getBackgroundGradient(),
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshWeather,
            color: const Color(0xFF6C63FF),
            backgroundColor: const Color(0xFF1A1F38),
            child: _isLoading
                ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Fetching weather data...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
                : _hasError
                ? _buildErrorWidget()
                : _buildWeatherWidget(),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off,
              size: 80,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 24),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Using fallback data may be available",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshWeather,
              icon: const Icon(Icons.refresh),
              label: const Text("Try Again"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherWidget() {
    if (_weatherData == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            if (_isUsingMockData) _buildMockDataBanner(),
            const SizedBox(height: 20),
            _buildMainWeatherCard(),
            const SizedBox(height: 24),
            _buildDetailsCard(),
            const SizedBox(height: 24),
            _buildAdditionalInfoCard(),
            const SizedBox(height: 20),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildMockDataBanner() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, color: Colors.orange[300], size: 16),
          const SizedBox(width: 6),
          Text(
            "Demo Mode - Using Sample Data",
            style: TextStyle(
              color: Colors.orange[300],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  _weatherData!.locationName,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                if (_weatherData!.isMockData)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "DEMO",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.white70),
                const SizedBox(width: 4),
                Text(
                  "${_weatherData!.country}, ${_weatherData!.latLong}",
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        IconButton(
          onPressed: _refreshWeather,
          icon: const Icon(Icons.refresh, color: Colors.white70),
          tooltip: "Refresh",
        ),
      ],
    );
  }

  Widget _buildMainWeatherCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6C63FF).withOpacity(0.3),
            const Color(0xFF03DAC6).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _getWeatherIcon(_weatherData!.mainCondition, size: 80),
          const SizedBox(height: 16),
          Text(
            "${_weatherData!.temperature.round()}°C",
            style: const TextStyle(
              fontSize: 64,
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
            _weatherData!.mainCondition,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              "Feels like ${_weatherData!.feelsLike.round()}°C",
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38).withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildDetailItem(
            icon: Icons.water_drop,
            label: "Humidity",
            value: "${_weatherData!.humidity}%",
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildDetailItem(
            icon: Icons.air,
            label: "Wind Speed",
            value: "${_weatherData!.windSpeed.toStringAsFixed(1)} km/h",
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildDetailItem(
            icon: Icons.compress,
            label: "Pressure",
            value: "${_weatherData!.pressure} hPa",
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF03DAC6), size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F38).withOpacity(0.7),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildAdditionalItem(
            icon: Icons.sunny,
            label: "Sunrise",
            value: _weatherData!.sunrise,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildAdditionalItem(
            icon: Icons.nightlight_round,
            label: "Sunset",
            value: _weatherData!.sunset,
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.white.withOpacity(0.2),
          ),
          _buildAdditionalItem(
            icon: Icons.visibility,
            label: "Visibility",
            value: "${(_weatherData!.visibility / 1000).toStringAsFixed(1)} km",
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6C63FF), size: 24),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Text(
        _isUsingMockData
            ? "⚠️ Using demo data • API connection failed"
            : "✅ Live weather data",
        style: TextStyle(
          color: Colors.white.withOpacity(0.4),
          fontSize: 11,
        ),
      ),
    );
  }

  List<Color> _getBackgroundGradient() {
    if (_weatherData == null) {
      return [const Color(0xFF0A0E21), const Color(0xFF1A1F38)];
    }

    final condition = _weatherData!.mainCondition.toLowerCase();
    if (condition.contains('clear') || condition.contains('sunny')) {
      return [const Color(0xFF1A2980), const Color(0xFF26D0CE)];
    } else if (condition.contains('cloud')) {
      return [const Color(0xFF2C3E50), const Color(0xFF3498DB)];
    } else if (condition.contains('rain') || condition.contains('drizzle')) {
      return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)];
    } else if (condition.contains('thunder')) {
      return [const Color(0xFF1F1C2C), const Color(0xFF928DAB)];
    } else if (condition.contains('snow')) {
      return [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)];
    } else if (condition.contains('mist') || condition.contains('fog') || condition.contains('haze')) {
      return [const Color(0xFF606c88), const Color(0xFF3f4c6b)];
    } else {
      return [const Color(0xFF0A0E21), const Color(0xFF1A1F38)];
    }
  }

  Widget _getWeatherIcon(String condition, {double size = 60}) {
    String lowerCondition = condition.toLowerCase();

    if (lowerCondition.contains('clear') || lowerCondition.contains('sunny')) {
      return Icon(Icons.wb_sunny, color: Colors.amber, size: size);
    } else if (lowerCondition.contains('cloud')) {
      if (lowerCondition.contains('few') || lowerCondition.contains('scattered')) {
        return Icon(Icons.cloud_queue, color: Colors.grey[300], size: size);
      } else {
        return Icon(Icons.cloud, color: Colors.grey[400], size: size);
      }
    } else if (lowerCondition.contains('rain')) {
      return Icon(Icons.grain, color: Colors.lightBlue[300], size: size);
    } else if (lowerCondition.contains('drizzle')) {
      return Icon(Icons.beach_access, color: Colors.lightBlue[200], size: size);
    } else if (lowerCondition.contains('thunder')) {
      return Icon(Icons.flash_on, color: Colors.orangeAccent, size: size);
    } else if (lowerCondition.contains('snow')) {
      return Icon(Icons.ac_unit, color: Colors.white70, size: size);
    } else if (lowerCondition.contains('mist') || lowerCondition.contains('fog') || lowerCondition.contains('haze')) {
      return Icon(Icons.foggy, color: Colors.grey[400], size: size);
    } else {
      return Icon(Icons.wb_cloudy, color: Colors.grey[400], size: size);
    }
  }
}

class WeatherData {
  final String locationName;
  final String country;
  final String latLong;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int pressure;
  final int visibility;
  final String mainCondition;
  final String sunrise;
  final String sunset;
  final bool isMockData;

  WeatherData({
    required this.locationName,
    required this.country,
    required this.latLong,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.pressure,
    required this.visibility,
    required this.mainCondition,
    required this.sunrise,
    required this.sunset,
    this.isMockData = false,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final locationName = json['name'] ?? 'Unknown';
    final country = json['sys']['country'] ?? 'Unknown';
    final lat = json['coord']['lat'].toStringAsFixed(2);
    final lon = json['coord']['lon'].toStringAsFixed(2);
    final latLong = "$lat°N, $lon°E";

    final temperature = json['main']['temp'].toDouble();
    final feelsLike = json['main']['feels_like'].toDouble();
    final humidity = json['main']['humidity'];
    final windSpeed = json['wind']['speed'].toDouble();
    final pressure = json['main']['pressure'];
    final visibility = json['visibility'] ?? 10000;
    final mainCondition = json['weather'][0]['main'];

    // Convert timestamps to readable time
    final sunriseTime = DateTime.fromMillisecondsSinceEpoch(
        json['sys']['sunrise'] * 1000
    );
    final sunsetTime = DateTime.fromMillisecondsSinceEpoch(
        json['sys']['sunset'] * 1000
    );

    final sunrise = "${sunriseTime.hour.toString().padLeft(2, '0')}:${sunriseTime.minute.toString().padLeft(2, '0')}";
    final sunset = "${sunsetTime.hour.toString().padLeft(2, '0')}:${sunsetTime.minute.toString().padLeft(2, '0')}";

    return WeatherData(
      locationName: locationName,
      country: country,
      latLong: latLong,
      temperature: temperature,
      feelsLike: feelsLike,
      humidity: humidity,
      windSpeed: windSpeed,
      pressure: pressure,
      visibility: visibility,
      mainCondition: mainCondition,
      sunrise: sunrise,
      sunset: sunset,
      isMockData: false,
    );
  }
}
