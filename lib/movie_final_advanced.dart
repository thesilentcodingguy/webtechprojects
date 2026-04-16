import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

const String apiKey = "ee9c25db"; // Add your OMDB API key here

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE50914), // Netflix red
          secondary: const Color(0xFF221f1f),
          surface: const Color(0xFF0f0f0f),
          background: const Color(0xFF0f0f0f),
        ),
        scaffoldBackgroundColor: const Color(0xFF0f0f0f),
      ),
      home: const LoginPage(),
    );
  }
}

// ================= LOGIN PAGE =================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  void _login() {
    if (usernameController.text.isNotEmpty || passwordController.text.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomePage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
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
              const Color(0xFF1a1a1a),
              const Color(0xFF0f0f0f),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    margin: const EdgeInsets.only(bottom: 50),
                    child: const Text(
                      "CINEFLIX",
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: Color(0xFFE50914),
                      ),
                    ),
                  ),
                  const Text(
                    "Sign In",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Username Field
                  _buildTextField(
                    controller: usernameController,
                    label: "Username",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 20),
                  // Password Field
                  _buildTextField(
                    controller: passwordController,
                    label: "Password",
                    icon: Icons.lock_outline,
                    obscure: true,
                  ),
                  const SizedBox(height: 40),
                  // Login Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE50914), Color(0xFFB20710)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _login,
                        borderRadius: BorderRadius.circular(8),
                        child: const Center(
                          child: Text(
                            "SIGN IN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF221f1f),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

// ================= MOVIE MODEL =================
class Movie {
  final String title;
  final String year;
  final String poster;
  final String imdbID;
  final String type;

  Movie({
    required this.title,
    required this.year,
    required this.poster,
    required this.imdbID,
    this.type = "movie",
  });
}

// ================= HOME PAGE =================
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  List<Movie> movies = [];
  List<Movie> filteredMovies = [];
  bool isLoading = false;
  String searchQuery = "inception";
  
  Map<String, double> ratings = {};
  Map<String, String> reviews = {};
  
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    fetchMovies();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> fetchMovies() async {
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse("https://www.omdbapi.com/?apikey=$apiKey&s=$searchQuery&type=movie"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data["Search"] != null) {
          setState(() {
            movies = (data["Search"] as List)
                .map((m) => Movie(
                  title: m["Title"],
                  year: m["Year"],
                  poster: m["Poster"],
                  imdbID: m["imdbID"],
                  type: m["Type"] ?? "movie",
                ))
                .toList();
            filteredMovies = movies;
          });
          _animationController.forward(from: 0);
        } else {
          _showFallback();
        }
      }
    } catch (e) {
      _showFallback();
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showFallback() {
    setState(() {
      movies = [
        Movie(title: "Inception", year: "2010", poster: "", imdbID: "1"),
        Movie(title: "The Dark Knight", year: "2008", poster: "", imdbID: "2"),
        Movie(title: "Interstellar", year: "2014", poster: "", imdbID: "3"),
        Movie(title: "Tenet", year: "2020", poster: "", imdbID: "4"),
        Movie(title: "The Matrix", year: "1999", poster: "", imdbID: "5"),
      ];
      filteredMovies = movies;
    });
  }

  void _openMovieDetail(Movie movie) async {
    try {
      final response = await http.get(
        Uri.parse("https://www.omdbapi.com/?apikey=$apiKey&i=${movie.imdbID}"),
      );

      if (response.statusCode == 200) {
        final details = jsonDecode(response.body);
        
        if (!mounted) return;
        
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => MovieDetailPage(
              movie: movie,
              details: details,
              rating: ratings[movie.imdbID] ?? 0,
              review: reviews[movie.imdbID] ?? "",
              onSave: (rating, review) {
                setState(() {
                  ratings[movie.imdbID] = rating;
                  reviews[movie.imdbID] = review;
                });
              },
            ),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                    .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading movie details: $e')),
      );
    }
  }

  Color _getRatingColor(double rating) {
    if (rating >= 4.5) return const Color(0xFF00D084);
    if (rating >= 3.5) return const Color(0xFF2DD4BF);
    if (rating >= 2.5) return const Color(0xFFFCD34D);
    if (rating >= 1.5) return const Color(0xFFFB923C);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "CINEFLIX",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: Color(0xFFE50914),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, size: 28),
            onPressed: () => _showSearchDialog(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE50914),
                strokeWidth: 3,
              ),
            )
          : filteredMovies.isEmpty
              ? const Center(
                  child: Text(
                    "No movies found\nTry another search",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                        child: Text(
                          "Popular Movies",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(12),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: filteredMovies.length,
                        itemBuilder: (context, index) {
                          return _buildMovieCard(filteredMovies[index], index);
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMovieCard(Movie movie, int index) {
    final rating = ratings[movie.imdbID] ?? 0.0;
    final ratingColor = _getRatingColor(rating);
    
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final animation = Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(index * 0.1, 1.0, curve: Curves.easeOut),
          ),
        );
        
        return Transform.translate(
          offset: Offset(0, 50 * (1 - animation.value)),
          child: Opacity(
            opacity: animation.value,
            child: GestureDetector(
              onTap: () => _openMovieDetail(movie),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.7),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Poster Image
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF221f1f),
                      ),
                      child: movie.poster.isNotEmpty && movie.poster != "N/A"
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                movie.poster,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _buildPlaceholder(),
                              ),
                            )
                          : _buildPlaceholder(),
                    ),
                    // Gradient Overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withOpacity(0.9),
                            Colors.black.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    // Content Overlay
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Rating Stars
                            if (rating > 0)
                              Row(
                                children: [
                                  ...[1, 2, 3, 4, 5].map((star) {
                                    return Icon(
                                      star <= rating ? Icons.star : Icons.star_border,
                                      size: 12,
                                      color: ratingColor,
                                    );
                                  }),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            const SizedBox(height: 6),
                            Text(
                              movie.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              movie.year,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Hover Effect
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _openMovieDetail(movie),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFF221f1f),
      ),
      child: Center(
        child: Icon(
          Icons.local_movies,
          size: 40,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  void _showSearchDialog() {
    final searchController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFF221f1f),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Search Movies",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Enter movie title...",
                  hintStyle: TextStyle(color: Colors.grey[600]),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFFE50914)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[700]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFE50914)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE50914),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      if (searchController.text.isNotEmpty) {
                        setState(() => searchQuery = searchController.text);
                        fetchMovies();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text("Search", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ================= MOVIE DETAIL PAGE =================
class MovieDetailPage extends StatefulWidget {
  final Movie movie;
  final Map<String, dynamic> details;
  final double rating;
  final String review;
  final Function(double, String) onSave;

  const MovieDetailPage({
    super.key,
    required this.movie,
    required this.details,
    required this.rating,
    required this.review,
    required this.onSave,
  });

  @override
  State<MovieDetailPage> createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> with SingleTickerProviderStateMixin {
  late double _rating;
  late TextEditingController _reviewController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _rating = widget.rating;
    _reviewController = TextEditingController(text: widget.review);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Color _getRatingColor() {
    if (_rating >= 4.5) return const Color(0xFF00D084);
    if (_rating >= 3.5) return const Color(0xFF2DD4BF);
    if (_rating >= 2.5) return const Color(0xFFFCD34D);
    if (_rating >= 1.5) return const Color(0xFFFB923C);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final posterImage = widget.movie.poster.isNotEmpty && widget.movie.poster != "N/A"
        ? widget.movie.poster
        : null;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image Section
            Stack(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(0xFF221f1f),
                  ),
                  child: posterImage != null
                      ? Image.network(
                          posterImage,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                            child: Icon(
                              Icons.local_movies,
                              size: 80,
                              color: Colors.grey[700],
                            ),
                          ),
                        )
                      : Center(
                          child: Icon(
                            Icons.local_movies,
                            size: 80,
                            color: Colors.grey[700],
                          ),
                        ),
                ),
                // Gradient Overlay
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        const Color(0xFF0f0f0f),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                // Back Button
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Year
                  Text(
                    widget.movie.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        widget.movie.year,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE50914).withOpacity(0.2),
                          border: Border.all(color: const Color(0xFFE50914)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "MOVIE",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            color: Color(0xFFE50914),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Plot
                  const Text(
                    "Plot",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.details["Plot"] ?? "No description available",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Ratings
                  const Text(
                    "Your Rating",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ...[1.0, 2.0, 3.0, 4.0, 5.0].map((star) {
                              return GestureDetector(
                                onTap: () => setState(() => _rating = star),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Icon(
                                    _rating >= star ? Icons.star : Icons.star_border,
                                    size: 40,
                                    color: _getRatingColor(),
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _rating > 0 ? "${_rating.toStringAsFixed(1)}/5.0" : "Rate this movie",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getRatingColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Review
                  const Text(
                    "Your Review",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF221f1f),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[800]!),
                    ),
                    child: TextField(
                      controller: _reviewController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Write your thoughts...",
                        hintStyle: TextStyle(color: Colors.grey[600]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        widget.onSave(_rating, _reviewController.text);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Rating saved successfully!"),
                            backgroundColor: Color(0xFFE50914),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text(
                        "SAVE RATING & REVIEW",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "CLOSE",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
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
