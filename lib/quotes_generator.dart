import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// http: ^0.13.6

void main() {
  runApp(const QuoteApp());
}

class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Quotes App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const QuoteScreen(),
    );
  }
}

class QuoteScreen extends StatefulWidget {
  const QuoteScreen({super.key});

  @override
  State<QuoteScreen> createState() => _QuoteScreenState();
}

class _QuoteScreenState extends State<QuoteScreen> {
  String quote = "Loading...";
  String author = "";

  @override
  void initState() {
    super.initState();
    fetchQuote();
  }

  Future<void> fetchQuote() async {
    try {
      final response = await http.get(
        Uri.parse('https://dummyjson.com/quotes/random'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          quote = data['quote'] ?? "No quote found";
          author = data['author'] ?? "Unknown";
        });
      } else {
        setState(() {
          quote = "Failed to load quote";
          author = "";
        });
      }
    } catch (e) {
      setState(() {
        quote = "Error occurred";
        author = "";
      });
    }
  }

  void onSwipe() {
    fetchQuote();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quotes App"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (_) => onSwipe(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.format_quote,
                        size: 40, color: Colors.deepPurple),
                    const SizedBox(height: 20),
                    Text(
                      quote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "- $author",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Button (extra UX)
                    ElevatedButton(
                      onPressed: fetchQuote,
                      child: const Text("New Quote"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
