// main.dart
// A complete Movie Review App with OMDB API integration
// Features: Search movies, view details, rate with stars, dynamic backgrounds

import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Review App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const MovieSearchScreen(),
    );
  }
}

// ==================== MODELS ====================

class Movie {
  final String imdbID;
  final String title;
  final String year;
  final String genre;
  final String poster;
  final String plot;
  final String director;
  final String actors;
  final String imdbRating;
  final String runtime;

  Movie({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.genre,
    required this.poster,
    required this.plot,
    required this.director,
    required this.actors,
    required this.imdbRating,
    required this.runtime,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      imdbID: json['imdbID'] ?? '',
      title: json['Title'] ?? 'N/A',
      year: json['Year'] ?? 'N/A',
      genre: json['Genre'] ?? 'N/A',
      poster: json['Poster'] ?? '',
      plot: json['Plot'] ?? 'No plot available.',
      director: json['Director'] ?? 'N/A',
      actors: json['Actors'] ?? 'N/A',
      imdbRating: json['imdbRating'] ?? 'N/A',
      runtime: json['Runtime'] ?? 'N/A',
    );
  }
}

class SearchResult {
  final String imdbID;
  final String title;
  final String year;
  final String poster;
  final String type;

  SearchResult({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.poster,
    required this.type,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      imdbID: json['imdbID'] ?? '',
      title: json['Title'] ?? 'N/A',
      year: json['Year'] ?? 'N/A',
      poster: json['Poster'] ?? '',
      type: json['Type'] ?? 'movie',
    );
  }
}

class UserReview {
  final String movieId;
  final String movieTitle;
  final double userRating;
  final DateTime ratedAt;
  final String reviewText;

  UserReview({
    required this.movieId,
    required this.movieTitle,
    required this.userRating,
    required this.ratedAt,
    this.reviewText = '',
  });

  Map<String, dynamic> toJson() => {
    'movieId': movieId,
    'movieTitle': movieTitle,
    'userRating': userRating,
    'ratedAt': ratedAt.toIso8601String(),
    'reviewText': reviewText,
  };

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      movieId: json['movieId'],
      movieTitle: json['movieTitle'],
      userRating: json['userRating'].toDouble(),
      ratedAt: DateTime.parse(json['ratedAt']),
      reviewText: json['reviewText'] ?? '',
    );
  }
}

// ==================== API SERVICE ====================

class OmdbApiService {
  // IMPORTANT: Replace this with your actual OMDB API key
  static const String apiKey = 'ee9c25db';
  static const String baseUrl = 'https://www.omdbapi.com/';

  static Future<List<SearchResult>> searchMovies(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?apikey=$apiKey&s=$query&type=movie'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          final List<dynamic> movies = data['Search'];
          return movies
              .map((json) => SearchResult.fromJson(json))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to search movies');
      }
    } catch (e) {
      log('Search error: $e');
      return [];
    }
  }

  static Future<Movie?> getMovieDetails(String imdbID) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl?apikey=$apiKey&i=$imdbID&plot=full'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['Response'] == 'True') {
          return Movie.fromJson(data);
        }
        return null;
      } else {
        throw Exception('Failed to get movie details');
      }
    } catch (e) {
      log('Details error: $e');
      return null;
    }
  }
}

// ==================== RATING HELPER ====================

class RatingHelper {
  static Color getBackgroundColor(double rating) {
    if (rating >= 4.0) {
      return Colors.green.shade50;
    } else if (rating == 3.0) {
      return Colors.orange.shade50;
    } else {
      return Colors.red.shade50;
    }
  }

  static Color getBorderColor(double rating) {
    if (rating >= 4.0) {
      return Colors.green;
    } else if (rating == 3.0) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static Color getAccentColor(double rating) {
    if (rating >= 4.0) {
      return Colors.green.shade700;
    } else if (rating == 3.0) {
      return Colors.orange.shade700;
    } else {
      return Colors.red.shade700;
    }
  }

  static String getRatingMessage(double rating) {
    if (rating >= 4.0) return 'Excellent!';
    if (rating == 3.0) return 'Good';
    if (rating >= 2.0) return 'Average';
    return 'Poor';
  }
}

// ==================== PROVIDER / STATE MANAGEMENT ====================

class ReviewProvider extends ChangeNotifier {
  final Map<String, UserReview> _reviews = {};

  Map<String, UserReview> get reviews => _reviews;

  UserReview? getReviewForMovie(String movieId) {
    return _reviews[movieId];
  }

  double? getRatingForMovie(String movieId) {
    return _reviews[movieId]?.userRating;
  }

  void setRating(String movieId, String movieTitle, double rating, {String reviewText = ''}) {
    final review = UserReview(
      movieId: movieId,
      movieTitle: movieTitle,
      userRating: rating,
      ratedAt: DateTime.now(),
      reviewText: reviewText,
    );
    _reviews[movieId] = review;
    notifyListeners();
  }

  void updateReviewText(String movieId, String reviewText) {
    if (_reviews.containsKey(movieId)) {
      _reviews[movieId] = UserReview(
        movieId: movieId,
        movieTitle: _reviews[movieId]!.movieTitle,
        userRating: _reviews[movieId]!.userRating,
        ratedAt: _reviews[movieId]!.ratedAt,
        reviewText: reviewText,
      );
      notifyListeners();
    }
  }
}

// ==================== CUSTOM WIDGETS ====================

class StarRating extends StatelessWidget {
  final double rating;
  final double size;
  final Function(double)? onRatingChanged;
  final bool interactive;

  const StarRating({
    super.key,
    required this.rating,
    this.size = 32,
    this.onRatingChanged,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = (index + 1).toDouble();
        final isFullStar = rating >= starValue;
        final isHalfStar = !isFullStar && rating > index.toDouble();

        return GestureDetector(
          onTap: interactive && onRatingChanged != null
              ? () => onRatingChanged!(starValue)
              : null,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              isFullStar
                  ? Icons.star
                  : (isHalfStar ? Icons.star_half : Icons.star_border),
              size: size,
              color: Colors.amber,
            ),
          ),
        );
      }),
    );
  }
}

class RatingChip extends StatelessWidget {
  final double rating;
  final bool showMessage;

  const RatingChip({super.key, required this.rating, this.showMessage = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: RatingHelper.getBorderColor(rating),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (showMessage) ...[
            const SizedBox(width: 8),
            Text(
              RatingHelper.getRatingMessage(rating),
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class MovieCard extends StatelessWidget {
  final SearchResult movie;
  final double? userRating;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.userRating,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = userRating != null
        ? RatingHelper.getBackgroundColor(userRating!)
        : Colors.white;
    final borderColor = userRating != null
        ? RatingHelper.getBorderColor(userRating!)
        : Colors.grey.shade300;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                bottomLeft: Radius.circular(14),
              ),
              child: SizedBox(
                width: 100,
                height: 140,
                child: movie.poster != 'N/A'
                    ? Image.network(
                  movie.poster,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.movie, size: 40),
                  ),
                )
                    : Container(
                  color: Colors.grey.shade300,
                  child: const Icon(Icons.movie, size: 40),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${movie.year} • ${movie.type.toUpperCase()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (userRating != null) ...[
                      Row(
                        children: [
                          StarRating(
                            rating: userRating!,
                            size: 16,
                            interactive: false,
                          ),
                          const SizedBox(width: 8),
                          RatingChip(rating: userRating!),
                        ],
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Not rated yet',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.chevron_right, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

class ReviewTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const ReviewTextField({
    super.key,
    required this.controller,
    this.hintText = 'Write your review here...',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(12),
      ),
    );
  }
}

// ==================== MAIN SCREENS ====================

class MovieSearchScreen extends StatefulWidget {
  const MovieSearchScreen({super.key});

  @override
  State<MovieSearchScreen> createState() => _MovieSearchScreenState();
}

class _MovieSearchScreenState extends State<MovieSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final results = await OmdbApiService.searchMovies(query);

    setState(() {
      _isLoading = false;
      _searchResults = results;
      if (results.isEmpty) {
        _errorMessage = 'No movies found for "$query"';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movie Review App'),
        backgroundColor: Colors.blue.shade800,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RatedMoviesScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search movies...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _performSearch(),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Expanded(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage.isNotEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
            )
          else if (_searchResults.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.movie, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Search for a movie to get started',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final movie = _searchResults[index];
                    return ConsumerMovieCard(movieId: movie.imdbID, movie: movie);
                  },
                ),
              ),
        ],
      ),
    );
  }
}

class ConsumerMovieCard extends StatelessWidget {
  final String movieId;
  final SearchResult movie;

  const ConsumerMovieCard({
    super.key,
    required this.movieId,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final userRating = reviewProvider.getRatingForMovie(movieId);
        return MovieCard(
          movie: movie,
          userRating: userRating,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailScreen(movieId: movieId),
              ),
            );
          },
        );
      },
    );
  }
}

class MovieDetailScreen extends StatefulWidget {
  final String movieId;

  const MovieDetailScreen({super.key, required this.movieId});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  Movie? _movie;
  bool _isLoading = true;
  String _errorMessage = '';
  double _tempRating = 0;
  final TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMovieDetails();
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _loadMovieDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final movie = await OmdbApiService.getMovieDetails(widget.movieId);

    setState(() {
      _isLoading = false;
      if (movie != null) {
        _movie = movie;
      } else {
        _errorMessage = 'Failed to load movie details';
      }
    });
  }

  void _updateRating(double rating, ReviewProvider reviewProvider) {
    setState(() {
      _tempRating = rating;
    });

    reviewProvider.setRating(
      widget.movieId,
      _movie!.title,
      rating,
      reviewText: _reviewController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Rated ${_movie!.title}: ${rating.toStringAsFixed(1)} stars'),
        backgroundColor: RatingHelper.getBorderColor(rating),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _saveReviewText(ReviewProvider reviewProvider) {
    if (_movie != null) {
      reviewProvider.updateReviewText(widget.movieId, _reviewController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review saved')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final currentRating = reviewProvider.getRatingForMovie(widget.movieId) ?? _tempRating;
        final backgroundColor = currentRating > 0
            ? RatingHelper.getBackgroundColor(currentRating)
            : Colors.white;

        return Scaffold(
          body: Container(
            color: backgroundColor,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300,
                  pinned: true,
                  backgroundColor: currentRating > 0
                      ? RatingHelper.getAccentColor(currentRating)
                      : Colors.blue.shade800,
                  flexibleSpace: FlexibleSpaceBar(
                    background: _movie != null && _movie!.poster.isNotEmpty
                        ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          _movie!.poster,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade800,
                            child: const Icon(
                              Icons.movie,
                              size: 80,
                              color: Colors.white54,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                        : Container(
                      color: Colors.grey.shade800,
                      child: const Icon(Icons.movie, size: 80, color: Colors.white54),
                    ),
                    title: Text(_movie?.title ?? 'Movie Details'),                    centerTitle: true,
                  ),
                  title: Text(_movie?.title ?? 'Movie Details'),
                  titleTextStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (_isLoading)
                          const Center(child: CircularProgressIndicator())
                        else if (_errorMessage.isNotEmpty)
                          Center(
                            child: Column(
                              children: [
                                Text(_errorMessage),
                                ElevatedButton(
                                  onPressed: _loadMovieDetails,
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          )
                        else if (_movie != null) ...[
                            // Genre Chips
                            Wrap(
                              spacing: 8,
                              children: _movie!.genre.split(', ').map((genre) {
                                return Chip(
                                  label: Text(genre),
                                  backgroundColor: Colors.grey.shade200,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),

                            // Rating Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Your Rating',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  StarRating(
                                    rating: currentRating,
                                    size: 44,
                                    onRatingChanged: (rating) => _updateRating(rating, reviewProvider),
                                  ),
                                  const SizedBox(height: 12),
                                  if (currentRating > 0) ...[
                                    RatingChip(rating: currentRating, showMessage: true),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Rated on: ${reviewProvider.getReviewForMovie(widget.movieId)?.ratedAt.toString().split(' ')[0] ?? 'today'}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'Tap on a star to rate this movie',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Review Text Section
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Write a Review',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ReviewTextField(
                                    controller: _reviewController,
                                    hintText: 'Share your thoughts about this movie...',
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: () => _saveReviewText(reviewProvider),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: currentRating > 0
                                            ? RatingHelper.getAccentColor(currentRating)
                                            : Colors.blue,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                      child: const Text('Save Review'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Movie Details
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Movie Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildDetailRow('Year', _movie!.year),
                                  _buildDetailRow('Runtime', _movie!.runtime),
                                  _buildDetailRow('Director', _movie!.director),
                                  _buildDetailRow('Actors', _movie!.actors),
                                  _buildDetailRow('IMDb Rating', _movie!.imdbRating),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Plot',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _movie!.plot,
                                    style: const TextStyle(height: 1.5),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class RatedMoviesScreen extends StatelessWidget {
  const RatedMoviesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rated Movies'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, reviewProvider, child) {
          final ratedMovies = reviewProvider.reviews.values.toList()
            ..sort((a, b) => b.ratedAt.compareTo(a.ratedAt));

          if (ratedMovies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No rated movies yet',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rate some movies to see them here',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: ratedMovies.length,
            itemBuilder: (context, index) {
              final review = ratedMovies[index];
              final backgroundColor = RatingHelper.getBackgroundColor(review.userRating);
              final borderColor = RatingHelper.getBorderColor(review.userRating);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 2),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 50,
                      height: 70,
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.movie, size: 30),
                    ),
                  ),
                  title: Text(
                    review.movieTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      StarRating(
                        rating: review.userRating,
                        size: 16,
                        interactive: false,
                      ),
                      if (review.reviewText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          review.reviewText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        'Rated: ${review.ratedAt.toString().split(' ')[0]}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  trailing: RatingChip(rating: review.userRating),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailScreen(movieId: review.movieId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==================== CONSUMER WIDGET & PROVIDER SETUP ====================

class Consumer<T extends ChangeNotifier> extends StatelessWidget {
  final Widget Function(BuildContext context, T value, Widget? child) builder;

  const Consumer({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final provider = ProviderScope.of<T>(context);
    return builder(context, provider, null);
  }
}

class ProviderScope extends InheritedWidget {
  final ReviewProvider reviewProvider;

  const ProviderScope({
    super.key,
    required this.reviewProvider,
    required super.child,
  });

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProviderScope>();
    if (scope == null) {
      throw Exception('ProviderScope not found in widget tree');
    }
    return scope.reviewProvider as T;
  }

  @override
  bool updateShouldNotify(ProviderScope oldWidget) {
    return reviewProvider != oldWidget.reviewProvider;
  }
}

// Update the main app to use the provider scope
void main() {
  runApp(const MyAppWithProvider());
}

class MyAppWithProvider extends StatelessWidget {
  const MyAppWithProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      reviewProvider: ReviewProvider(),
      child: MaterialApp(
        title: 'Movie Review App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const MovieSearchScreen(),
      ),
    );
  }
}
