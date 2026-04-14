import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppData.loadData();
  runApp(const WasteManagementApp());
}

class WasteManagementApp extends StatelessWidget {
  const WasteManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cooperative Waste Management',
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==================== MODELS ====================

class User {
  final String id;
  final String name;
  final String role;
  final String? zone;
  final String? region;

  User({
    required this.id,
    required this.name,
    required this.role,
    this.zone,
    this.region,
  });
}

class Zone {
  final String id;
  final String name;
  String scheduleDate;
  String status;

  Zone({
    required this.id,
    required this.name,
    required this.scheduleDate,
    this.status = 'Scheduled',
  });
}

class Complaint {
  final String id;
  final String residentId;
  final String residentName;
  final String description;
  final String? imageUrl;
  final String location;
  String status;
  final DateTime date;

  Complaint({
    required this.id,
    required this.residentId,
    required this.residentName,
    required this.description,
    this.imageUrl,
    required this.location,
    required this.status,
    required this.date,
  });
}

class Payment {
  final String id;
  final String residentId;
  final double amount;
  final String status;
  final DateTime date;

  Payment({
    required this.id,
    required this.residentId,
    required this.amount,
    required this.status,
    required this.date,
  });
}

class SpecialDrive {
  final String id;
  final String title;
  final String description;
  final List<String> zones;
  final DateTime date;

  SpecialDrive({
    required this.id,
    required this.title,
    required this.description,
    required this.zones,
    required this.date,
  });
}

// ==================== DATA STORE ====================

class AppData {
  static List<User> users = [
    User(id: '1', name: 'Admin User', role: 'admin'),
    User(id: '2', name: 'Supervisor John', role: 'supervisor', zone: 'Zone A', region: 'North'),
    User(id: '3', name: 'Driver Mike', role: 'driver', zone: 'Zone A', region: 'North'),
    User(id: '4', name: 'Alice Resident', role: 'resident', zone: 'Zone A', region: 'North'),
    User(id: '5', name: 'Bob Resident', role: 'resident', zone: 'Zone B', region: 'South'),
    User(id: '6', name: 'Carol Resident', role: 'resident', zone: 'Zone C', region: 'East'),
  ];

  static List<Zone> zones = [
    Zone(id: '1', name: 'Zone A', scheduleDate: '2024-01-20', status: 'Scheduled'),
    Zone(id: '2', name: 'Zone B', scheduleDate: '2024-01-21', status: 'Scheduled'),
    Zone(id: '3', name: 'Zone C', scheduleDate: '2024-01-22', status: 'Scheduled'),
  ];

  static List<Complaint> complaints = [];
  static List<Payment> payments = [];
  static List<SpecialDrive> specialDrives = [];

  static Map<String, List<String>> zoneResidents = {
    'Zone A': ['Alice Resident'],
    'Zone B': ['Bob Resident'],
    'Zone C': ['Carol Resident'],
  };

  static String? currentUserRole;
  static User? currentUser;
  static List<Complaint> getComplaintsByZone(String? zoneName) {
    return complaints.where((c) {
      final resident = users.firstWhere((u) => u.id == c.residentId);
      return resident.zone == zoneName;
    }).toList();
  }
  static Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    // Save complaints
    List<String> complaintsJson = complaints.map((c) => jsonEncode({
      'id': c.id,
      'residentId': c.residentId,
      'residentName': c.residentName,
      'description': c.description,
      'location': c.location,
      'status': c.status,
      'date': c.date.toIso8601String(),
    })).toList();
    await prefs.setStringList('complaints', complaintsJson);

    // Save payments
    List<String> paymentsJson = payments.map((p) => jsonEncode({
      'id': p.id,
      'residentId': p.residentId,
      'amount': p.amount,
      'status': p.status,
      'date': p.date.toIso8601String(),
    })).toList();
    await prefs.setStringList('payments', paymentsJson);

    // Save special drives
    List<String> drivesJson = specialDrives.map((d) => jsonEncode({
      'id': d.id,
      'title': d.title,
      'description': d.description,
      'zones': d.zones,
      'date': d.date.toIso8601String(),
    })).toList();
    await prefs.setStringList('specialDrives', drivesJson);

    // Save zone statuses
    List<String> zonesJson = zones.map((z) => jsonEncode({
      'id': z.id,
      'name': z.name,
      'scheduleDate': z.scheduleDate,
      'status': z.status,
    })).toList();
    await prefs.setStringList('zones', zonesJson);
  }

  static Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load complaints
    List<String>? savedComplaints = prefs.getStringList('complaints');
    if (savedComplaints != null) {
      complaints = savedComplaints.map((json) {
        Map<String, dynamic> data = jsonDecode(json);
        return Complaint(
          id: data['id'],
          residentId: data['residentId'],
          residentName: data['residentName'],
          description: data['description'],
          location: data['location'],
          status: data['status'],
          date: DateTime.parse(data['date']),
        );
      }).toList();
    }

    // Load payments
    List<String>? savedPayments = prefs.getStringList('payments');
    if (savedPayments != null) {
      payments = savedPayments.map((json) {
        Map<String, dynamic> data = jsonDecode(json);
        return Payment(
          id: data['id'],
          residentId: data['residentId'],
          amount: data['amount'],
          status: data['status'],
          date: DateTime.parse(data['date']),
        );
      }).toList();
    }

    // Load special drives
    List<String>? savedDrives = prefs.getStringList('specialDrives');
    if (savedDrives != null) {
      specialDrives = savedDrives.map((json) {
        Map<String, dynamic> data = jsonDecode(json);
        return SpecialDrive(
          id: data['id'],
          title: data['title'],
          description: data['description'],
          zones: List<String>.from(data['zones']),
          date: DateTime.parse(data['date']),
        );
      }).toList();
    }

    // Load zones
    List<String>? savedZones = prefs.getStringList('zones');
    if (savedZones != null) {
      zones = savedZones.map((json) {
        Map<String, dynamic> data = jsonDecode(json);
        return Zone(
          id: data['id'],
          name: data['name'],
          scheduleDate: data['scheduleDate'],
          status: data['status'],
        );
      }).toList();
    }
  }
}

// ==================== LOGIN SCREEN ====================

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? selectedUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.green.shade700, Colors.green.shade300],
          ),
        ),
        child: Center(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.recycling, size: 64, color: Colors.green),
                  const SizedBox(height: 16),
                  const Text(
                    'Cooperative Waste Management',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Role & User', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedUserId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    items: AppData.users.map((user) {
                      return DropdownMenuItem(
                        value: user.id,
                        child: Text('${user.name} (${user.role.toUpperCase()})${user.zone != null ? ' - ${user.zone}' : ''}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedUserId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: selectedUserId != null ? () {
                      final user = AppData.users.firstWhere((u) => u.id == selectedUserId);
                      AppData.currentUser = user;
                      AppData.currentUserRole = user.role;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const DashboardRouter()),
                      );
                    } : null,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: Colors.green,
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== DASHBOARD ROUTER ====================

class DashboardRouter extends StatelessWidget {
  const DashboardRouter({super.key});

  @override
  Widget build(BuildContext context) {
    switch (AppData.currentUserRole) {
      case 'admin':
        return const AdminDashboard();
      case 'supervisor':
        return const SupervisorDashboard();
      case 'driver':
        return const DriverDashboard();
      case 'resident':
        return const ResidentDashboard();
      default:
        return const LoginScreen();
    }
  }
}

// ==================== ADMIN DASHBOARD ====================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin: ${AppData.currentUser?.name}'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.report), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Drives'),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildUserManagement();
      case 1:
        return _buildReports();
      case 2:
        return _buildSpecialDrives();
      default:
        return Container();
    }
  }

  Widget _buildUserManagement() {
    return ListView.builder(
      itemCount: AppData.users.length,
      itemBuilder: (context, index) {
        final user = AppData.users[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: ListTile(
            leading: Icon(Icons.person, color: _getRoleColor(user.role)),
            title: Text(user.name),
            subtitle: Text('${user.role.toUpperCase()}${user.zone != null ? ' - ${user.zone}' : ''}'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  AppData.users.removeAt(index);
                });
                _showNotification(context, 'User deleted successfully');
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildReports() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildReportCard('Total Complaints', AppData.complaints.length.toString(), Icons.report, Colors.orange),
          const SizedBox(height: 12),
          _buildReportCard('Total Payments', '₹${AppData.payments.fold(0.0, (sum, p) => sum + p.amount)}', Icons.payment, Colors.green),
          const SizedBox(height: 12),
          _buildReportCard('Collection Status', '${AppData.zones.where((z) => z.status == 'Completed').length}/${AppData.zones.length} Zones', Icons.delete, Colors.blue),
          const SizedBox(height: 16),
          const Text('Recent Complaints', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...AppData.complaints.reversed.take(5).map((c) => ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: Text(c.description),
            subtitle: Text('${c.residentName} - ${c.status}'),
          )),
        ],
      ),
    );
  }

  Widget _buildReportCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color, child: Icon(icon, color: Colors.white)),
            const SizedBox(width: 16),
            Expanded(child: Text(title, style: const TextStyle(fontSize: 16))),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecialDrives() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    String? selectedZone;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Announce Special Drive'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Title')),
                      TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description')),
                      DropdownButtonFormField<String>(
                        value: selectedZone,
                        decoration: const InputDecoration(labelText: 'Zone'),
                        items: ['All Zones', ...AppData.zones.map((z) => z.name)].map((zone) {
                          return DropdownMenuItem(value: zone, child: Text(zone));
                        }).toList(),
                        onChanged: (value) => selectedZone = value,
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        final drive = SpecialDrive(
                          id: DateTime.now().toString(),
                          title: titleController.text,
                          description: descController.text,
                          zones: selectedZone == 'All Zones' ? AppData.zones.map((z) => z.name).toList() : [selectedZone!],
                          date: DateTime.now(),
                        );
                        setState(() {
                          AppData.specialDrives.add(drive);
                        });
                        _showNotification(context, 'Special drive announced: ${drive.title}');
                        Navigator.pop(context);
                        titleController.clear();
                        descController.clear();
                      },
                      child: const Text('Announce'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.campaign),
            label: const Text('Announce Special Drive'),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: AppData.specialDrives.length,
            itemBuilder: (context, index) {
              final drive = AppData.specialDrives[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: ListTile(
                  leading: const Icon(Icons.announcement, color: Colors.orange),
                  title: Text(drive.title),
                  subtitle: Text('${drive.description}\nZones: ${drive.zones.join(", ")}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin': return Colors.red;
      case 'supervisor': return Colors.blue;
      case 'driver': return Colors.orange;
      case 'resident': return Colors.green;
      default: return Colors.grey;
    }
  }

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }
}

// ==================== SUPERVISOR DASHBOARD ====================

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Dashboard'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),      body: _getBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedules'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Complaints'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assign Tasks'),
        ],
      ),
    );
  }

  Widget _getBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildScheduleManagement();
      case 1:
        return _buildComplaints();
      case 2:
        return _buildTaskAssignment();
      default:
        return Container();
    }
  }

  Widget _buildScheduleManagement() {
    return ListView.builder(
      itemCount: AppData.zones.length,
      itemBuilder: (context, index) {
        final zone = AppData.zones[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.location_city, color: Colors.blue),
            title: Text(zone.name),
            subtitle: Text('Schedule: ${zone.scheduleDate} | Status: ${zone.status}'),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                _editSchedule(zone);
              },
            ),
          ),
        );
      },
    );
  }

  void _editSchedule(Zone zone) {
    DateTime? selectedDate;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Schedule for ${zone.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () async {
                selectedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                setState(() {});
              },
              child: Text(selectedDate != null ? DateFormat('yyyy-MM-dd').format(selectedDate!) : 'Select Date'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (selectedDate != null) {
                setState(() {
                  zone.scheduleDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
                });
                _showNotification(context, 'Schedule updated for ${zone.name}');
                // Notify residents
                final residents = AppData.users.where((u) => u.zone == zone.name && u.role == 'resident');
                for (var resident in residents) {
                  _showNotification(context, '${resident.name}: Your waste collection schedule has been updated to ${zone.scheduleDate}');
                }
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildComplaints() {
    final zoneComplaints = AppData.getComplaintsByZone(AppData.currentUser?.zone);

    return ListView.builder(
      itemCount: zoneComplaints.length,
      itemBuilder: (context, index) {
        final complaint = zoneComplaints[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            leading: Icon(Icons.warning, color: complaint.status == 'Pending' ? Colors.red : Colors.green),
            title: Text(complaint.residentName),
            subtitle: Text('${complaint.description}\nLocation: ${complaint.location}\nStatus: ${complaint.status}'),
            trailing: complaint.status == 'Pending'
                ? ElevatedButton(
              onPressed: () {
                setState(() {
                  complaint.status = 'Resolved';
                });
                _showNotification(context, 'Complaint from ${complaint.residentName} marked as resolved');
              },
              child: const Text('Resolve'),
            )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildTaskAssignment() {
    final drivers = AppData.users.where((u) => u.role == 'driver').toList();
    final pendingComplaints = AppData.complaints.where((c) => c.status == 'Pending').toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Assign Drivers to Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: pendingComplaints.length,
            itemBuilder: (context, index) {
              final complaint = pendingComplaints[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(complaint.description),
                  subtitle: DropdownButton<String>(
                    hint: const Text('Assign to driver'),
                    items: drivers.map((d) => DropdownMenuItem(value: d.name, child: Text(d.name))).toList(),
                    onChanged: (value) {
                      _showNotification(context, 'Task assigned to $value for complaint: ${complaint.description}');
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.blue, behavior: SnackBarBehavior.floating),
    );
  }
}

// ==================== DRIVER DASHBOARD ====================

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  @override
  Widget build(BuildContext context) {
    final myZone = AppData.currentUser?.zone ?? 'Zone A';
    final zoneSchedule = AppData.zones.firstWhere((z) => z.name == myZone);

    return Scaffold(
      appBar: AppBar(
        title: Text('Driver: ${AppData.currentUser?.name}'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Your Assigned Zone', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(myZone, style: const TextStyle(fontSize: 24, color: Colors.blue)),
                    const SizedBox(height: 8),
                    Text('Schedule: ${zoneSchedule.scheduleDate}', style: const TextStyle(fontSize: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Update Pickup Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  zoneSchedule.status = 'Completed';
                });
                _showNotification(context, 'Pickup completed for $myZone');
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Completed'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  zoneSchedule.status = 'Delayed';
                });
                _showNotification(context, 'Pickup delayed for $myZone');
                // Notify residents
                final residents = AppData.users.where((u) => u.zone == myZone && u.role == 'resident');
                for (var resident in residents) {
                  _showNotification(context, '${resident.name}: Waste collection in $myZone is delayed');
                }
              },
              icon: const Icon(Icons.warning),
              label: const Text('Mark as Delayed'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating),
    );
  }
}

// ==================== RESIDENT DASHBOARD ====================

class ResidentDashboard extends StatefulWidget {
  const ResidentDashboard({super.key});

  @override
  State<ResidentDashboard> createState() => _ResidentDashboardState();
}

class _ResidentDashboardState extends State<ResidentDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final myZone = AppData.currentUser?.zone ?? 'Zone A';
    final zoneSchedule = AppData.zones.firstWhere((z) => z.name == myZone);

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${AppData.currentUser?.name}'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),      body: _getBody(zoneSchedule),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Schedule'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Complaints'),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
        ],
      ),
    );
  }

  Widget _getBody(Zone zoneSchedule) {
    switch (_selectedIndex) {
      case 0:
        return _buildSchedule(zoneSchedule);
      case 1:
        return _buildComplaints();
      case 2:
        return _buildPayments();
      default:
        return Container();
    }
  }

  Widget _buildSchedule(Zone zoneSchedule) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Icon(Icons.delete_sweep, size: 48, color: Colors.green),
                  const SizedBox(height: 12),
                  Text('Your Zone: ${AppData.currentUser?.zone}', style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text('Next Collection Date:', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(zoneSchedule.scheduleDate, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: zoneSchedule.status == 'Delayed' ? Colors.red.shade50 : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Status: ${zoneSchedule.status}', style: TextStyle(color: zoneSchedule.status == 'Delayed' ? Colors.red : Colors.green)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (AppData.specialDrives.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Special Drives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    ...AppData.specialDrives.where((d) => d.zones.contains(AppData.currentUser?.zone) || d.zones.contains('All Zones')).map((drive) =>
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.campaign, size: 16, color: Colors.orange),
                              const SizedBox(width: 8),
                              Expanded(child: Text('${drive.title}: ${drive.description}')),
                            ],
                          ),
                        )
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildComplaints() {
    final myComplaints = AppData.complaints.where((c) => c.residentId == AppData.currentUser?.id).toList();
    TextEditingController descController = TextEditingController();
    TextEditingController locationController = TextEditingController();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Raise Complaint'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: descController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
                      const SizedBox(height: 8),
                      TextField(controller: locationController, decoration: const InputDecoration(labelText: 'Location (e.g., Street Name)')),
                    ],
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () {
                        final complaint = Complaint(
                          id: DateTime.now().toString(),
                          residentId: AppData.currentUser!.id,
                          residentName: AppData.currentUser!.name,
                          description: descController.text,
                          location: locationController.text,
                          status: 'Pending',
                          date: DateTime.now(),
                        );
                        setState(() {
                          AppData.complaints.add(complaint);
                        });
                        _showNotification(context, 'Complaint raised successfully');
                        Navigator.pop(context);
                        descController.clear();
                        locationController.clear();
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.add_alert),
            label: const Text('Raise New Complaint'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: myComplaints.length,
            itemBuilder: (context, index) {
              final complaint = myComplaints[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(Icons.warning, color: complaint.status == 'Pending' ? Colors.red : Colors.green),
                  title: Text(complaint.description),
                  subtitle: Text('Location: ${complaint.location}\nStatus: ${complaint.status}\nDate: ${DateFormat('MMM dd').format(complaint.date)}'),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPayments() {
    final myPayments = AppData.payments.where((p) => p.residentId == AppData.currentUser?.id).toList();
    double totalDue = 500.0 - myPayments.fold(0.0, (sum, p) => sum + p.amount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Total Dues', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text('₹${totalDue.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 12),
                  if (totalDue > 0)
                    ElevatedButton.icon(
                      onPressed: () {
                        final payment = Payment(
                          id: DateTime.now().toString(),
                          residentId: AppData.currentUser!.id,
                          amount: totalDue,
                          status: 'Completed',
                          date: DateTime.now(),
                        );
                        setState(() {
                          AppData.payments.add(payment);
                        });
                        _showNotification(context, 'Payment of ₹${totalDue.toStringAsFixed(2)} completed successfully');
                      },
                      icon: const Icon(Icons.payment),
                      label: Text('Pay ₹${totalDue.toStringAsFixed(2)}'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ...myPayments.map((payment) => ListTile(
            leading: const Icon(Icons.receipt, color: Colors.green),
            title: Text('₹${payment.amount.toStringAsFixed(2)}'),
            subtitle: Text(DateFormat('MMM dd, yyyy').format(payment.date)),
            trailing: const Icon(Icons.check_circle, color: Colors.green),
          )),
        ],
      ),
    );
  }

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }
}
