import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String OMDB_API_KEY = "ee9c25db";

void main() {
  runApp(const MovieApp());
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Movie Review",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        useMaterial3: true,
      ),
      home: const MovieHomePage(),
    );
  }
}

class Movie {
  final String title;
  final String genre;
  final String poster;

  Movie({
    required this.title,
    required this.genre,
    required this.poster,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'] ?? 'Unknown',
      genre: json['Genre'] ?? 'N/A',
      poster: json['Poster'] != "N/A"
          ? json['Poster']
          : "https://via.placeholder.com/300",
    );
  }
}

class MovieHomePage extends StatefulWidget {
  const MovieHomePage({super.key});

  @override
  State<MovieHomePage> createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  final TextEditingController _controller = TextEditingController();

  bool _isLoading = false;
  String _error = "";
  Movie? _movie;
  int _rating = 0;

  Future<void> fetchMovie(String name) async {
    setState(() {
      _isLoading = true;
      _error = "";
    });

    try {
      final url =
          "https://www.omdbapi.com/?t=$name&apikey=$OMDB_API_KEY";

      final response = await http.get(Uri.parse(url));

      final data = json.decode(response.body);

      if (data['Response'] == "True") {
        setState(() {
          _movie = Movie.fromJson(data);
          _rating = 0;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = data['Error'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Network error";
        _isLoading = false;
      });
    }
  }

  Color getBackgroundColor() {
    if (_rating >= 4) return Colors.green.shade700;
    if (_rating == 3) return Colors.orange.shade700;
    if (_rating > 0) return Colors.red.shade700;
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              getBackgroundColor(),
              Colors.black,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildSearchBar(),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error.isNotEmpty
                        ? Center(child: Text(_error))
                        : _movie == null
                            ? _buildEmpty()
                            : _buildMovie(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "🎬 Movie Review App",
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Search movie...",
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              fetchMovie(_controller.text.trim());
            },
            child: const Icon(Icons.search),
          )
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Text(
        "Search for a movie 🎥",
        style: TextStyle(fontSize: 18),
      ),
    );
  }

  Widget _buildMovie() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPoster(),
          const SizedBox(height: 20),
          _buildTitle(),
          const SizedBox(height: 10),
          _buildGenre(),
          const SizedBox(height: 20),
          _buildRating(),
        ],
      ),
    );
  }

  Widget _buildPoster() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        _movie!.poster,
        height: 300,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      _movie!.title,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildGenre() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _movie!.genre,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildRating() {
    return Column(
      children: [
        const Text(
          "Rate this movie",
          style: TextStyle(fontSize: 18),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _rating = index + 1;
                });
              },
              child: Icon(
                index < _rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
                size: 36,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(
          "Rating: $_rating / 5",
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}
