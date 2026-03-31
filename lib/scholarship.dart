import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ScholarshipApp());
}

class ScholarshipApp extends StatelessWidget {
  const ScholarshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scholarship App',
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
  int _currentPage = 0;
  final List<Widget> _pages = [
    const ChecklistScreen(),
    const DocumentsScreen(),
  ];

  void _showBanner(String message) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(message),
        backgroundColor: Colors.blue,
        contentTextStyle: const TextStyle(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0 && _currentPage > 0) {
            setState(() => _currentPage--);
            _showBanner('Previous page');
          } else if (details.primaryVelocity! < 0 && _currentPage < _pages.length - 1) {
            setState(() => _currentPage++);
            _showBanner('Next page');
          }
        },
        child: _pages[_currentPage],
      ),
    );
  }
}

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final Map<String, bool> _items = {
    'Transcript': false,
    'Recommendation': false,
    'Statement': false,
    'ID Proof': false,
  };

  void _toggleItem(String key) {
    setState(() => _items[key] = !_items[key]!);
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text('${_items[key]! ? "✓ Completed" : "✗ Unchecked"}: $key'),
        backgroundColor: _items[key]! ? Colors.green : Colors.orange,
        contentTextStyle: const TextStyle(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Application Checklist', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ..._items.entries.map((entry) => CheckboxListTile(
              title: Text(entry.key),
              value: entry.value,
              onChanged: (_) => _toggleItem(entry.key),
              activeColor: Colors.blue,
            )),
          ],
        ),
      ),
    );
  }
}

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final Map<String, File?> _docs = {
    'Transcript': null,
    'Recommendation': null,
    'Statement': null,
    'ID Proof': null,
  };
  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadDoc(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _docs[type] = File(image.path));
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text('$type uploaded successfully'),
          backgroundColor: Colors.green,
          contentTextStyle: const TextStyle(color: Colors.white),
          actions: [
            TextButton(
              onPressed: () => ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Document Upload', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ..._docs.entries.map((entry) => ListTile(
              leading: Icon(entry.value != null ? Icons.check_circle : Icons.upload_file, color: entry.value != null ? Colors.green : Colors.grey),
              title: Text(entry.key),
              trailing: IconButton(
                icon: const Icon(Icons.cloud_upload),
                onPressed: () => _uploadDoc(entry.key),
              ),
              onTap: () => _uploadDoc(entry.key),
            )),
          ],
        ),
      ),
    );
  }
}
