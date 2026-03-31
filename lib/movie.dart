import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String TMDB_BASE_URL = "https://api.themoviedb.org/3";
const String TMDB_IMG = "https://image.tmdb.org/t/p/w500";
const String API_KEY = "YOUR_API_KEY_HERE"; // Replace with your TMDB API key

void main() {
  runApp(MyMovieApp());
}

class MyMovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Explorer',
      theme: ThemeData.dark(),
      home: MovieHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Models
class Movie {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? releaseDate;
  final double voteAverage;
  final List<int> genreIds;
  
  Movie({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.releaseDate,
    required this.voteAverage,
    required this.genreIds,
  });
  
  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      overview: json['overview'],
      posterPath: json['poster_path'],
      releaseDate: json['release_date'],
      voteAverage: (json['vote_average'] ?? 0).toDouble(),
      genreIds: List<int>.from(json['genre_ids'] ?? []),
    );
  }
  
  String get year => releaseDate?.split('-')[0] ?? 'N/A';
  String get posterUrl => posterPath != null ? '$TMDB_IMG$posterPath' : '';
}

class Genre {
  final int id;
  final String name;
  
  Genre({required this.id, required this.name});
  
  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'], name: json['name']);
  }
}

// API Service
class MovieAPI {
  static Future<Map<String, dynamic>> _get(String endpoint) async {
    final url = Uri.parse('$TMDB_BASE_URL/$endpoint?api_key=$API_KEY');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load: ${response.statusCode}');
    }
  }
  
  static Future<List<Movie>> getMovies(String type, {int page = 1}) async {
    final data = await _get('movie/$type?page=$page');
    return (data['results'] as List)
        .map((json) => Movie.fromJson(json))
        .where((m) => m.posterUrl.isNotEmpty)
        .toList();
  }
  
  static Future<List<Movie>> searchMovies(String query) async {
    if (query.isEmpty) return [];
    final data = await _get('search/movie?query=${Uri.encodeComponent(query)}');
    return (data['results'] as List)
        .map((json) => Movie.fromJson(json))
        .where((m) => m.posterUrl.isNotEmpty)
        .toList();
  }
  
  static Future<Map<String, dynamic>> getMovieDetails(int id) async {
    final movieData = await _get('movie/$id');
    final creditsData = await _get('movie/$id/credits');
    final similarData = await _get('movie/$id/similar');
    
    return {
      'movie': Movie.fromJson(movieData),
      'cast': (creditsData['cast'] as List).take(10).toList(),
      'similar': (similarData['results'] as List)
          .map((json) => Movie.fromJson(json))
          .where((m) => m.posterUrl.isNotEmpty)
          .take(10)
          .toList(),
    };
  }
  
  static Future<List<Genre>> getGenres() async {
    final data = await _get('genre/movie/list');
    return (data['genres'] as List)
        .map((json) => Genre.fromJson(json))
        .toList();
  }
  
  static Future<List<Movie>> getMoviesByGenre(int genreId) async {
    final data = await _get('discover/movie?with_genres=$genreId');
    return (data['results'] as List)
        .map((json) => Movie.fromJson(json))
        .where((m) => m.posterUrl.isNotEmpty)
        .toList();
  }
}

// Main Page
class MovieHomePage extends StatefulWidget {
  @override
  _MovieHomePageState createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  List<Movie> trending = [];
  List<Movie> popular = [];
  List<Movie> topRated = [];
  List<Movie> upcoming = [];
  List<Movie> nowPlaying = [];
  List<Genre> genres = [];
  bool isLoading = true;
  String searchQuery = '';
  List<Movie> searchResults = [];
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  Future<void> loadAllData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        MovieAPI.getMovies('trending/week'),
        MovieAPI.getMovies('popular'),
        MovieAPI.getMovies('top_rated'),
        MovieAPI.getMovies('upcoming'),
        MovieAPI.getMovies('now_playing'),
        MovieAPI.getGenres(),
      ]);
      
      setState(() {
        trending = results[0];
        popular = results[1];
        topRated = results[2];
        upcoming = results[3];
        nowPlaying = results[4];
        genres = results[5];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.showSnackBar(context, SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> performSearch() async {
    if (searchQuery.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults = [];
      });
      return;
    }
    
    setState(() => isLoading = true);
    try {
      final results = await MovieAPI.searchMovies(searchQuery);
      setState(() {
        searchResults = results;
        isSearching = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.showSnackBar(context, SnackBar(content: Text('Search error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: isSearching 
            ? TextField(
                autofocus: true,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search movies...',
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  searchQuery = value;
                  performSearch();
                },
                onChanged: (value) {
                  searchQuery = value;
                  if (value.isEmpty) {
                    setState(() => isSearching = false);
                  }
                },
              )
            : Text('Movie Explorer'),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                if (isSearching) {
                  isSearching = false;
                  searchQuery = '';
                  searchResults = [];
                } else {
                  isSearching = true;
                }
              });
            },
          ),
        ],
      ),
      body: isLoading 
          ? Center(child: CircularProgressIndicator())
          : isSearching 
              ? buildSearchResults()
              : buildHomeContent(),
    );
  }

  Widget buildSearchResults() {
    if (searchResults.isEmpty && searchQuery.isNotEmpty) {
      return Center(child: Text('No movies found for "$searchQuery"'));
    }
    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final movie = searchResults[index];
        return ListTile(
          leading: movie.posterUrl.isNotEmpty 
              ? Image.network(movie.posterUrl, width: 50, fit: BoxFit.cover)
              : Container(width: 50, color: Colors.grey),
          title: Text(movie.title),
          subtitle: Text('${movie.year} ⭐ ${movie.voteAverage}'),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: movie.id)),
          ),
        );
      },
    );
  }

  Widget buildHomeContent() {
    return ListView(
      children: [
        buildSection('🔥 Trending', trending),
        buildSection('⭐ Popular', popular),
        buildSection('🏆 Top Rated', topRated),
        buildSection('📅 Upcoming', upcoming),
        buildSection('🎬 Now Playing', nowPlaying),
        buildGenreSection(),
      ],
    );
  }

  Widget buildSection(String title, List<Movie> movies) {
    if (movies.isEmpty) return SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Container(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: movie.id)),
                ),
                child: Container(
                  width: 130,
                  margin: EdgeInsets.only(left: 8, right: 8),
                  child: Column(
                    children: [
                      Expanded(
                        child: movie.posterUrl.isNotEmpty
                            ? Image.network(movie.posterUrl, fit: BoxFit.cover)
                            : Container(color: Colors.grey),
                      ),
                      Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      Text('⭐ ${movie.voteAverage}', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildGenreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('🎭 Genres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          padding: EdgeInsets.all(16),
          children: genres.map((genre) {
            return ActionChip(
              label: Text(genre.name),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GenreMoviesPage(genreId: genre.id, genreName: genre.name),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Movie Detail Page
class MovieDetailPage extends StatefulWidget {
  final int movieId;
  MovieDetailPage({required this.movieId});

  @override
  _MovieDetailPageState createState() => _MovieDetailPageState();
}

class _MovieDetailPageState extends State<MovieDetailPage> {
  Movie? movie;
  List<dynamic> cast = [];
  List<Movie> similar = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadDetails();
  }

  Future<void> loadDetails() async {
    setState(() => isLoading = true);
    try {
      final data = await MovieAPI.getMovieDetails(widget.movieId);
      setState(() {
        movie = data['movie'];
        cast = data['cast'];
        similar = data['similar'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.showSnackBar(context, SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(appBar: AppBar(), body: Center(child: CircularProgressIndicator()));
    }
    
    if (movie == null) {
      return Scaffold(appBar: AppBar(), body: Center(child: Text('Movie not found')));
    }

    return Scaffold(
      appBar: AppBar(title: Text(movie!.title)),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          if (movie!.posterUrl.isNotEmpty)
            Image.network(movie!.posterUrl, height: 300, fit: BoxFit.cover),
          SizedBox(height: 16),
          Text(movie!.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text('${movie!.year} ⭐ ${movie!.voteAverage}/10'),
          SizedBox(height: 16),
          Text('Overview:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Text(movie!.overview ?? 'No overview available'),
          SizedBox(height: 16),
          if (cast.isNotEmpty) ...[
            Text('Cast:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: cast.map((actor) => Chip(label: Text(actor['name'] ?? 'Unknown'))).toList(),
            ),
          ],
          if (similar.isNotEmpty) ...[
            SizedBox(height: 16),
            Text('Similar Movies:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: similar.length,
                itemBuilder: (context, index) {
                  final m = similar[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: m.id)),
                      );
                    },
                    child: Container(
                      width: 100,
                      margin: EdgeInsets.only(right: 8),
                      child: Column(
                        children: [
                          Expanded(
                            child: m.posterUrl.isNotEmpty
                                ? Image.network(m.posterUrl, fit: BoxFit.cover)
                                : Container(color: Colors.grey),
                          ),
                          Text(m.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// Genre Movies Page
class GenreMoviesPage extends StatelessWidget {
  final int genreId;
  final String genreName;
  
  GenreMoviesPage({required this.genreId, required this.genreName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(genreName)),
      body: FutureBuilder<List<Movie>>(
        future: MovieAPI.getMoviesByGenre(genreId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          
          final movies = snapshot.data!;
          if (movies.isEmpty) {
            return Center(child: Text('No movies found'));
          }
          
          return GridView.builder(
            padding: EdgeInsets.all(8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MovieDetailPage(movieId: movie.id)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: movie.posterUrl.isNotEmpty
                          ? Image.network(movie.posterUrl, fit: BoxFit.cover)
                          : Container(color: Colors.grey),
                    ),
                    Text(movie.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                    Text('⭐ ${movie.voteAverage}'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

extension on ScaffoldMessenger {
  static void showSnackBar(BuildContext context, SnackBar snackBar) {
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
