import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  runApp(const ElectionApp());
}

/// =======================
/// APP ROOT WITH THEME
/// =======================
class ElectionApp extends StatelessWidget {
  const ElectionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Election News Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[900],
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

/// =======================
/// ENHANCED MODEL
/// =======================
class News {
  final String id;
  final String constituency;
  final String title;
  final String description;
  final DateTime timestamp;
  final NewsPriority priority;
  final String imageUrl;

  News({
    required this.id,
    required this.constituency,
    required this.title,
    required this.description,
    required this.timestamp,
    this.priority = NewsPriority.normal,
    this.imageUrl = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'constituency': constituency,
    'title': title,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
    'priority': priority.index,
    'imageUrl': imageUrl,
  };

  factory News.fromJson(Map<String, dynamic> json) => News(
    id: json['id'],
    constituency: json['constituency'],
    title: json['title'],
    description: json['description'],
    timestamp: DateTime.parse(json['timestamp']),
    priority: NewsPriority.values[json['priority']],
    imageUrl: json['imageUrl'] ?? '',
  );
}

enum NewsPriority { low, normal, high, urgent }

extension NewsPriorityExtension on NewsPriority {
  Color get color {
    switch (this) {
      case NewsPriority.low:
        return Colors.grey;
      case NewsPriority.normal:
        return Colors.blue;
      case NewsPriority.high:
        return Colors.orange;
      case NewsPriority.urgent:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (this) {
      case NewsPriority.low:
        return Icons.info_outline;
      case NewsPriority.normal:
        return Icons.notifications_none;
      case NewsPriority.high:
        return Icons.warning_amber;
      case NewsPriority.urgent:
        return Icons.error;
    }
  }
}

/// =======================
/// ADVANCED CACHE SERVICE WITH TTL
/// =======================
class CacheService {
  static final Map<String, _CacheEntry<List<News>>> _cache = {};
  static const Duration _defaultTTL = Duration(minutes: 5);

  static void store(String key, List<News> news, {Duration? ttl}) {
    _cache[key] = _CacheEntry(
      data: news,
      expiryTime: DateTime.now().add(ttl ?? _defaultTTL),
    );
  }

  static List<News>? get(String key) {
    final entry = _cache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data;
    }
    _cache.remove(key);
    return null;
  }

  static void clear() {
    _cache.clear();
  }

  static void clearExpired() {
    _cache.removeWhere((_, entry) => entry.isExpired);
  }
}

class _CacheEntry<T> {
  final T data;
  final DateTime expiryTime;

  _CacheEntry({required this.data, required this.expiryTime});

  bool get isExpired => DateTime.now().isAfter(expiryTime);
}

/// =======================
/// ENHANCED LOAD BALANCER WITH WEIGHTS
/// =======================
class LoadBalancer {
  static final List<_Server> _servers = [
    _Server('Server A', weight: 5, region: 'North'),
    _Server('Server B', weight: 3, region: 'South'),
    _Server('Server C', weight: 2, region: 'East'),
  ];

  static int _currentIndex = 0;
  static final Random _random = Random();

  static String getServer({bool useRoundRobin = false}) {
    if (useRoundRobin) {
      final server = _servers[_currentIndex];
      _currentIndex = (_currentIndex + 1) % _servers.length;
      return server.name;
    }

    // Weighted random selection
    final totalWeight = _servers.fold(0, (sum, s) => sum + s.weight);
    var randomValue = _random.nextInt(totalWeight);

    for (final server in _servers) {
      if (randomValue < server.weight) {
        return server.name;
      }
      randomValue -= server.weight;
    }

    return _servers.first.name;
  }
}

class _Server {
  final String name;
  final int weight;
  final String region;

  _Server(this.name, {required this.weight, required this.region});
}

/// =======================
/// ENHANCED MOCK SERVER
/// =======================
class MockServer {
  static final List<String> _newsTemplates = [
    "Candidate announces major policy change",
    "Voter turnout reaches new record",
    "Debate highlights: Key moments from last night",
    "Election commission issues new guidelines",
    "Controversy erupts over campaign financing",
    "Polling stations prepare for upcoming vote",
    "International observers arrive for election",
    "Security measures tightened across constituency",
  ];

  static Future<List<News>> fetchNews(String constituency) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + Random().nextInt(400)));

    final server = LoadBalancer.getServer();
    final count = 1 + Random().nextInt(3);

    return List.generate(count, (index) {
      final priority = NewsPriority.values[Random().nextInt(4)];
      final template = _newsTemplates[Random().nextInt(_newsTemplates.length)];

      return News(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        constituency: constituency,
        title: "$constituency: $template",
        description: "From $server | Breaking election news #${Random().nextInt(1000)} - ${_getRandomDescription()}",
        timestamp: DateTime.now(),
        priority: priority,
        imageUrl: _getRandomImageUrl(),
      );
    });
  }

  static String _getRandomDescription() {
    final descriptions = [
      "Latest updates from the campaign trail show shifting voter preferences.",
      "Analysis of recent polling data indicates a tight race ahead.",
      "Local leaders weigh in on critical issues affecting the constituency.",
      "Exclusive: Behind the scenes with key political strategists.",
      "Voter interviews reveal growing concern about local development.",
    ];
    return descriptions[Random().nextInt(descriptions.length)];
  }

  static String _getRandomImageUrl() {
    final images = [
      'https://picsum.photos/id/100/200/150',
      'https://picsum.photos/id/101/200/150',
      'https://picsum.photos/id/102/200/150',
      'https://picsum.photos/id/104/200/150',
    ];
    return images[Random().nextInt(images.length)];
  }
}

/// =======================
/// ENHANCED NOTIFICATION SERVICE
/// =======================
class NotificationService {
  static final StreamController<News> _controller = StreamController.broadcast();
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Stream<News> get stream => _controller.stream;

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> push(News news) async {
    _controller.add(news);

    // Show local notification
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'election_channel',
      'Election News',
      channelDescription: 'Real-time election news updates',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.show(
      news.id.hashCode,
      news.title,
      news.description,
      platformChannelSpecifics,
    );
  }

  static void dispose() {
    _controller.close();
  }
}

/// =======================
/// ENHANCED NEWS SERVICE
/// =======================
class NewsService {
  static final Map<String, Timer> _pushTimers = {};
  static bool _isSimulating = false;

  static Future<List<News>> getNews(String constituency, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = CacheService.get(constituency);
      if (cached != null) {
        return cached;
      }
    }

    final news = await MockServer.fetchNews(constituency);
    CacheService.store(constituency, news);
    return news;
  }

  static void startPushSimulation(Set<String> subscribed) {
    if (_isSimulating) return;
    _isSimulating = true;

    Timer.periodic(const Duration(seconds: 5), (timer) {
      if (subscribed.isEmpty) return;

      final constituency = subscribed.elementAt(Random().nextInt(subscribed.length));

      MockServer.fetchNews(constituency).then((newsList) {
        for (final news in newsList) {
          if (subscribed.contains(news.constituency)) {
            NotificationService.push(news);
          }
        }
      });
    });
  }

  static void stopPushSimulation() {
    _isSimulating = false;
    for (final timer in _pushTimers.values) {
      timer.cancel();
    }
    _pushTimers.clear();
  }
}

/// =======================
/// HOME SCREEN WITH ADVANCED UI
/// =======================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Constituency> constituencies = [
    Constituency('Chennai Central', 'TN-01', Colors.blue),
    Constituency('Coimbatore', 'TN-02', Colors.green),
    Constituency('Madurai', 'TN-03', Colors.orange),
    Constituency('Salem', 'TN-04', Colors.purple),
    Constituency('Trichy', 'TN-05', Colors.teal),
    Constituency('Tirunelveli', 'TN-06', Colors.indigo),
  ];

  final Set<String> subscribed = {};
  final List<News> allNews = [];
  final List<News> favoriteNews = [];

  bool _isLoading = false;
  String _searchQuery = '';
  NewsPriority? _filterPriority;
  bool _showFavoritesOnly = false;
  int _totalNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadSubscriptions();
    NewsService.startPushSimulation(subscribed);

    NotificationService.stream.listen((news) {
      if (subscribed.contains(news.constituency)) {
        setState(() {
          allNews.insert(0, news);
          _totalNotifications++;
        });
        _showSnackBar(news);
      }
    });
  }

  @override
  void dispose() {
    NewsService.stopPushSimulation();
    NotificationService.dispose();
    super.dispose();
  }

  Future<void> _loadSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('subscriptions') ?? [];
    setState(() {
      subscribed.addAll(saved);
    });

    for (final sub in saved) {
      await _loadInitialNews(sub);
    }
  }

  Future<void> _saveSubscriptions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('subscriptions', subscribed.toList());
  }

  void _showSnackBar(News news) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(news.priority.icon, color: news.priority.color, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text("🔔 ${news.title}")),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'VIEW',
          onPressed: () => _showNewsDialog(news),
        ),
      ),
    );
  }

  void _showNewsDialog(News news) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(news.priority.icon, color: news.priority.color),
            const SizedBox(width: 8),
            Expanded(child: Text(news.title)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (news.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(news.imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
            const SizedBox(height: 12),
            Text(news.description),
            const SizedBox(height: 8),
            Text(
              'Constituency: ${news.constituency}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Time: ${_formatTime(news.timestamp)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                if (!favoriteNews.contains(news)) {
                  favoriteNews.add(news);
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Added to favorites')),
              );
            },
            child: const Text('FAVORITE'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Future<void> toggleSubscription(Constituency c) async {
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 300));

    setState(() {
      if (subscribed.contains(c.id)) {
        subscribed.remove(c.id);
        _showCustomSnackBar('Unsubscribed from ${c.name}', Colors.grey);
      } else {
        subscribed.add(c.id);
        _loadInitialNews(c.id);
        _showCustomSnackBar('Subscribed to ${c.name}', Colors.green);
      }
      _isLoading = false;
    });

    await _saveSubscriptions();
  }

  void _showCustomSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _loadInitialNews(String constituencyId) async {
    final news = await NewsService.getNews(constituencyId);
    setState(() {
      allNews.insertAll(0, news);
    });
  }

  void _clearAllNews() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All News'),
        content: const Text('Are you sure you want to clear all news?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => allNews.clear());
              Navigator.pop(context);
              _showCustomSnackBar('All news cleared', Colors.orange);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }

  List<News> get _filteredNews {
    var news = _showFavoritesOnly ? favoriteNews : allNews;

    if (_filterPriority != null) {
      news = news.where((n) => n.priority == _filterPriority).toList();
    }

    if (_searchQuery.isNotEmpty) {
      news = news.where((n) =>
      n.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          n.constituency.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return news;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election News Hub'),
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  _showCustomSnackBar('$_totalNotifications total notifications', Colors.blue);
                },
              ),
              if (_totalNotifications > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '$_totalNotifications',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              setState(() => _showFavoritesOnly = !_showFavoritesOnly);
              _showCustomSnackBar(
                _showFavoritesOnly ? 'Showing favorites only' : 'Showing all news',
                Colors.red,
              );
            },
            color: _showFavoritesOnly ? Colors.red : null,
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'clear_cache') {
                CacheService.clear();
                setState(() {});
                _showCustomSnackBar('Cache cleared', Colors.orange);
              } else if (value == 'clear_favorites') {
                setState(() => favoriteNews.clear());
                _showCustomSnackBar('Favorites cleared', Colors.orange);
              } else if (value == 'refresh_all') {
                setState(() {});
                _showCustomSnackBar('Refreshed', Colors.green);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh_all', child: Text('Refresh All')),
              const PopupMenuItem(value: 'clear_cache', child: Text('Clear Cache')),
              const PopupMenuItem(value: 'clear_favorites', child: Text('Clear Favorites')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          _buildSubscriptions(),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildNewsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search news...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => setState(() => _searchQuery = ''),
          )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[800],
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          FilterChip(
            label: const Text('All'),
            selected: _filterPriority == null,
            onSelected: (_) => setState(() => _filterPriority = null),
          ),
          const SizedBox(width: 8),
          ...NewsPriority.values.map((priority) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(priority.toString().split('.').last),
              selected: _filterPriority == priority,
              onSelected: (_) => setState(() => _filterPriority = priority),
              backgroundColor: priority.color.withOpacity(0.2),
              selectedColor: priority.color.withOpacity(0.5),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildSubscriptions() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: constituencies.length,
        itemBuilder: (context, index) {
          final c = constituencies[index];
          final isSub = subscribed.contains(c.id);

          return GestureDetector(
            onTap: () => toggleSubscription(c),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Unsubscribe from ${c.name}?'),
                  content: const Text('This will remove all news from this constituency.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => subscribed.remove(c.id));
                        _saveSubscriptions();
                        Navigator.pop(context);
                        _showCustomSnackBar('Unsubscribed from ${c.name}', Colors.grey);
                      },
                      child: const Text('UNSUBSCRIBE'),
                    ),
                  ],
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.all(8),
              width: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSub ? [c.color, c.color.withOpacity(0.7)] : [Colors.grey[700]!, Colors.grey[800]!],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isSub)
                    BoxShadow(
                      color: c.color.withOpacity(0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isSub ? Icons.notifications_active : Icons.notifications_off, color: Colors.white, size: 24),
                  const SizedBox(height: 4),
                  Text(
                    c.name,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNewsList() {
    final filtered = _filteredNews;

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.newspaper, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              _showFavoritesOnly ? 'No favorite news yet' : 'No news available',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (!_showFavoritesOnly)
              Text(
                'Subscribe to constituencies to get news',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        CacheService.clear();
        for (final sub in subscribed) {
          await _loadInitialNews(sub);
        }
      },
      child: ReorderableListView.builder(
        itemCount: filtered.length,
        onReorder: (oldIndex, newIndex) {
          setState(() {
            if (newIndex > oldIndex) newIndex--;
            final item = filtered.removeAt(oldIndex);
            filtered.insert(newIndex, item);
          });
        },
        itemBuilder: (context, index) {
          final news = filtered[index];
          final isFavorite = favoriteNews.contains(news);

          return Dismissible(
            key: ValueKey(news.id),
            direction: DismissDirection.endToStart,
            onDismissed: (_) {
              setState(() {
                allNews.remove(news);
                favoriteNews.remove(news);
              });
              _showCustomSnackBar('News dismissed', Colors.grey);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 2,
              child: InkWell(
                onTap: () => _showNewsDialog(news),
                onLongPress: () {
                  setState(() {
                    if (isFavorite) {
                      favoriteNews.remove(news);
                    } else {
                      favoriteNews.add(news);
                    }
                  });
                  _showCustomSnackBar(
                    isFavorite ? 'Removed from favorites' : 'Added to favorites',
                    Colors.red,
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(news.priority.icon, color: news.priority.color, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              news.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isFavorite)
                            const Icon(Icons.favorite, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            _formatTime(news.timestamp),
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        news.description,
                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              news.constituency,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${news.priority.toString().split('.').last.toUpperCase()}',
                            style: TextStyle(fontSize: 10, color: news.priority.color),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Constituency {
  final String name;
  final String id;
  final Color color;

  Constituency(this.name, this.id, this.color);
}
