import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const TravelAndEntertainmentApp());
}

class TravelAndEntertainmentApp extends StatelessWidget {
  const TravelAndEntertainmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel & Entertainment',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFFE94057),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        cardColor: const Color(0xFF2A2A2A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A1A),
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1A1A1A),
          selectedItemColor: Color(0xFFE94057),
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  static const String apiKey = 'ee9c25db'; // Replace with your OMDb API key

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      MovieSwipeScreen(apiKey: apiKey),
      TravelCostScreen(),
      EntertainmentScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight_takeoff),
            label: 'Travel Cost',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_activity),
            label: 'Entertainment',
          ),
        ],
      ),
    );
  }
}

// ==================== MOVIE SWIPE SCREEN ====================
class MovieSwipeScreen extends StatefulWidget {
  final String apiKey;
  const MovieSwipeScreen({super.key, required this.apiKey});

  @override
  State<MovieSwipeScreen> createState() => _MovieSwipeScreenState();
}

class _MovieSwipeScreenState extends State<MovieSwipeScreen> {
  List<Movie> _movies = [];
  bool _isLoading = true;
  String _errorMessage = '';

  final List<String> _searchTerms = ['marvel', 'batman', 'star', 'lord', 'spider', 'superman', 'avengers', 'harry'];

  @override
  void initState() {
    super.initState();
    _fetchMovies();
  }

  Future<void> _fetchMovies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final randomTerm = _searchTerms[_searchTerms.length % 2 == 0 ? 0 : 1];
      final response = await http.get(
        Uri.parse('http://www.omdbapi.com/?apikey=${widget.apiKey}&s=$randomTerm&type=movie'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          List<Movie> fetchedMovies = [];
          for (var item in data['Search']) {
            final detailResponse = await http.get(
              Uri.parse('http://www.omdbapi.com/?apikey=${widget.apiKey}&i=${item['imdbID']}'),
            );
            if (detailResponse.statusCode == 200) {
              final detailData = json.decode(detailResponse.body);
              fetchedMovies.add(Movie.fromJson(detailData));
            }
          }
          setState(() {
            _movies = fetchedMovies;
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = data['Error'] ?? 'Failed to load movies';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Network error. Please check your connection.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _handleSwipeLeft() {
    if (_movies.isNotEmpty) {
      setState(() {
        _movies.removeAt(0);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passed'), duration: Duration(milliseconds: 300)),
      );
    }
  }

  void _handleSwipeRight() {
    if (_movies.isNotEmpty) {
      final likedMovie = _movies[0];
      setState(() {
        _movies.removeAt(0);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Liked: ${likedMovie.title}'), duration: Duration(milliseconds: 500)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe to Discover Movies'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMovies,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _fetchMovies, child: const Text('Retry')),
          ],
        ),
      )
          : _movies.isEmpty
          ? const Center(child: Text('No more movies! Pull to refresh'))
          : Stack(
        children: [
          for (int i = _movies.length - 1; i >= 0; i--)
            SwipeCard(
              key: ValueKey(_movies[i].imdbID),
              movie: _movies[i],
              onSwipeLeft: _handleSwipeLeft,
              onSwipeRight: _handleSwipeRight,
              isTop: i == 0,
            ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'passBtn',
                  onPressed: _handleSwipeLeft,
                  backgroundColor: Colors.grey[800],
                  child: const Icon(Icons.close, size: 30, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: 'likeBtn',
                  onPressed: _handleSwipeRight,
                  backgroundColor: const Color(0xFFE94057),
                  child: const Icon(Icons.favorite, size: 30, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SwipeCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback onSwipeLeft;
  final VoidCallback onSwipeRight;
  final bool isTop;

  const SwipeCard({
    super.key,
    required this.movie,
    required this.onSwipeLeft,
    required this.onSwipeRight,
    required this.isTop,
  });

  @override
  State<SwipeCard> createState() => _SwipeCardState();
}

class _SwipeCardState extends State<SwipeCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Offset _dragStart = Offset.zero;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (!widget.isTop) return;
    _dragStart = details.localPosition;
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!widget.isTop) return;
    setState(() {
      _dragOffset = details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (!widget.isTop) return;
    _isDragging = false;
    if (_dragOffset.dx.abs() > 120) {
      if (_dragOffset.dx > 0) {
        widget.onSwipeRight();
      } else {
        widget.onSwipeLeft();
      }
    }
    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isTopCard = widget.isTop;
    final dragValue = _dragOffset.dx / MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: isTopCard && _isDragging ? _dragOffset : Offset.zero,
          child: Transform.rotate(
            angle: isTopCard && _isDragging ? dragValue * 0.2 : 0,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: widget.movie.poster != 'N/A'
                              ? Image.network(
                            widget.movie.poster,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.broken_image, size: 50, color: Colors.grey),
                            ),
                          )
                              : Container(
                            color: Colors.grey[800],
                            child: const Icon(Icons.movie, size: 50, color: Colors.grey),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.movie.title,
                                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 20),
                                    const SizedBox(width: 4),
                                    Text(widget.movie.imdbRating, style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.calendar_today, size: 16),
                                    const SizedBox(width: 4),
                                    Text(widget.movie.year, style: const TextStyle(fontSize: 14)),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.access_time, size: 16),
                                    const SizedBox(width: 4),
                                    Text(widget.movie.runtime, style: const TextStyle(fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  widget.movie.plot,
                                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  children: widget.movie.genre.split(',').map((g) => Chip(
                                    label: Text(g.trim(), style: const TextStyle(fontSize: 12)),
                                    backgroundColor: Colors.grey[800],
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  )).toList(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ==================== TRAVEL COST SCREEN ====================
class TravelCostScreen extends StatefulWidget {
  const TravelCostScreen({super.key});

  @override
  State<TravelCostScreen> createState() => _TravelCostScreenState();
}

class _TravelCostScreenState extends State<TravelCostScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();

  String _selectedTransport = 'Car';
  String _selectedCurrency = 'USD';
  double _calculatedCost = 0;
  bool _isCalculated = false;

  final Map<String, double> _ratePerKm = {
    'Car': 0.35,
    'Bus': 0.12,
    'Train': 0.22,
    'Flight': 0.45,
  };

  final Map<String, double> _currencyRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'INR': 83.5,
    'JPY': 150.2,
  };

  final List<Map<String, dynamic>> _recentTrips = [];

  @override
  void initState() {
    super.initState();
    _loadRecentTrips();
  }

  void _loadRecentTrips() async {
    final prefs = await SharedPreferences.getInstance();
    final tripsJson = prefs.getStringList('recent_trips') ?? [];
    setState(() {
      _recentTrips.clear();
      for (var json in tripsJson) {
        _recentTrips.add(jsonDecode(json) as Map<String, dynamic>);
      }
    });
  }

  void _saveTrip(Map<String, dynamic> trip) async {
    final prefs = await SharedPreferences.getInstance();
    _recentTrips.insert(0, trip);
    if (_recentTrips.length > 5) _recentTrips.removeLast();
    final tripsJson = _recentTrips.map((t) => jsonEncode(t)).toList();
    await prefs.setStringList('recent_trips', tripsJson);
  }

  void _calculateCost() {
    double distance = double.tryParse(_distanceController.text) ?? 0;
    if (distance <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid distance in kilometers')),
      );
      return;
    }

    final baseCost = distance * (_ratePerKm[_selectedTransport] ?? 0.35);
    final convertedCost = baseCost * (_currencyRates[_selectedCurrency] ?? 1.0);

    setState(() {
      _calculatedCost = convertedCost;
      _isCalculated = true;
    });

    final trip = {
      'origin': _originController.text.isNotEmpty ? _originController.text : 'Point A',
      'destination': _destinationController.text.isNotEmpty ? _destinationController.text : 'Point B',
      'distance': distance,
      'transport': _selectedTransport,
      'cost': convertedCost,
      'currency': _selectedCurrency,
      'date': DateTime.now().toIso8601String(),
    };
    _saveTrip(trip);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Cost Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _originController,
                      decoration: const InputDecoration(
                        labelText: 'Origin',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _destinationController,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        prefixIcon: Icon(Icons.location_city),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _distanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Distance (km)',
                        prefixIcon: Icon(Icons.straighten),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedTransport,
                      decoration: const InputDecoration(
                        labelText: 'Transport Mode',
                        prefixIcon: Icon(Icons.directions_car),
                        border: OutlineInputBorder(),
                      ),
                      items: _ratePerKm.keys.map((mode) {
                        return DropdownMenuItem(value: mode, child: Text(mode));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTransport = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedCurrency,
                      decoration: const InputDecoration(
                        labelText: 'Currency',
                        prefixIcon: Icon(Icons.attach_money),
                        border: OutlineInputBorder(),
                      ),
                      items: _currencyRates.keys.map((currency) {
                        return DropdownMenuItem(value: currency, child: Text(currency));
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCurrency = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _calculateCost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE94057),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Calculate Cost', style: TextStyle(fontSize: 16)),
                    ),
                    if (_isCalculated) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Color(0xFFE94057), Color(0xFF8A2387)]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text('Estimated Cost', style: TextStyle(fontSize: 14, color: Colors.white70)),
                            const SizedBox(height: 8),
                            Text(
                              '${_selectedCurrency == 'USD' ? '\$' : _selectedCurrency == 'EUR' ? '€' : _selectedCurrency == 'GBP' ? '£' : _selectedCurrency == 'JPY' ? '¥' : '₹'}${_calculatedCost.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'via $_selectedTransport • ${_distanceController.text} km',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_recentTrips.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recent Trips', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      ..._recentTrips.take(3).map((trip) => ListTile(
                        leading: const Icon(Icons.history),
                        title: Text('${trip['origin']} → ${trip['destination']}'),
                        subtitle: Text('${trip['distance']} km • ${trip['transport']}'),
                        trailing: Text(
                          '${trip['currency'] == 'USD' ? '\$' : trip['currency'] == 'EUR' ? '€' : '₹'}${trip['cost'].toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ==================== ENTERTAINMENT SCREEN ====================
class EntertainmentScreen extends StatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  State<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends State<EntertainmentScreen> {
  final List<Map<String, dynamic>> _events = [
    {'name': '🎸 Rock Concert', 'venue': 'Stadium Arena', 'price': 49.99, 'date': 'Dec 15, 2024'},
    {'name': '🎭 Broadway Show', 'venue': 'Grand Theater', 'price': 89.99, 'date': 'Dec 18, 2024'},
    {'name': '🎪 Circus Extravaganza', 'venue': 'City Center', 'price': 35.50, 'date': 'Dec 20, 2024'},
    {'name': '🎬 Film Festival', 'venue': 'Cinema World', 'price': 25.00, 'date': 'Dec 22, 2024'},
    {'name': '🏀 Basketball Game', 'venue': 'Sports Complex', 'price': 65.00, 'date': 'Dec 25, 2024'},
  ];

  final List<Map<String, dynamic>> _bookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final bookingsJson = prefs.getStringList('entertainment_bookings') ?? [];
    setState(() {
      _bookings.clear();
      for (var json in bookingsJson) {
        _bookings.add(jsonDecode(json) as Map<String, dynamic>);
      }
    });
  }

  void _saveBooking(Map<String, dynamic> booking) async {
    final prefs = await SharedPreferences.getInstance();
    _bookings.add(booking);
    final bookingsJson = _bookings.map((b) => jsonEncode(b)).toList();
    await prefs.setStringList('entertainment_bookings', bookingsJson);
  }

  void _bookEvent(Map<String, dynamic> event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(event['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Venue: ${event['venue']}'),
            const SizedBox(height: 8),
            Text('Date: ${event['date']}'),
            const SizedBox(height: 8),
            Text('Price: \$${event['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final booking = {
                ...event,
                'bookingId': DateTime.now().millisecondsSinceEpoch.toString(),
                'bookedAt': DateTime.now().toIso8601String(),
              };
              _saveBooking(booking);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Booked: ${event['name']}')),
              );
              setState(() {});
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE94057)),
            child: const Text('Confirm Booking'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entertainment Events'),
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.event), text: 'Events'),
                Tab(icon: Icon(Icons.bookmark), text: 'My Bookings'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _events.length,
                    itemBuilder: (context, index) {
                      final event = _events[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE94057),
                            child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                          ),
                          title: Text(event['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${event['venue']} • ${event['date']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('\$${event['price']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE94057))),
                            ],
                          ),
                          onTap: () => _bookEvent(event),
                        ),
                      );
                    },
                  ),
                  _bookings.isEmpty
                      ? const Center(child: Text('No bookings yet.\nTap on events to book!', textAlign: TextAlign.center))
                      : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: const Icon(Icons.confirmation_number, color: Color(0xFFE94057)),
                          title: Text(booking['name']),
                          subtitle: Text('${booking['venue']} • ${booking['date']}'),
                          trailing: Text('\$${booking['price']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== MOVIE MODEL ====================
class Movie {
  final String title;
  final String year;
  final String imdbID;
  final String type;
  final String poster;
  final String imdbRating;
  final String runtime;
  final String genre;
  final String plot;
  final String director;
  final String actors;

  Movie({
    required this.title,
    required this.year,
    required this.imdbID,
    required this.type,
    required this.poster,
    required this.imdbRating,
    required this.runtime,
    required this.genre,
    required this.plot,
    required this.director,
    required this.actors,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'N/A',
      year: json['Year'] ?? 'N/A',
      imdbID: json['imdbID'] ?? '',
      type: json['Type'] ?? 'movie',
      poster: json['Poster'] ?? 'N/A',
      imdbRating: json['imdbRating'] ?? 'N/A',
      runtime: json['Runtime'] ?? 'N/A',
      genre: json['Genre'] ?? 'N/A',
      plot: json['Plot'] ?? 'No plot available',
      director: json['Director'] ?? 'N/A',
      actors: json['Actors'] ?? 'N/A',
    );
  }
}
