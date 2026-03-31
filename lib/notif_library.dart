import 'package:flutter/material.dart';

void main() {
  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const LibraryScreen(),
    );
  }
}

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final List<Map<String, dynamic>> _books = [
    {'title': 'The Great Gatsby', 'author': 'F. Scott Fitzgerald', 'available': true},
    {'title': 'To Kill a Mockingbird', 'author': 'Harper Lee', 'available': true},
    {'title': '1984', 'author': 'George Orwell', 'available': false},
    {'title': 'Pride and Prejudice', 'author': 'Jane Austen', 'available': true},
    {'title': 'The Catcher in the Rye', 'author': 'J.D. Salinger', 'available': false},
  ];

  void _showBanner(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.warning,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green : Colors.orange,
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    
    // Auto dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      }
    });
  }

  void _borrowBook(int index) {
    final book = _books[index];
    if (book['available']) {
      setState(() {
        _books[index]['available'] = false;
      });
      _showBanner('📚 "${book['title']}" borrowed successfully! Due date: 30 days');
    } else {
      _showBanner('⚠️ "${book['title']}" is currently not available', isSuccess: false);
    }
  }

  void _returnBook(int index) {
    final book = _books[index];
    if (!book['available']) {
      setState(() {
        _books[index]['available'] = true;
      });
      _showBanner('✅ "${book['title']}" returned successfully! Thank you');
    } else {
      _showBanner('ℹ️ "${book['title']}" is already in library', isSuccess: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Management'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              _showBanner('📢 Library closes at 8 PM today!');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
              ),
            ),
            child: const Column(
              children: [
                Icon(Icons.library_books, size: 40, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Welcome to Digital Library',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Borrow and return books easily',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          
          // Book List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: book['available'] ? Colors.green : Colors.red,
                      child: Icon(
                        book['available'] ? Icons.check : Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      book['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(book['author']),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (book['available'])
                          ElevatedButton.icon(
                            onPressed: () => _borrowBook(index),
                            icon: const Icon(Icons.arrow_downward, size: 16),
                            label: const Text('Borrow'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        if (!book['available'])
                          ElevatedButton.icon(
                            onPressed: () => _returnBook(index),
                            icon: const Icon(Icons.arrow_upward, size: 16),
                            label: const Text('Return'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Stats Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat(
                  Icons.book,
                  'Total Books',
                  _books.length.toString(),
                ),
                _buildStat(
                  Icons.check_circle,
                  'Available',
                  _books.where((b) => b['available']).length.toString(),
                ),
                _buildStat(
                  Icons.people,
                  'Borrowed',
                  _books.where((b) => !b['available']).length.toString(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showBanner('📖 New arrivals this week! Check out the latest books');
        },
        child: const Icon(Icons.notifications_active),
      ),
    );
  }

  Widget _buildStat(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}
