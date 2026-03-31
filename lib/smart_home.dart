import 'package:flutter/material.dart';
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Gesture Home Automation',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: const HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool light = false, tv = false, ac = false;
  int channel = 1, volume = 10, temp = 24;
  void toggleLight() => setState(() => light = !light);
  void toggleTV() => setState(() => tv = !tv);
  void toggleAC() => setState(() => ac = !ac);
  void channelUp() => tv ? setState(() => channel++) : null;
  void channelDown() => tv && channel > 1 ? setState(() => channel--) : null;
  void volUp() => tv && volume < 100 ? setState(() => volume++) : null;
  void volDown() => tv && volume > 0 ? setState(() => volume--) : null;
  void tempUp() => ac && temp < 30 ? setState(() => temp++) : null;
  void tempDown() => ac && temp > 16 ? setState(() => temp--) : null;

  Widget buildControl(String label, int value, VoidCallback onInc, VoidCallback onDec,
      {bool isTemp = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            _buildIcon(Icons.remove, onDec),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(20),
              ),
              child: isTemp
                  ? Row(children: [Text('$temp', style: const TextStyle(fontSize: 18)), const Text('°C')])
                  : Text('$value', style: const TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 16),
            _buildIcon(Icons.add, onInc),
          ],
        ),
      ],
    );
  }

  Widget _buildIcon(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.all(8),
          child: Icon(icon, size: 20),
        ),
      );

  Widget _buildDeviceCard(IconData icon, String title, bool isOn, Color color,
      VoidCallback onPower, List<Widget>? controls, String gestureHint) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onDoubleTap: onPower,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Icon(icon, size: 28, color: isOn ? color : Colors.grey),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                Chip(
                  label: Text(isOn ? 'ON' : 'OFF'),
                  backgroundColor: isOn ? Colors.green.shade100 : Colors.red.shade100,
                  avatar: Icon(isOn ? Icons.power : Icons.power_off, size: 16),
                ),
              ]),
              const SizedBox(height: 8),
              Text(gestureHint, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const Divider(),
              if (isOn && controls != null) ...controls,
              if (!isOn)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: Text('Double Tap to turn ON', style: TextStyle(color: Colors.grey))),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gesture Home Automation'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade50, Colors.white],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Light Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: toggleLight,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(children: [
                    Icon(light ? Icons.lightbulb : Icons.lightbulb_outline, size: 32, color: light ? Colors.amber : Colors.grey),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Living Room Light', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Tap to Toggle', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Switch(value: light, onChanged: (_) => toggleLight(), activeColor: Colors.amber),
                  ]),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // TV Card
            _buildDeviceCard(
              Icons.tv, 'Smart TV', tv, Colors.blue, toggleTV,
              [
                buildControl('Channel:', channel, channelUp, channelDown),
                const SizedBox(height: 12),
                buildControl('Volume:', volume, volUp, volDown),
              ],
              'Double Tap to Power, Long Press Channel, Tap Volume',
            ),
            const SizedBox(height: 16),
            
            // AC Card
            _buildDeviceCard(
              Icons.ac_unit, 'Air Conditioner', ac, Colors.cyan, toggleAC,
              [buildControl('Temperature:', temp, tempUp, tempDown, isTemp: true)],
              'Double Tap to Power, Tap +/- for Temp',
            ),
          ],
        ),
      ),
    );
  }
}
