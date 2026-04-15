import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const SmartHomeServicesApp());
}

class SmartHomeServicesApp extends StatelessWidget {
  const SmartHomeServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Home Services',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// Service model
class Service {
  final String id;
  final String name;
  final double basePrice;
  final double rating;
  final int reviewCount;
  final IconData icon;

  const Service({
    required this.id,
    required this.name,
    required this.basePrice,
    required this.rating,
    required this.reviewCount,
    required this.icon,
  });
}

// Order model
class Order {
  String id;
  String serviceId;
  String serviceName;
  double price;
  DateTime date;
  TimeOfDay time;
  String professionalName;
  double professionalRating;
  OrderStatus status;

  Order({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.date,
    required this.time,
    required this.professionalName,
    required this.professionalRating,
    this.status = OrderStatus.pending,
  });

  String getFormattedDateTime() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat.jm();
    final dateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return '${dateFormat.format(date)} at ${timeFormat.format(dateTime)}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'price': price,
      'date': date.toIso8601String(),
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'professionalName': professionalName,
      'professionalRating': professionalRating,
      'status': status.index,
    };
  }
}

enum OrderStatus { pending, confirmed, solved }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.solved:
        return 'Solved';
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.green;
      case OrderStatus.solved:
        return Colors.blue;
    }
  }
}

// Available services (5 names given)
final List<Service> availableServices = [
  const Service(
    id: 's1',
    name: 'Plumbing',
    basePrice: 49.99,
    rating: 4.8,
    reviewCount: 234,
    icon: Icons.plumbing,
  ),
  const Service(
    id: 's2',
    name: 'Electrical',
    basePrice: 59.99,
    rating: 4.7,
    reviewCount: 189,
    icon: Icons.electrical_services,
  ),
  const Service(
    id: 's3',
    name: 'Cleaning',
    basePrice: 39.99,
    rating: 4.9,
    reviewCount: 456,
    icon: Icons.cleaning_services,
  ),
  const Service(
    id: 's4',
    name: 'AC Repair',
    basePrice: 79.99,
    rating: 4.6,
    reviewCount: 167,
    icon: Icons.ac_unit,
  ),
  const Service(
    id: 's5',
    name: 'Carpentry',
    basePrice: 54.99,
    rating: 4.7,
    reviewCount: 98,
    icon: Icons.handyman,
  ),
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Order> _orders = [];
  int _selectedIndex = 0;

  void _addOrder(Order order) {
    setState(() {
      _orders.add(order);
    });
  }

  void _updateOrderStatus(String orderId, OrderStatus newStatus) {
    setState(() {
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index].status = newStatus;
      }
    });
  }

  double get _totalCost {
    return _orders.fold(0.0, (sum, order) => sum + order.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BookingPage(onOrderPlaced: _addOrder),
          OrdersPage(orders: _orders, onUpdateStatus: _updateOrderStatus),
          BillPage(orders: _orders, totalCost: _totalCost),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.book_online), label: 'Book'),
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.receipt), label: 'Bill'),
        ],
      ),
    );
  }
}

class BookingPage extends StatefulWidget {
  final Function(Order) onOrderPlaced;

  const BookingPage({super.key, required this.onOrderPlaced});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Service? _selectedService;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedProfessional = '';
  double _professionalRating = 0.0;

  final List<Map<String, dynamic>> _professionals = [
    {'name': 'John Smith', 'rating': 4.9, 'reviews': 128, 'specialty': 'Plumbing'},
    {'name': 'Sarah Johnson', 'rating': 4.8, 'reviews': 95, 'specialty': 'Electrical'},
    {'name': 'Mike Davis', 'rating': 4.9, 'reviews': 203, 'specialty': 'Cleaning'},
    {'name': 'David Wilson', 'rating': 4.7, 'reviews': 76, 'specialty': 'AC Repair'},
    {'name': 'Robert Brown', 'rating': 4.8, 'reviews': 112, 'specialty': 'Carpentry'},
    {'name': 'Emily Clark', 'rating': 5.0, 'reviews': 67, 'specialty': 'Cleaning'},
    {'name': 'James Lee', 'rating': 4.6, 'reviews': 89, 'specialty': 'Plumbing'},
  ];

  List<Map<String, dynamic>> _getFilteredProfessionals() {
    if (_selectedService == null) return [];
    final serviceName = _selectedService!.name;
    return _professionals.where((p) => p['specialty'] == serviceName).toList();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _placeOrder() {
    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a service')),
      );
      return;
    }
    if (_selectedProfessional.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a professional')),
      );
      return;
    }

    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      serviceId: _selectedService!.id,
      serviceName: _selectedService!.name,
      price: _selectedService!.basePrice,
      date: _selectedDate,
      time: _selectedTime,
      professionalName: _selectedProfessional,
      professionalRating: _professionalRating,
      status: OrderStatus.pending,
    );

    widget.onOrderPlaced(order);
    setState(() {
      _selectedService = null;
      _selectedProfessional = '';
      _professionalRating = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${order.serviceName} booked successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPros = _getFilteredProfessionals();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book a Service'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Service',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: availableServices.length,
              itemBuilder: (context, index) {
                final service = availableServices[index];
                final isSelected = _selectedService?.id == service.id;
                return Card(
                  elevation: isSelected ? 4 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedService = service;
                        _selectedProfessional = '';
                        _professionalRating = 0.0;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(service.icon, size: 40, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 8),
                        Text(
                          service.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\$${service.basePrice.toStringAsFixed(2)}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star, size: 14, color: Colors.amber),
                            const SizedBox(width: 2),
                            Text(
                              service.rating.toString(),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${service.reviewCount})',
                              style: TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_selectedService != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selected: ${_selectedService!.name}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text('\$${_selectedService!.basePrice.toStringAsFixed(2)}'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select Professional',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (filteredPros.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  child: const Text('No professionals available for this service'),
                )
              else
                Column(
                  children: filteredPros.map((pro) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(pro['name'][0]),
                        ),
                        title: Text(pro['name']),
                        subtitle: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(pro['rating'].toString()),
                            const SizedBox(width: 8),
                            Text('(${pro['reviews']} reviews)'),
                          ],
                        ),
                        trailing: Radio<String>(
                          value: pro['name'],
                          groupValue: _selectedProfessional,
                          onChanged: (value) {
                            setState(() {
                              _selectedProfessional = value!;
                              _professionalRating = pro['rating'];
                            });
                          },
                        ),
                        onTap: () {
                          setState(() {
                            _selectedProfessional = pro['name'];
                            _professionalRating = pro['rating'];
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              const SizedBox(height: 16),
              const Text(
                'Choose Date & Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today),
                      label: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time),
                      label: Text(_selectedTime.format(context)),
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _placeOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Place Order', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  final List<Order> orders;
  final Function(String, OrderStatus) onUpdateStatus;

  const OrdersPage({super.key, required this.orders, required this.onUpdateStatus});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        elevation: 0,
      ),
      body: orders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No orders yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('Book a service to get started', style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders.reversed.toList()[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: order.status.color.withOpacity(0.1),
                child: Icon(
                  _getIconForService(order.serviceName),
                  color: order.status.color,
                ),
              ),
              title: Text(
                order.serviceName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.getFormattedDateTime()),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: order.status.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      order.status.displayName,
                      style: TextStyle(color: order.status.color, fontSize: 12),
                    ),
                  ),
                ],
              ),
              trailing: Text(
                '\$${order.price.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Professional: ${order.professionalName}'),
                          const SizedBox(width: 12),
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(order.professionalRating.toString()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.receipt, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text('Order ID: ${order.id.substring(order.id.length - 8)}'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (order.status != OrderStatus.solved)
                        Row(
                          children: [
                            if (order.status == OrderStatus.pending)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    onUpdateStatus(order.id, OrderStatus.confirmed);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order confirmed!')),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.green,
                                  ),
                                  child: const Text('Confirm'),
                                ),
                              ),
                            if (order.status == OrderStatus.confirmed) ...[
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    onUpdateStatus(order.id, OrderStatus.solved);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Order marked as solved!')),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue,
                                  ),
                                  child: const Text('Mark Solved'),
                                ),
                              ),
                            ],
                          ],
                        ),
                      if (order.status == OrderStatus.solved)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              SizedBox(width: 8),
                              Text('Service completed successfully'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  IconData _getIconForService(String serviceName) {
    switch (serviceName) {
      case 'Plumbing':
        return Icons.plumbing;
      case 'Electrical':
        return Icons.electrical_services;
      case 'Cleaning':
        return Icons.cleaning_services;
      case 'AC Repair':
        return Icons.ac_unit;
      case 'Carpentry':
        return Icons.handyman;
      default:
        return Icons.build;
    }
  }
}

class BillPage extends StatelessWidget {
  final List<Order> orders;
  final double totalCost;

  const BillPage({super.key, required this.orders, required this.totalCost});

  @override
  Widget build(BuildContext context) {
    final completedOrders = orders.where((o) => o.status == OrderStatus.solved).toList();
    final pendingAmount = orders
        .where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.confirmed)
        .fold(0.0, (sum, o) => sum + o.price);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cumulative Bill'),
        elevation: 0,
      ),
      body: orders.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('No bills yet', style: TextStyle(fontSize: 18, color: Colors.grey)),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Total Bill',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${totalCost.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBillSummaryItem('Total Orders', orders.length, Colors.blue),
                        _buildBillSummaryItem('Completed', completedOrders.length, Colors.green),
                        _buildBillSummaryItem('Pending', orders.length - completedOrders.length, Colors.orange),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Payment Breakdown',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders.reversed.toList()[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: order.status.color.withOpacity(0.1),
                      child: Icon(
                        Icons.receipt,
                        size: 20,
                        color: order.status.color,
                      ),
                    ),
                    title: Text(order.serviceName),
                    subtitle: Text(
                      '${order.status.displayName} • ${order.getFormattedDateTime()}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${order.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (order.status == OrderStatus.solved)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Paid',
                              style: TextStyle(fontSize: 10, color: Colors.green),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Pending',
                              style: TextStyle(fontSize: 10, color: Colors.orange),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade700, Colors.blue.shade500],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Pending Payment',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${pendingAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${orders.where((o) => o.status != OrderStatus.solved).length} orders pending',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.amber.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.amber),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Payment is collected upon service completion. Orders marked as "Solved" are considered paid.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillSummaryItem(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
