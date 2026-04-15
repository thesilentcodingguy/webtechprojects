import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const MoodQuoteApp());
}

class MoodQuoteApp extends StatelessWidget {
  const MoodQuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mood Quotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        fontFamily: 'SF Pro Text',
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF818CF8),
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          clipBehavior: Clip.antiAlias,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const QuoteHomePage(),
    );
  }
}

class QuoteHomePage extends StatefulWidget {
  const QuoteHomePage({super.key});

  @override
  State<QuoteHomePage> createState() => _QuoteHomePageState();
}

class _QuoteHomePageState extends State<QuoteHomePage> with TickerProviderStateMixin {
  Mood selectedMood = Mood.inspired;
  String currentQuote = "";
  String currentAuthor = "";
  bool isLoading = false;
  String errorMessage = "";

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final Map<Mood, List<Map<String, String>>> _cachedQuotes = {};
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
    _fetchQuoteForMood(selectedMood);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuoteForMood(Mood mood) async {
    setState(() {
      isLoading = true;
      errorMessage = "";
    });

    _fadeController.reset();

    try {
      // Check cache first
      if (_cachedQuotes.containsKey(mood) && _cachedQuotes[mood]!.isNotEmpty) {
        final cachedList = _cachedQuotes[mood]!;
        final randomIndex = _random.nextInt(cachedList.length);
        final quote = cachedList[randomIndex];
        setState(() {
          currentQuote = quote['text']!;
          currentAuthor = quote['author']!;
          isLoading = false;
        });
        _fadeController.forward();
        return;
      }

      // Fetch from API (ZenQuotes.io - free, no API key required)
      final moodQuery = _getMoodQuery(mood);
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/quotes/$moodQuery'),
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        List<Map<String, String>> quotesList = [];

        for (var item in data) {
          if (item['q'] != null && item['a'] != null) {
            quotesList.add({
              'text': item['q'].toString(),
              'author': item['a'].toString(),
            });
          }
        }

        if (quotesList.isNotEmpty) {
          _cachedQuotes[mood] = quotesList;
          final randomIndex = _random.nextInt(quotesList.length);
          final quote = quotesList[randomIndex];
          setState(() {
            currentQuote = quote['text']!;
            currentAuthor = quote['author']!;
            isLoading = false;
          });
        } else {
          _useFallbackQuote(mood);
        }
      } else {
        _useFallbackQuote(mood);
      }
    } catch (e) {
      _useFallbackQuote(mood);
      setState(() {
        errorMessage = "Using offline quotes";
      });
    } finally {
      _fadeController.forward();
    }
  }

  void _useFallbackQuote(Mood mood) {
    final fallback = _getFallbackQuotes(mood);
    final randomIndex = _random.nextInt(fallback.length);
    setState(() {
      currentQuote = fallback[randomIndex]['text']!;
      currentAuthor = fallback[randomIndex]['author']!;
      isLoading = false;
    });
  }

  String _getMoodQuery(Mood mood) {
    switch (mood) {
      case Mood.happy: return 'happiness';
      case Mood.sad: return 'hope';
      case Mood.motivated: return 'success';
      case Mood.calm: return 'peace';
      case Mood.inspired: return 'inspirational';
      case Mood.anxious: return 'calm';
    }
  }

  List<Map<String, String>> _getFallbackQuotes(Mood mood) {
    final fallbacks = {
      Mood.happy: [
        {'text': 'Happiness is not by chance, but by choice.', 'author': 'Jim Rohn'},
        {'text': 'The most wasted of days is one without laughter.', 'author': 'E.E. Cummings'},
        {'text': 'Happiness radiates like the fragrance from a flower.', 'author': 'Unknown'},
      ],
      Mood.sad: [
        {'text': 'The sun will rise and we will try again.', 'author': 'Twenty One Pilots'},
        {'text': 'Every storm runs out of rain.', 'author': 'Maya Angelou'},
        {'text': 'Tough times never last, but tough people do.', 'author': 'Robert H. Schuller'},
      ],
      Mood.motivated: [
        {'text': 'The only way to do great work is to love what you do.', 'author': 'Steve Jobs'},
        {'text': 'Don\'t watch the clock; do what it does. Keep going.', 'author': 'Sam Levenson'},
        {'text': 'Your limitation—it\'s only your imagination.', 'author': 'Unknown'},
      ],
      Mood.calm: [
        {'text': 'Peace is not absence of conflict, it is the ability to handle conflict by peaceful means.', 'author': 'Ronald Reagan'},
        {'text': 'Within you, there is a stillness and a sanctuary.', 'author': 'Henry David Thoreau'},
        {'text': 'Calm mind brings inner strength.', 'author': 'Dalai Lama'},
      ],
      Mood.inspired: [
        {'text': 'The future belongs to those who believe in the beauty of their dreams.', 'author': 'Eleanor Roosevelt'},
        {'text': 'You are never too old to set another goal or to dream a new dream.', 'author': 'C.S. Lewis'},
        {'text': 'What you get by achieving your goals is not as important as what you become.', 'author': 'Zig Ziglar'},
      ],
      Mood.anxious: [
        {'text': 'Breathe. Let go. And remind yourself that this very moment is the only one you know you have for sure.', 'author': 'Oprah Winfrey'},
        {'text': 'Nothing can disturb your peace of mind unless you allow it to.', 'author': 'Marcus Aurelius'},
        {'text': 'Worrying is like paying a debt you don\'t owe.', 'author': 'Mark Twain'},
      ],
    };
    return fallbacks[mood]!;
  }

  void _changeMood(Mood mood) {
    if (selectedMood == mood) return;
    setState(() {
      selectedMood = mood;
    });
    _fetchQuoteForMood(mood);
  }

  void _nextQuote() {
    if (!isLoading) {
      _fetchQuoteForMood(selectedMood);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Mood Quotes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? Colors.white : const Color(0xFF1E1B2E),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]
                : [const Color(0xFFE0E7FF), const Color(0xFFF3E8FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Mood selection chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: Mood.values.map((mood) {
                    final isSelected = selectedMood == mood;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: FilterChip(
                        label: Text(
                          mood.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        selected: isSelected,
                        onSelected: (_) => _changeMood(mood),
                        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white.withValues(alpha: 0.7),
                        selectedColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? Colors.white70 : const Color(0xFF1E1B2E)),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: isSelected
                              ? BorderSide.none
                              : BorderSide(color: (isDark ? Colors.white24 : Colors.black12)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 32),

              // Quote card with swipe gesture
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GestureDetector(
                    onHorizontalDragEnd: (details) {
                      if (details.primaryVelocity! > 0) {
                        // Swipe right - new quote
                        _nextQuote();
                      } else if (details.primaryVelocity! < 0) {
                        // Swipe left - new quote
                        _nextQuote();
                      }
                    },
                    child: AnimatedBuilder(
                      animation: _fadeController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _fadeAnimation.value,
                          child: Transform.scale(
                            scale: 0.95 + (0.05 * _fadeAnimation.value),
                            child: child,
                          ),
                        );
                      },
                      child: Card(
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(36),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(36),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: isDark
                                  ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                                  : [Colors.white, const Color(0xFFF8FAFC)],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Mood icon and badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: (isDark ? const Color(0xFF6366F1) : const Color(0xFF818CF8)).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      selectedMood.icon,
                                      size: 20,
                                      color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      selectedMood.displayName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF6366F1),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Quote text
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 28),
                                child: isLoading
                                    ? const Column(
                                  children: [
                                    SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Finding inspiration...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontStyle: FontStyle.italic,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )
                                    : Text(
                                  '"$currentQuote"',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                    letterSpacing: -0.3,
                                    color: isDark ? Colors.white : const Color(0xFF1E1B2E),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // Author
                              if (!isLoading && currentAuthor.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 28),
                                  child: Text(
                                    '— $currentAuthor —',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w400,
                                      fontStyle: FontStyle.italic,
                                      color: isDark ? Colors.white60 : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 48),

                              // Swipe hint
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.swipe_rounded,
                                    size: 20,
                                    color: isDark ? Colors.white38 : Colors.grey.shade400,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Swipe left or right for new quote',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Error message
              if (errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.orange.shade300 : Colors.orange.shade700,
                    ),
                  ),
                ),

              // New quote button
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _nextQuote,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('New Quote'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    backgroundColor: isDark ? const Color(0xFF6366F1) : const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum Mood {
  happy,
  sad,
  motivated,
  calm,
  inspired,
  anxious;
}

extension MoodExtension on Mood {
  String get label {
    switch (this) {
      case Mood.happy: return '😊 Happy';
      case Mood.sad: return '😔 Sad';
      case Mood.motivated: return '⚡ Motivated';
      case Mood.calm: return '🍃 Calm';
      case Mood.inspired: return '✨ Inspired';
      case Mood.anxious: return '🌊 Anxious';
    }
  }

  String get displayName {
    switch (this) {
      case Mood.happy: return 'Feeling Happy';
      case Mood.sad: return 'Feeling Sad';
      case Mood.motivated: return 'Feeling Motivated';
      case Mood.calm: return 'Feeling Calm';
      case Mood.inspired: return 'Feeling Inspired';
      case Mood.anxious: return 'Feeling Anxious';
    }
  }

  IconData get icon {
    switch (this) {
      case Mood.happy: return Icons.sentiment_very_satisfied;
      case Mood.sad: return Icons.sentiment_dissatisfied;
      case Mood.motivated: return Icons.bolt;
      case Mood.calm: return Icons.spa;
      case Mood.inspired: return Icons.auto_awesome;
      case Mood.anxious: return Icons.waves;
    }
  }
}
