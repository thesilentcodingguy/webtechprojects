import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Using a free movie API that doesn't require API key
const String MOVIE_API_URL = "https://freetestapi.com/api/v1/movies";

void main() {
  runApp(MyMovieApp());
}

class MyMovieApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Magic',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.purple,
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.purple,
          secondary: Colors.pink,
        ),
      ),
      home: MovieHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Movie Model
class Movie {
  final int id;
  final String title;
  final String? description;
  final String? thumbnail;
  final int? year;
  final double rating;
  final List<String> genres;
  bool isLiked = false;

  Movie({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    this.year,
    required this.rating,
    required this.genres,
    this.isLiked = false,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Unknown',
      description: json['description'],
      thumbnail: json['thumbnail'],
      year: json['year'],
      rating: (json['rating'] ?? 0).toDouble(),
      genres: List<String>.from(json['genres'] ?? []),
    );
  }

  String get yearText => year != null ? year.toString() : 'N/A';
}

// API Service
class MovieService {
  static Future<List<Movie>> getAllMovies() async {
    try {
      final response = await http.get(Uri.parse(MOVIE_API_URL));
      if (response.statusCode == 200) {
        List jsonList = json.decode(response.body);
        return jsonList.map((json) => Movie.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load movies');
      }
    } catch (e) {
      // Fallback mock data if API fails
      return getMockMovies();
    }
  }

  static Future<List<Movie>> searchMovies(String query, List<Movie> allMovies) async {
    await Future.delayed(Duration(milliseconds: 300)); // Simulate search delay
    return allMovies.where((movie) =>
    movie.title.toLowerCase().contains(query.toLowerCase()) ||
        movie.genres.any((g) => g.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  static List<Movie> getMockMovies() {
    return [
      Movie(id: 1, title: 'Inception', description: 'A thief who steals corporate secrets through dream-sharing technology.',
          thumbnail: 'https://image.tmdb.org/t/p/w500/9gk7adHYeDvHkCSEqAvQNLV5Uyi.jpg',
          year: 2010, rating: 8.8, genres: ['Action', 'Sci-Fi']),
      Movie(id: 2, title: 'The Dark Knight', description: 'Batman faces the Joker in Gotham City.',
          thumbnail: 'https://image.tmdb.org/t/p/w500/qJ2tW6WMUDux911r6m7haRef0WH.jpg',
          year: 2008, rating: 9.0, genres: ['Action', 'Crime']),
      Movie(id: 3, title: 'Interstellar', description: 'A team of explorers travel through a wormhole in space.',
          thumbnail: 'https://image.tmdb.org/t/p/w500/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
          year: 2014, rating: 8.6, genres: ['Sci-Fi', 'Drama']),
      Movie(id: 4, title: 'The Matrix', description: 'A computer hacker learns about the true nature of reality.',
          thumbnail: 'https://image.tmdb.org/t/p/w500/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg',
          year: 1999, rating: 8.7, genres: ['Action', 'Sci-Fi']),
      Movie(id: 5, title: 'Pulp Fiction', description: 'The lives of two mob hitmen, a boxer, and a gangster\'s wife intertwine.',
          thumbnail: 'https://image.tmdb.org/t/p/w500/d5iIlFn5s0ImszYzBPb8JPIfbXD.jpg',
          year: 1994, rating: 8.9, genres: ['Crime', 'Drama']),
    ];
  }
}

// Main Page
class MovieHomePage extends StatefulWidget {
  @override
  _MovieHomePageState createState() => _MovieHomePageState();
}

class _MovieHomePageState extends State<MovieHomePage> {
  List<Movie> allMovies = [];
  List<Movie> filteredMovies = [];
  List<Movie> likedMovies = [];
  bool isLoading = true;
  String searchQuery = '';
  bool isSearching = false;
  String selectedGenre = 'All';
  List<String> genres = [];

  @override
  void initState() {
    super.initState();
    loadMovies();
  }

  Future<void> loadMovies() async {
    setState(() => isLoading = true);
    allMovies = await MovieService.getAllMovies();
    filteredMovies = allMovies;

    // Extract unique genres
    Set<String> genreSet = {};
    for (var movie in allMovies) {
      genreSet.addAll(movie.genres);
    }
    genres = ['All', ...genreSet.toList()];

    setState(() => isLoading = false);
  }

  void filterMovies() {
    setState(() {
      filteredMovies = allMovies.where((movie) {
        final matchesSearch = searchQuery.isEmpty ||
            movie.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            movie.genres.any((g) => g.toLowerCase().contains(searchQuery.toLowerCase()));
        final matchesGenre = selectedGenre == 'All' || movie.genres.contains(selectedGenre);
        return matchesSearch && matchesGenre;
      }).toList();
    });
  }

  void toggleLike(Movie movie) {
    setState(() {
      movie.isLiked = !movie.isLiked;
      if (movie.isLiked) {
        likedMovies.add(movie);
        _showSnackBar('❤️ Added "${movie.title}" to favorites');
      } else {
        likedMovies.remove(movie);
        _showSnackBar('💔 Removed "${movie.title}" from favorites');
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1)),
    );
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
            hintText: 'Search by title or genre...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.grey),
          ),
          onChanged: (value) {
            searchQuery = value;
            filterMovies();
          },
        )
            : Text('🎬 Movie Magic', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearching = !isSearching;
                if (!isSearching) {
                  searchQuery = '';
                  filterMovies();
                }
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: isSearching ? SizedBox() : _buildGenreFilter(),
        ),
      ),
      body: isLoading
          ? Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading movies...', style: TextStyle(color: Colors.grey)),
        ],
      ))
          : Column(
        children: [
          if (likedMovies.isNotEmpty)
            _buildLikedMoviesBar(),
          Expanded(
            child: filteredMovies.isEmpty
                ? Center(child: Text('No movies found 🎭', style: TextStyle(fontSize: 18)))
                : GridView.builder(
              padding: EdgeInsets.all(8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: filteredMovies.length,
              itemBuilder: (context, index) {
                final movie = filteredMovies[index];
                return _buildMovieCard(movie);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenreFilter() {
    return Container(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 8),
        itemCount: genres.length,
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = selectedGenre == genre;
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: FilterChip(
              label: Text(genre),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedGenre = genre;
                  filterMovies();
                });
              },
              backgroundColor: Colors.grey[900],
              selectedColor: Colors.purple,
              labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLikedMoviesBar() {
    return Container(
      height: 120,
      color: Colors.purple.withOpacity(0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Text('❤️ Favorites (${likedMovies.length})',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink)),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: likedMovies.length,
              itemBuilder: (context, index) {
                final movie = likedMovies[index];
                return GestureDetector(
                  onTap: () => _showMovieDetails(movie),
                  child: Container(
                    width: 70,
                    margin: EdgeInsets.only(left: 8),
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey[800],
                          ),
                          child: Center(child: Icon(Icons.movie, color: Colors.pink)),
                        ),
                        Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return GestureDetector(
      onTap: () => _showMovieDetails(movie),
      onDoubleTap: () {
        toggleLike(movie);
        // Haptic feedback
      },
      onLongPress: () {
        _showMovieOptions(movie);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      color: Colors.grey[800],
                    ),
                    child: Center(
                      child: Icon(Icons.movie, size: 50, color: Colors.grey[600]),
                    ),
                  ),
                  // Like badge
                  if (movie.isLiked)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.favorite, size: 16, color: Colors.white),
                      ),
                    ),
                  // Rating badge
                  Positioned(
                    bottom: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: 12, color: Colors.amber),
                          SizedBox(width: 2),
                          Text(movie.rating.toString(), style: TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(movie.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Text(movie.yearText, style: TextStyle(fontSize: 11, color: Colors.grey)),
                    SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: movie.genres.take(2).map((genre) =>
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.purple.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(genre, style: TextStyle(fontSize: 8)),
                          )
                      ).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMovieDetails(Movie movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(movie.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 20),
                        SizedBox(width: 4),
                        Text('${movie.rating}/10', style: TextStyle(fontSize: 16)),
                        SizedBox(width: 16),
                        Icon(Icons.calendar_today, size: 16),
                        SizedBox(width: 4),
                        Text(movie.yearText),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('Genres:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: movie.genres.map((genre) =>
                          Chip(label: Text(genre))
                      ).toList(),
                    ),
                    SizedBox(height: 16),
                    Text('Storyline:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text(movie.description ?? 'No description available', style: TextStyle(height: 1.5)),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildActionButton(
                          icon: movie.isLiked ? Icons.favorite : Icons.favorite_border,
                          label: movie.isLiked ? 'Liked' : 'Like',
                          color: Colors.pink,
                          onTap: () {
                            toggleLike(movie);
                            Navigator.pop(context);
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.share,
                          label: 'Share',
                          color: Colors.blue,
                          onTap: () {
                            _showSnackBar('✨ Sharing "${movie.title}"');
                            Navigator.pop(context);
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.play_arrow,
                          label: 'Watch Trailer',
                          color: Colors.green,
                          onTap: () {
                            _showSnackBar('🎬 Trailer would play here');
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMovieOptions(Movie movie) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.favorite, color: Colors.pink),
              title: Text(movie.isLiked ? 'Remove from favorites' : 'Add to favorites'),
              onTap: () {
                toggleLike(movie);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.info, color: Colors.blue),
              title: Text('View details'),
              onTap: () {
                Navigator.pop(context);
                _showMovieDetails(movie);
              },
            ),
            ListTile(
              leading: Icon(Icons.recommend, color: Colors.orange),
              title: Text('Recommend to a friend'),
              onTap: () {
                _showSnackBar('📤 Recommendation sent!');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
