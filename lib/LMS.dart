import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const LibraryManagementSystem());
}

class LibraryManagementSystem extends StatelessWidget {
  const LibraryManagementSystem({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeScreen(),
    );
  }
}

class Book {
  String id;
  String title;
  String author;
  bool isAvailable;
  String? rentedBy;
  DateTime? rentDate;
  
  Book({
    required this.id,
    required this.title,
    required this.author,
    this.isAvailable = true,
    this.rentedBy,
    this.rentDate,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isAvailable': isAvailable,
      'rentedBy': rentedBy,
      'rentDate': rentDate?.toIso8601String(),
    };
  }
  
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      isAvailable: map['isAvailable'],
      rentedBy: map['rentedBy'],
      rentDate: map['rentDate'] != null ? DateTime.parse(map['rentDate']) : null,
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<Book> _books = [];
  
  final List<Widget> _screens = [];
  
  @override
  void initState() {
    super.initState();
    // Add sample books
    _books.addAll([
      Book(id: 'B001', title: 'The Great Gatsby', author: 'F. Scott Fitzgerald'),
      Book(id: 'B002', title: 'To Kill a Mockingbird', author: 'Harper Lee'),
      Book(id: 'B003', title: '1984', author: 'George Orwell'),
      Book(id: 'B004', title: 'Pride and Prejudice', author: 'Jane Austen'),
    ]);
    
    _screens.addAll([
      AvailableBooksScreen(books: _books),
      RentBookScreen(books: _books, onRent: _refreshBooks),
      ReturnBookScreen(books: _books, onReturn: _refreshBooks),
      AddBookScreen(books: _books, onAdd: _refreshBooks),
    ]);
  }
  
  void _refreshBooks() {
    setState(() {});
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Library Management System'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.menu_book), label: 'Available'),
          NavigationDestination(icon: Icon(Icons.arrow_downward), label: 'Rent'),
          NavigationDestination(icon: Icon(Icons.arrow_upward), label: 'Return'),
          NavigationDestination(icon: Icon(Icons.add), label: 'Add Book'),
        ],
      ),
    );
  }
}

class AvailableBooksScreen extends StatelessWidget {
  final List<Book> books;
  
  const AvailableBooksScreen({super.key, required this.books});
  
  @override
  Widget build(BuildContext context) {
    final availableBooks = books.where((book) => book.isAvailable).toList();
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Books',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${availableBooks.length} / ${books.length}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: availableBooks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.book, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No books available', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: availableBooks.length,
                      itemBuilder: (context, index) {
                        final book = availableBooks[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(book.id),
                            ),
                            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(book.author),
                            trailing: const Chip(
                              label: Text('Available'),
                              backgroundColor: Colors.green,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class RentBookScreen extends StatefulWidget {
  final List<Book> books;
  final VoidCallback onRent;
  
  const RentBookScreen({super.key, required this.books, required this.onRent});
  
  @override
  State<RentBookScreen> createState() => _RentBookScreenState();
}

class _RentBookScreenState extends State<RentBookScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBookId;
  String _renterName = '';
  DateTime _rentDate = DateTime.now();
  
  @override
  Widget build(BuildContext context) {
    final availableBooks = widget.books.where((book) => book.isAvailable).toList();
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_downward, size: 64, color: Colors.indigo),
              const SizedBox(height: 16),
              const Text(
                'Rent a Book',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Book',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book),
                ),
                value: _selectedBookId,
                items: availableBooks.map((book) {
                  return DropdownMenuItem(
                    value: book.id,
                    child: Text('${book.id} - ${book.title}'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBookId = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a book' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Renter Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                onChanged: (value) => _renterName = value,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter renter name' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Rent Date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_rentDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _rentDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _rentDate = date;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final book = widget.books.firstWhere((b) => b.id == _selectedBookId);
                    book.isAvailable = false;
                    book.rentedBy = _renterName;
                    book.rentDate = _rentDate;
                    widget.onRent();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${book.title} rented to $_renterName')),
                    );
                    _formKey.currentState!.reset();
                    setState(() {
                      _selectedBookId = null;
                      _renterName = '';
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Rent Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReturnBookScreen extends StatefulWidget {
  final List<Book> books;
  final VoidCallback onReturn;
  
  const ReturnBookScreen({super.key, required this.books, required this.onReturn});
  
  @override
  State<ReturnBookScreen> createState() => _ReturnBookScreenState();
}

class _ReturnBookScreenState extends State<ReturnBookScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBookId;
  DateTime _returnDate = DateTime.now();
  double _fine = 0;
  
  void _calculateFine() {
    if (_selectedBookId != null) {
      final book = widget.books.firstWhere((b) => b.id == _selectedBookId);
      if (book.rentDate != null) {
        final days = _returnDate.difference(book.rentDate!).inDays;
        if (days > 14) {
          _fine = (days - 14) * 5.0; // $5 per day after 14 days
        } else {
          _fine = 0;
        }
        setState(() {});
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final rentedBooks = widget.books.where((book) => !book.isAvailable).toList();
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_upward, size: 64, color: Colors.orange),
              const SizedBox(height: 16),
              const Text(
                'Return a Book',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Book to Return',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.menu_book),
                ),
                value: _selectedBookId,
                items: rentedBooks.map((book) {
                  return DropdownMenuItem(
                    value: book.id,
                    child: Text('${book.id} - ${book.title} (Rented by: ${book.rentedBy})'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBookId = value;
                    _fine = 0;
                  });
                  _calculateFine();
                },
                validator: (value) => value == null ? 'Please select a book' : null,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Return Date'),
                subtitle: Text(DateFormat('dd MMM yyyy').format(_returnDate)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _returnDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() {
                        _returnDate = date;
                      });
                      _calculateFine();
                    }
                  },
                ),
              ),
              if (_fine > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Late Return Fine: \$${_fine.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final book = widget.books.firstWhere((b) => b.id == _selectedBookId);
                    final days = _returnDate.difference(book.rentDate!).inDays;
                    
                    String message = '${book.title} returned successfully';
                    if (days > 14) {
                      message += '. Late fine: \$${_fine.toStringAsFixed(2)}';
                    }
                    
                    book.isAvailable = true;
                    book.rentedBy = null;
                    book.rentDate = null;
                    widget.onReturn();
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(message)),
                    );
                    
                    _formKey.currentState!.reset();
                    setState(() {
                      _selectedBookId = null;
                      _fine = 0;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Return Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AddBookScreen extends StatefulWidget {
  final List<Book> books;
  final VoidCallback onAdd;
  
  const AddBookScreen({super.key, required this.books, required this.onAdd});
  
  @override
  State<AddBookScreen> createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  
  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _authorController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 64, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Add New Book',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Book ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Please enter book ID';
                  if (widget.books.any((b) => b.id == value)) return 'Book ID already exists';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Book Title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter book title' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(
                  labelText: 'Author Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter author name' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final newBook = Book(
                      id: _idController.text,
                      title: _titleController.text,
                      author: _authorController.text,
                    );
                    widget.books.add(newBook);
                    widget.onAdd();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Book added successfully')),
                    );
                    _formKey.currentState!.reset();
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: Colors.green,
                ),
                child: const Text('Add Book'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
