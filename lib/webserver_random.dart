import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const WebServerApp());
}

class WebServerApp extends StatelessWidget {
  const WebServerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Web Server App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> _data = {};
  bool _loading = false;
  String _error = '';

  // Free public APIs (no API key required)
  final List<Map<String, String>> _apis = [
    {'name': 'Random User', 'url': 'https://randomuser.me/api/'},
    {'name': 'Random Quote', 'url': 'https://zenquotes.io/api/random'},
    {'name': 'Random Dog', 'url': 'https://dog.ceo/api/breeds/image/random'},
    {'name': 'Random Cat', 'url': 'https://api.thecatapi.com/v1/images/search?limit=1'},
    {'name': 'Random Joke', 'url': 'https://v2.jokeapi.dev/joke/Any?type=single'},
  ];

  Future<void> _fetchData(String url, String type) async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        setState(() {
          _data = {'type': type, 'data': jsonData};
          _loading = false;
        });
      } else {
        setState(() {
          _error = 'Error: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load data';
        _loading = false;
      });
    }
  }

  Widget _buildDisplay() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching data...'),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(_error, style: const TextStyle(color: Colors.red)),
          ],
        ),
      );
    }

    if (_data.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.api, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text('Select an API to fetch data', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Response:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                const SizedBox(height: 8),
                ..._formatData(_data['data'], _data['type']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _formatData(dynamic data, String type) {
    List<Widget> widgets = [];

    if (type == 'Random User') {
      final user = data['results'][0];
      widgets.add(Text('Name: ${user['name']['first']} ${user['name']['last']}'));
      widgets.add(const SizedBox(height: 8));
      widgets.add(Text('Email: ${user['email']}'));
      widgets.add(const SizedBox(height: 8));
      widgets.add(Text('Country: ${user['location']['country']}'));
      widgets.add(const SizedBox(height: 8));
      widgets.add(Text('Phone: ${user['phone']}'));
    }
    else if (type == 'Random Quote') {
      widgets.add(
        Text(
          '"${data[0]['q']}"',
          style: const TextStyle(fontStyle: FontStyle.italic),
        ),
      );
      widgets.add(const SizedBox(height: 8));
      widgets.add(
        Text(
          '- ${data[0]['a']}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    }
    else if (type == 'Random Dog') {
      widgets.add(Image.network(data['message'], height: 200));
      widgets.add(const SizedBox(height: 8));
      widgets.add(const Text('🐕 Woof! Here\'s a random dog!'));
    }
    else if (type == 'Random Cat') {
      widgets.add(Image.network(data[0]['url'], height: 200));
      widgets.add(const SizedBox(height: 8));
      widgets.add(const Text('🐱 Meow! Here\'s a random cat!'));
    }
    else if (type == 'Random Joke') {
      widgets.add(Text(data['joke'], style: const TextStyle(fontSize: 16)));
    }
    else {
      widgets.add(Text(json.encode(data)));
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Server App'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // API Buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _apis.map((api) {
                return ElevatedButton(
                  onPressed: () => _fetchData(api['url']!, api['name']!),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _data['type'] == api['name'] ? Colors.blue : null,
                  ),
                  child: Text(api['name']!),
                );
              }).toList(),
            ),
          ),
          const Divider(),
          // Display Area
          Expanded(child: _buildDisplay()),
        ],
      ),
    );
  }
}
