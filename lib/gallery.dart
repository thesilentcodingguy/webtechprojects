import 'package:flutter/material.dart';

void main() {
  runApp(const GalleryApp());
}

class GalleryApp extends StatelessWidget {
  const GalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GalleryScreen(),
    );
  }
}

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  // List of image URLs (using high-quality, reliable demo images)
  final List<String> _images = [
    'https://picsum.photos/id/1015/800/1200', // Mountain landscape
    'https://picsum.photos/id/104/800/1200',  // Waterfall
    'https://picsum.photos/id/106/800/1200',  // Flower
    'https://picsum.photos/id/107/800/1200',  // Grass
    'https://picsum.photos/id/116/800/1200',  // Lake
  ];

  late final List<String> _imageDetails = [
    'Mountain Landscape\nA serene mountain view with snow-capped peaks and lush green valleys.',
    'Waterfall\nA powerful waterfall cascading down ancient rocks, surrounded by mist.',
    'Red Flower\nA vibrant red flower in full bloom, showcasing nature\'s intricate beauty.',
    'Morning Grass\nDew-covered grass blades glistening in the soft morning sunlight.',
    'Lake Reflection\nA tranquil lake mirroring the sky and surrounding forest.',
  ];

  int _currentIndex = 0;
  bool _isZoomed = false;

  void _nextImage() {
    if (!_isZoomed) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _images.length;
      });
    }
  }

  void _previousImage() {
    if (!_isZoomed) {
      setState(() {
        _currentIndex = (_currentIndex - 1 + _images.length) % _images.length;
      });
    }
  }

  void _toggleZoom() {
    setState(() {
      _isZoomed = !_isZoomed;
    });
  }

  void _showDetailsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Image Details',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info_outline,
              size: 48,
              color: Colors.deepPurple,
            ),
            const SizedBox(height: 16),
            Text(
              _imageDetails[_currentIndex],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: _toggleZoom,
          onDoubleTap: _showDetailsDialog,
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null) {
              if (details.primaryVelocity! > 0) {
                // Swipe right -> previous image
                _previousImage();
              } else if (details.primaryVelocity! < 0) {
                // Swipe left -> next image
                _nextImage();
              }
            }
          },
          child: Container(
            color: Colors.black,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              child: _isZoomed
                  ? InteractiveViewer(
                      key: ValueKey('zoomed_$_currentIndex'),
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Image.network(
                        _images[_currentIndex],
                        fit: BoxFit.contain,
                      ),
                    )
                  : Image.network(
                      key: ValueKey('normal_$_currentIndex'),
                      _images[_currentIndex],
                      fit: BoxFit.contain,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
