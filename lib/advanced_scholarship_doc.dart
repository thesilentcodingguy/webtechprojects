import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ScholarshipApp());
}

class ScholarshipApp extends StatelessWidget {
  const ScholarshipApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Scholarship Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'SF Pro Text',
      ),
      home: const ScholarshipHomeScreen(),
    );
  }
}

// Main Home Screen with Gesture Detection
class ScholarshipHomeScreen extends StatefulWidget {
  const ScholarshipHomeScreen({super.key});

  @override
  State<ScholarshipHomeScreen> createState() => _ScholarshipHomeScreenState();
}

class _ScholarshipHomeScreenState extends State<ScholarshipHomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // Gesture state for swipe detection
  double _dragStartX = 0;

  void _showNotification(String message) {
    _scaffoldMessengerKey.currentState?.showMaterialBanner(
      MaterialBanner(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        contentTextStyle: const TextStyle(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              _scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
            },
            child: const Text(
              'DISMISS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    // Auto-dismiss after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      _scaffoldMessengerKey.currentState?.hideCurrentMaterialBanner();
    });
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    const double swipeThreshold = 50;
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! > swipeThreshold) {
        // Swipe right - go to checklist
        setState(() {
          _selectedIndex = 1;
        });
        _showNotification('📋 Swiped to Checklist');
      } else if (details.primaryVelocity! < -swipeThreshold) {
        // Swipe left - go to documents
        setState(() {
          _selectedIndex = 2;
        });
        _showNotification('📎 Swiped to Documents');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      body: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            DashboardScreen(),
            ChecklistScreen(),
            DocumentsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
          String message = index == 0
              ? '🏠 Dashboard'
              : index == 1
                  ? '📋 Checklist'
                  : '📎 Documents';
          _showNotification('Navigated to $message');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.checklist_outlined), label: 'Checklist'),
          NavigationDestination(icon: Icon(Icons.upload_file_outlined), label: 'Documents'),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.grey.shade100,
          ],
        ),
      ),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    size: 80,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Merit Excellence Scholarship',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Academic Year 2024-2025',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.attach_money, color: Color(0xFF2E7D32)),
                            SizedBox(width: 12),
                            Text(
                              'Award Amount',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '\$25,000',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E7D32),
                          ),
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(Icons.calendar_today, 'Deadline', 'May 30, 2025'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.people, 'Available Slots', '50'),
                        const SizedBox(height: 12),
                        _buildInfoRow(Icons.star, 'Minimum GPA', '3.5'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  '👆 Swipe left/right to navigate\n📋 Checklist → 📎 Documents',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Checklist Screen with Gesture Detection
class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final Map<String, bool> _checklist = {
    'Academic Transcripts': false,
    'Recommendation Letters': false,
    'Statement of Purpose': false,
    'Proof of Enrollment': false,
    'Valid ID / Passport': false,
    'Financial Statement': false,
  };

  double _completionPercentage = 0;

  @override
  void initState() {
    super.initState();
    _updateCompletion();
  }

  void _updateCompletion() {
    int completed = _checklist.values.where((v) => v == true).length;
    setState(() {
      _completionPercentage = completed / _checklist.length;
    });
  }

  void _toggleCheckbox(String key) {
    setState(() {
      _checklist[key] = !_checklist[key]!;
      _updateCompletion();
    });

    // Show notification when item is checked
    if (_checklist[key]!) {
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            '✓ Completed: $key',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          backgroundColor: const Color(0xFF2E7D32),
          contentTextStyle: const TextStyle(color: Colors.white),
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
      Future.delayed(const Duration(seconds: 2), () {
        ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Application Checklist',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Complete all items to be eligible',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                // Progress Indicator
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Progress',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${(_completionPercentage * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _completionPercentage,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF2E7D32),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Checklist Items
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _checklist.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (context, index) {
                      String key = _checklist.keys.elementAt(index);
                      bool value = _checklist[key]!;
                      return CheckboxListTile(
                        title: Text(
                          key,
                          style: TextStyle(
                            fontSize: 16,
                            decoration: value ? TextDecoration.lineThrough : null,
                            color: value ? Colors.grey : Colors.black87,
                          ),
                        ),
                        value: value,
                        onChanged: (_) => _toggleCheckbox(key),
                        activeColor: const Color(0xFF2E7D32),
                        secondary: Icon(
                          value ? Icons.check_circle : Icons.circle_outlined,
                          color: value ? const Color(0xFF2E7D32) : Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onDoubleTap: () {
                    ScaffoldMessenger.of(context).showMaterialBanner(
                      MaterialBanner(
                        content: const Text(
                          '📌 Tip: Upload documents after completing checklist',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: Colors.blueGrey,
                        contentTextStyle: const TextStyle(color: Colors.white),
                        actions: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentMaterialBanner();
                            },
                            child: const Text(
                              'GOT IT',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Double-tap for tip',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Documents Screen with Upload Functionality
class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final Map<String, File?> _uploadedFiles = {
    'Transcript': null,
    'Recommendation Letter': null,
    'Statement of Purpose': null,
    'ID Proof': null,
  };

  final ImagePicker _picker = ImagePicker();

  Future<void> _uploadDocument(String documentType) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await _picker.pickImage(
                  source: ImageSource.camera,
                );
                if (photo != null) {
                  setState(() {
                    _uploadedFiles[documentType] = File(photo.path);
                  });
                  _showUploadNotification(documentType);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder),
              title: const Text('Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  setState(() {
                    _uploadedFiles[documentType] = File(image.path);
                  });
                  _showUploadNotification(documentType);
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showUploadNotification(String documentType) {
    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        content: Text(
          '✓ $documentType uploaded successfully',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        backgroundColor: const Color(0xFF2E7D32),
        contentTextStyle: const TextStyle(color: Colors.white),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: const Text(
              'DISMISS',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
    });
  }

  int get _uploadedCount {
    return _uploadedFiles.values.where((file) => file != null).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Document Upload',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1B5E20),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload required documents',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),
                // Upload Progress
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Documents Uploaded',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$_uploadedCount/${_uploadedFiles.length}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: _uploadedCount / _uploadedFiles.length,
                          backgroundColor: Colors.grey.shade200,
                          color: const Color(0xFF2E7D32),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Document List
                ..._uploadedFiles.entries.map((entry) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: entry.value != null
                              ? const Color(0xFF2E7D32).withOpacity(0.1)
                              : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          entry.value != null
                              ? Icons.check_circle
                              : Icons.upload_file,
                          color: entry.value != null
                              ? const Color(0xFF2E7D32)
                              : Colors.grey,
                        ),
                      ),
                      title: Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: entry.value != null
                          ? Text(
                              'Uploaded • ${entry.value!.path.split('/').last.substring(0, 12)}...',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            )
                          : const Text('Not uploaded'),
                      trailing: IconButton(
                        icon: Icon(
                          entry.value != null ? Icons.refresh : Icons.add,
                          color: const Color(0xFF2E7D32),
                        ),
                        onPressed: () => _uploadDocument(entry.key),
                      ),
                      onTap: () => _uploadDocument(entry.key),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                GestureDetector(
                  onLongPress: () {
                    ScaffoldMessenger.of(context).showMaterialBanner(
                      MaterialBanner(
                        content: const Text(
                          '📎 Long press to see upload instructions',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        backgroundColor: Colors.blueGrey,
                        contentTextStyle: const TextStyle(color: Colors.white),
                        actions: [
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context)
                                  .hideCurrentMaterialBanner();
                            },
                            child: const Text(
                              'OK',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    );
                    Future.delayed(const Duration(seconds: 2), () {
                      ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, size: 16, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Long-press for help',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
