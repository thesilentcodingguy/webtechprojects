import 'package:flutter/material.dart';

void main() {
  runApp(const DoctorAppointmentApp());
}

class DoctorAppointmentApp extends StatelessWidget {
  const DoctorAppointmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doctor Appointment',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ---------- Models ----------
class Doctor {
  final String id;
  final String name;
  final String specialty;
  final List<AvailableSlot> availableSlots;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.availableSlots,
  });
}

class AvailableSlot {
  final String date;
  final String time;

  AvailableSlot({required this.date, required this.time});
}

class Appointment {
  final String patientName;
  final String patientPhone;
  final String doctorId;
  final String doctorName;
  final String date;
  final String time;

  Appointment({
    required this.patientName,
    required this.patientPhone,
    required this.doctorId,
    required this.doctorName,
    required this.date,
    required this.time,
  });
}

// ---------- Mock Data ----------
List<Doctor> mockDoctors = [
  Doctor(
    id: 'd1',
    name: 'Dr. Sarah Johnson',
    specialty: 'Cardiologist',
    availableSlots: [
      AvailableSlot(date: '2026-04-05', time: '10:00 AM'),
      AvailableSlot(date: '2026-04-05', time: '11:30 AM'),
      AvailableSlot(date: '2026-04-06', time: '02:00 PM'),
      AvailableSlot(date: '2026-04-07', time: '09:00 AM'),
    ],
  ),
  Doctor(
    id: 'd2',
    name: 'Dr. Michael Lee',
    specialty: 'Dermatologist',
    availableSlots: [
      AvailableSlot(date: '2026-04-05', time: '01:00 PM'),
      AvailableSlot(date: '2026-04-06', time: '10:30 AM'),
      AvailableSlot(date: '2026-04-06', time: '03:00 PM'),
    ],
  ),
  Doctor(
    id: 'd3',
    name: 'Dr. Emily White',
    specialty: 'Pediatrician',
    availableSlots: [
      AvailableSlot(date: '2026-04-07', time: '11:00 AM'),
      AvailableSlot(date: '2026-04-08', time: '09:30 AM'),
      AvailableSlot(date: '2026-04-08', time: '01:30 PM'),
    ],
  ),
];

// Global appointments list (acts as "database")
List<Appointment> allAppointments = [];

// ---------- Home Page (Dashboard Selector) ----------
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Appointment System'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PatientDashboard()),
                  );
                },
                icon: const Icon(Icons.person),
                label: const Text('Patient Dashboard', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(240, 50),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DoctorDashboard()),
                  );
                },
                icon: const Icon(Icons.medical_services),
                label: const Text('Doctor Dashboard', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(240, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Patient Dashboard ----------
class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  Doctor? selectedDoctor;
  AvailableSlot? selectedSlot;

  void _bookAppointment(BuildContext context, Doctor doctor, AvailableSlot slot) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController();
        final phoneController = TextEditingController();
        return AlertDialog(
          title: Text('Book with ${doctor.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isNotEmpty &&
                    phoneController.text.trim().isNotEmpty) {
                  final appointment = Appointment(
                    patientName: nameController.text.trim(),
                    patientPhone: phoneController.text.trim(),
                    doctorId: doctor.id,
                    doctorName: doctor.name,
                    date: slot.date,
                    time: slot.time,
                  );
                  setState(() {
                    allAppointments.add(appointment);
                    // Remove booked slot from doctor's availability
                    doctor.availableSlots.removeWhere(
                      (s) => s.date == slot.date && s.time == slot.time,
                    );
                  });
                  Navigator.pop(context); // close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Appointment booked successfully!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all fields')),
                  );
                }
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Patient Dashboard'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select a Doctor:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: mockDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = mockDoctors[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(doctor.name),
                      subtitle: Text(doctor.specialty),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        setState(() {
                          selectedDoctor = doctor;
                          selectedSlot = null;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            if (selectedDoctor != null) ...[
              const Divider(height: 24),
              Text('${selectedDoctor!.name} - Available Slots:',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Expanded(
                flex: 1,
                child: ListView.builder(
                  itemCount: selectedDoctor!.availableSlots.length,
                  itemBuilder: (context, idx) {
                    final slot = selectedDoctor!.availableSlots[idx];
                    return Card(
                      child: ListTile(
                        title: Text('${slot.date} at ${slot.time}'),
                        trailing: OutlinedButton(
                          onPressed: () => _bookAppointment(context, selectedDoctor!, slot),
                          child: const Text('Book'),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------- Doctor Dashboard ----------
class DoctorDashboard extends StatelessWidget {
  const DoctorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Doctor Dashboard'), centerTitle: true),
      body: allAppointments.isEmpty
          ? const Center(child: Text('No appointments booked yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: allAppointments.length,
              itemBuilder: (context, index) {
                final apt = allAppointments[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.person, size: 40),
                    title: Text(apt.patientName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📞 ${apt.patientPhone}'),
                        const SizedBox(height: 4),
                        Text('👨‍⚕️ ${apt.doctorName} | 📅 ${apt.date} | ⏰ ${apt.time}'),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
