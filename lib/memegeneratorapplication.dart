import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meme Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const MemeGeneratorHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MemeGeneratorHome extends StatefulWidget {
  const MemeGeneratorHome({super.key});

  @override
  State<MemeGeneratorHome> createState() => _MemeGeneratorHomeState();
}

class _MemeGeneratorHomeState extends State<MemeGeneratorHome> {
  List<CreatedMeme> createdMemes = [];
  int currentMemeIndex = 0;
  bool showGeneratedButton = false;

  @override
  void initState() {
    super.initState();
  }

  void addCreatedMeme(CreatedMeme meme) {
    setState(() {
      if (createdMemes.length >= 5) {
        createdMemes.removeAt(0);
      }
      createdMemes.add(meme);
    });
  }

  void deleteMeme(int index) {
    setState(() {
      createdMemes.removeAt(index);
      if (createdMemes.isEmpty) {
        currentMemeIndex = 0;
      } else if (currentMemeIndex >= createdMemes.length) {
        currentMemeIndex = createdMemes.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meme Generator'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: Column(
        children: [
          // Main display area for created memes
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.grey[100]!, Colors.grey[200]!],
                ),
              ),
              child: createdMemes.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.photo_library,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No memes created yet',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tap the + button to create your first meme',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
                  : GestureDetector(
                onTap: () {
                  setState(() {
                    showGeneratedButton = !showGeneratedButton;
                  });
                },
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity != null) {
                    if (details.primaryVelocity! > 0 && currentMemeIndex > 0) {
                      setState(() {
                        currentMemeIndex--;
                        showGeneratedButton = false;
                      });
                    } else if (details.primaryVelocity! < 0 && currentMemeIndex < createdMemes.length - 1) {
                      setState(() {
                        currentMemeIndex++;
                        showGeneratedButton = false;
                      });
                    }
                  }
                },
                child: Stack(
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Stack(
                              children: [
                                // Use Image.network directly instead of base64Decode
                                Image.network(
                                  createdMemes[currentMemeIndex].imageUrl,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: Icon(Icons.broken_image, size: 50),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        value: loadingProgress.expectedTotalBytes != null
                                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                            : null,
                                      ),
                                    );
                                  },
                                ),
                                if (createdMemes[currentMemeIndex].topText.isNotEmpty)
                                  Positioned(
                                    top: 20,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.7),
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        createdMemes[currentMemeIndex].topText,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 3,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                if (createdMemes[currentMemeIndex].bottomText.isNotEmpty)
                                  Positioned(
                                    bottom: 20,
                                    left: 0,
                                    right: 0,
                                    child: Container(
                                      color: Colors.black.withOpacity(0.7),
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        createdMemes[currentMemeIndex].bottomText,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              blurRadius: 3,
                                              color: Colors.black,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Meme'),
                                          content: const Text('Are you sure you want to delete this meme?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                deleteMeme(currentMemeIndex);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showGeneratedButton)
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                showGeneratedButton = false;
                              });
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MemeSelector(
                                    onMemeCreated: addCreatedMeme,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add_photo_alternate),
                            label: const Text('Generate New Meme'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (createdMemes.length > 1)
                      Positioned(
                        bottom: 20,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${currentMemeIndex + 1}/${createdMemes.length}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Thumbnail strip of created memes
          if (createdMemes.isNotEmpty)
            Container(
              height: 100,
              color: Colors.grey[100],
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8),
                itemCount: createdMemes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        currentMemeIndex = index;
                        showGeneratedButton = false;
                      });
                    },
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: currentMemeIndex == index ? Colors.blue : Colors.grey,
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.network(
                              createdMemes[index].imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                );
                              },
                            ),
                            if (createdMemes[index].topText.isNotEmpty)
                              Positioned(
                                top: 2,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.black.withOpacity(0.6),
                                  padding: const EdgeInsets.all(2),
                                  child: Text(
                                    createdMemes[index].topText,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MemeSelector(
                onMemeCreated: addCreatedMeme,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: 'Create New Meme',
      ),
    );
  }
}

class MemeSelector extends StatefulWidget {
  final Function(CreatedMeme) onMemeCreated;

  const MemeSelector({super.key, required this.onMemeCreated});

  @override
  State<MemeSelector> createState() => _MemeSelectorState();
}

class _MemeSelectorState extends State<MemeSelector> {
  List<MemeTemplate> memeTemplates = [];
  bool isLoading = true;
  String errorMessage = '';
  int currentTemplateIndex = 0;
  String topText = '';
  String bottomText = '';
  bool showTextInputs = false;

  @override
  void initState() {
    super.initState();
    fetchMemeTemplates();
  }

  Future<void> fetchMemeTemplates() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.imgflip.com/get_memes'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          final List memesData = data['data']['memes'];
          setState(() {
            memeTemplates = memesData
                .map((meme) => MemeTemplate.fromJson(meme))
                .take(50)
                .toList();
            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = 'Failed to load memes';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to connect to API';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error: $e';
        isLoading = false;
      });
    }
  }

  void saveMeme() {
    if (topText.isEmpty && bottomText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text for your meme')),
      );
      return;
    }

    final template = memeTemplates[currentTemplateIndex];

    final createdMeme = CreatedMeme(
      imageUrl: template.url,
      topText: topText,
      bottomText: bottomText,
      createdAt: DateTime.now(),
    );

    widget.onMemeCreated(createdMeme);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Meme saved successfully!')),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Meme Template'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (!isLoading && errorMessage.isEmpty)
            IconButton(
              icon: const Icon(Icons.check_circle),
              onPressed: saveMeme,
              tooltip: 'Save Meme',
            ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading meme templates...'),
          ],
        ),
      )
          : errorMessage.isNotEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: fetchMemeTemplates,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onHorizontalDragEnd: (details) {
                if (details.primaryVelocity != null) {
                  if (details.primaryVelocity! > 0 && currentTemplateIndex > 0) {
                    setState(() {
                      currentTemplateIndex--;
                    });
                  } else if (details.primaryVelocity! < 0 && currentTemplateIndex < memeTemplates.length - 1) {
                    setState(() {
                      currentTemplateIndex++;
                    });
                  }
                }
              },
              onTap: () {
                setState(() {
                  showTextInputs = !showTextInputs;
                });
              },
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.network(
                        memeTemplates[currentTemplateIndex].url,
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded / progress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 50),
                            ),
                          );
                        },
                      ),
                      if (showTextInputs) ...[
                        Positioned(
                          top: 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.8),
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                              decoration: const InputDecoration(
                                hintText: 'Enter top text',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  topText = value;
                                });
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 0,
                          right: 0,
                          child: Container(
                            color: Colors.black.withOpacity(0.8),
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              style: const TextStyle(color: Colors.white, fontSize: 18),
                              decoration: const InputDecoration(
                                hintText: 'Enter bottom text',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  bottomText = value;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                      Positioned(
                        bottom: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Tap to ${showTextInputs ? 'hide' : 'add'} text',
                            style: const TextStyle(color: Colors.white, fontSize: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            height: 100,
            color: Colors.grey[100],
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(8),
              itemCount: memeTemplates.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      currentTemplateIndex = index;
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: currentTemplateIndex == index ? Colors.blue : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.network(
                        memeTemplates[index].url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: saveMeme,
              icon: const Icon(Icons.save),
              label: const Text('SAVE MEME'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MemeTemplate {
  final String id;
  final String name;
  final String url;

  MemeTemplate({
    required this.id,
    required this.name,
    required this.url,
  });

  factory MemeTemplate.fromJson(Map<String, dynamic> json) {
    return MemeTemplate(
      id: json['id'].toString(),
      name: json['name'],
      url: json['url'],
    );
  }
}

class CreatedMeme {
  final String imageUrl;  // Changed from imageData to imageUrl
  final String topText;
  final String bottomText;
  final DateTime createdAt;

  CreatedMeme({
    required this.imageUrl,
    required this.topText,
    required this.bottomText,
    required this.createdAt,
  });
}
