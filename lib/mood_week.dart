import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodMuse',
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        brightness: Brightness.light,
        primaryColor: const Color(0xFF6C63FF),
        scaffoldBackgroundColor: const Color(0xFFF8F9FF),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          brightness: Brightness.light,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const MoodTrackerHome(),
    );
  }
}

class Mood {
  final String name;
  final IconData icon;
  final Color color;
  final String emoji;

  const Mood({
    required this.name,
    required this.icon,
    required this.color,
    required this.emoji,
  });
}

class MoodEntry {
  final DateTime date;
  final Mood mood;
  final String note;

  MoodEntry({
    required this.date,
    required this.mood,
    this.note = '',
  });
}

class MoodTrackerHome extends StatefulWidget {
  const MoodTrackerHome({super.key});

  @override
  State<MoodTrackerHome> createState() => _MoodTrackerHomeState();
}

class _MoodTrackerHomeState extends State<MoodTrackerHome> {
  final Map<DateTime, MoodEntry> _moodEntries = {};
  DateTime _selectedDate = DateTime.now();
  String _note = '';

  // Available moods
  final List<Mood> _moods = const [
    Mood(name: 'Amazing', icon: Icons.emoji_emotions, color: Color(0xFFFFD700), emoji: '🤩'),
    Mood(name: 'Happy', icon: Icons.sentiment_very_satisfied, color: Color(0xFFA5D6A5), emoji: '😊'),
    Mood(name: 'Calm', icon: Icons.spa, color: Color(0xFF81D4FA), emoji: '😌'),
    Mood(name: 'Neutral', icon: Icons.sentiment_neutral, color: Color(0xFFE0E0E0), emoji: '😐'),
    Mood(name: 'Sad', icon: Icons.sentiment_dissatisfied, color: Color(0xFF90CAF9), emoji: '😔'),
    Mood(name: 'Angry', icon: Icons.sentiment_very_dissatisfied, color: Color(0xFFEF9A9A), emoji: '😠'),
    Mood(name: 'Energetic', icon: Icons.flash_on, color: Color(0xFFFFAB91), emoji: '⚡'),
    Mood(name: 'Tired', icon: Icons.bedtime, color: Color(0xFFBCAAA4), emoji: '😴'),
  ];

  // Helper to get start of week (Monday)
  DateTime _startOfWeek(DateTime date) {
    DateTime start = DateTime(date.year, date.month, date.day);
    int weekDay = start.weekday;
    int daysToSubtract = weekDay - 1; // Monday = 1
    return start.subtract(Duration(days: daysToSubtract));
  }

  List<DateTime> _getWeekDates(DateTime date) {
    DateTime start = _startOfWeek(date);
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  Mood? _getMoodForDate(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return _moodEntries[normalized]?.mood;
  }

  void _saveMood(Mood mood) {
    setState(() {
      final normalized = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      _moodEntries[normalized] = MoodEntry(
        date: normalized,
        mood: mood,
        note: _note.trim().isEmpty ? '' : _note,
      );
      _note = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Mood saved: ${mood.emoji} ${mood.name}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: mood.color,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      backgroundColor: Colors.white,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How are you feeling?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('EEEE, MMMM d').format(_selectedDate),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Add a note (optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (value) => _note = value,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _moods.map((mood) {
                return GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _saveMood(mood);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: mood.color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: mood.color, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(mood.emoji, style: const TextStyle(fontSize: 24)),
                        const SizedBox(width: 8),
                        Text(
                          mood.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: mood.color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Map<Mood, int> _getWeeklyMoodCounts() {
    final weekDates = _getWeekDates(_selectedDate);
    final counts = <Mood, int>{};
    for (var mood in _moods) {
      counts[mood] = 0;
    }
    for (var date in weekDates) {
      final entry = _moodEntries[DateTime(date.year, date.month, date.day)];
      if (entry != null) {
        counts[entry.mood] = (counts[entry.mood] ?? 0) + 1;
      }
    }
    return counts;
  }

  Mood? _getMostProminentMood() {
    final counts = _getWeeklyMoodCounts();
    if (counts.values.every((count) => count == 0)) return null;
    return counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  String _getMotivationalMessage(Mood? mood) {
    if (mood == null) return "Log your moods to see insights! ✨";
    switch (mood.name) {
      case 'Amazing': return "You're on fire! Keep shining! 🔥";
      case 'Happy': return "Joy looks good on you! 🌟";
      case 'Calm': return "Inner peace is powerful. 🧘";
      case 'Neutral': return "Every day is a fresh start. 🌱";
      case 'Sad': return "This too shall pass. You're strong. 💪";
      case 'Angry': return "Take a deep breath. You've got this. 🌬️";
      case 'Energetic': return "Channel that energy! 🚀";
      case 'Tired': return "Rest is productive too. 🛌";
      default: return "Keep glowing! ✨";
    }
  }

  Color _getBackgroundColorForMood(Mood? mood) {
    if (mood == null) return const Color(0xFFF8F9FF);
    return mood.color.withOpacity(0.15);
  }

  @override
  Widget build(BuildContext context) {
    final mostProminent = _getMostProminentMood();
    final bgColor = _getBackgroundColorForMood(mostProminent);
    final weekDates = _getWeekDates(_selectedDate);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar with week navigation
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'MoodMuse',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    fontSize: 22,
                  ),
                ),
                centerTitle: true,
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.8),
                        const Color(0xFF3F3D9E).withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2026),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
              ],
            ),

            // Week selector
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.subtract(const Duration(days: 7));
                        });
                      },
                      icon: const Icon(Icons.chevron_left, size: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                    Text(
                      'Week of ${DateFormat('MMM d').format(_startOfWeek(_selectedDate))}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedDate = _selectedDate.add(const Duration(days: 7));
                        });
                      },
                      icon: const Icon(Icons.chevron_right, size: 32),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Weekly mood grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.9,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final date = weekDates[index];
                    final mood = _getMoodForDate(date);
                    final isToday = DateUtils.isSameDay(date, DateTime.now());
                    final hasMood = mood != null;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedDate = date);
                        _showMoodPicker();
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: hasMood ? mood!.color.withOpacity(0.3) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isToday ? const Color(0xFF6C63FF) : Colors.transparent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              DateFormat('E').format(date),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isToday ? const Color(0xFF6C63FF) : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('d').format(date),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isToday ? const Color(0xFF6C63FF) : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              hasMood ? mood!.emoji : '➕',
                              style: TextStyle(fontSize: 28),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: 7,
                ),
              ),
            ),

            // Selected date mood display
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getMoodForDate(_selectedDate)?.emoji ?? '📝',
                        style: const TextStyle(fontSize: 40),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMMM d').format(_selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getMoodForDate(_selectedDate)?.name ?? 'No mood logged yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: _getMoodForDate(_selectedDate)?.color ?? Colors.grey,
                            ),
                          ),
                          if (_moodEntries[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)]?.note.isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                '📌 ${_moodEntries[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)]!.note}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _showMoodPicker,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Log Mood'),
                    ),
                  ],
                ),
              ),
            ),

            // Analysis Section
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF6C63FF).withOpacity(0.9),
                      const Color(0xFF3F3D9E).withOpacity(0.9),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.insights, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Weekly Analysis',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Most prominent mood card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            '🌟 MOST PROMINENT MOOD 🌟',
                            style: TextStyle(
                              fontSize: 12,
                              letterSpacing: 1,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (mostProminent != null)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  mostProminent.emoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  mostProminent.name,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          else
                            const Text(
                              'No moods logged this week',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white70,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Text(
                            _getMotivationalMessage(mostProminent),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Mood distribution
                    const Text(
                      'Mood Distribution',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._getWeeklyMoodCounts().entries
                        .where((e) => e.value > 0)
                        .map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(entry.key.emoji, style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(entry.key.name, style: const TextStyle(color: Colors.white)),
                              const Spacer(),
                              Text('${entry.value} day${entry.value > 1 ? 's' : ''}',
                                  style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: entry.value / 7,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(entry.key.color),
                            borderRadius: BorderRadius.circular(8),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ))
                        .toList(),
                    if (_getWeeklyMoodCounts().values.every((c) => c == 0))
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: Text(
                            'Tap any day to start tracking your moods!',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 30)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showMoodPicker,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 4,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Log Today\'s Mood', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
