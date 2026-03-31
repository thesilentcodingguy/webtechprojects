import 'package:flutter/material.dart';

void main() {
  runApp(const GroceryApp());
}

class GroceryApp extends StatelessWidget {
  const GroceryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: Colors.green)),
      home: const GroceryScreen(),
    );
  }
}

class GroceryScreen extends StatefulWidget {
  const GroceryScreen({super.key});

  @override
  State<GroceryScreen> createState() => _GroceryScreenState();
}

class _GroceryScreenState extends State<GroceryScreen> {
  final List<Map<String, dynamic>> _items = [
    {'name': 'Apples', 'price': 2.99, 'emoji': '🍎'},
    {'name': 'Bananas', 'price': 1.49, 'emoji': '🍌'},
    {'name': 'Bread', 'price': 2.49, 'emoji': '🍞'},
    {'name': 'Milk', 'price': 3.99, 'emoji': '🥛'},
    {'name': 'Eggs', 'price': 4.99, 'emoji': '🥚'},
    {'name': 'Chicken', 'price': 8.99, 'emoji': '🍗'},
    {'name': 'Rice', 'price': 5.99, 'emoji': '🍚'},
    {'name': 'Tomatoes', 'price': 1.99, 'emoji': '🍅'},
  ];

  int _currentIndex = 0;
  final Map<String, int> _cart = {};

  void _nextItem() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _items.length;
    });
  }

  void _previousItem() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _items.length) % _items.length;
    });
  }

  void _addToCart() {
    String itemName = _items[_currentIndex]['name'];
    setState(() {
      _cart[itemName] = (_cart[itemName] ?? 0) + 1;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${_items[_currentIndex]['emoji']} ${_items[_currentIndex]['name']} to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Store'),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CartScreen(cart: _cart, items: _items)),
                  ).then((_) => setState(() {}));
                },
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${_cart.values.reduce((a, b) => a + b)}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _previousItem();
          } else if (details.primaryVelocity! < 0) {
            _nextItem();
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      _items[_currentIndex]['emoji'],
                      style: const TextStyle(fontSize: 80),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _items[_currentIndex]['name'],
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '\$${_items[_currentIndex]['price'].toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 24, color: Colors.green),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton.icon(
                      onPressed: _addToCart,
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                '← Swipe left/right to browse →',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  final Map<String, int> cart;
  final List<Map<String, dynamic>> items;

  const CartScreen({super.key, required this.cart, required this.items});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  double get _total {
    double total = 0;
    widget.cart.forEach((itemName, quantity) {
      final item = widget.items.firstWhere((i) => i['name'] == itemName);
      total += item['price'] * quantity;
    });
    return total;
  }

  void _updateQuantity(String itemName, int change) {
    setState(() {
      if (change > 0) {
        widget.cart[itemName] = (widget.cart[itemName] ?? 0) + 1;
      } else {
        if (widget.cart[itemName]! > 1) {
          widget.cart[itemName] = widget.cart[itemName]! - 1;
        } else {
          widget.cart.remove(itemName);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
        centerTitle: true,
      ),
      body: widget.cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty', style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.cart.length,
                    itemBuilder: (context, index) {
                      String itemName = widget.cart.keys.elementAt(index);
                      int quantity = widget.cart[itemName]!;
                      final item = widget.items.firstWhere((i) => i['name'] == itemName);
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: ListTile(
                          leading: Text(item['emoji'], style: const TextStyle(fontSize: 32)),
                          title: Text(itemName),
                          subtitle: Text('\$${item['price']} each'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () => _updateQuantity(itemName, -1),
                              ),
                              Text('$quantity', style: const TextStyle(fontSize: 18)),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () => _updateQuantity(itemName, 1),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade200, blurRadius: 10),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('\$${_total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PaymentScreen(total: _total)),
                            );
                          },
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Proceed to Payment', style: TextStyle(fontSize: 16)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  final double total;

  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'Cash';
  final List<String> _methods = ['Cash', 'Card', 'UPI'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.payment, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              Text('Total Amount: \$${widget.total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              const Text('Select Payment Method', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 16),
              ..._methods.map((method) => RadioListTile(
                title: Text(method),
                value: method,
                groupValue: _selectedMethod,
                onChanged: (value) => setState(() => _selectedMethod = value!),
                activeColor: Colors.green,
              )),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptScreen(
                        total: widget.total,
                        method: _selectedMethod,
                        items: ModalRoute.of(context)!.settings.arguments as Map<String, int>? ?? {},
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
                child: const Text('Place Order', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptScreen extends StatelessWidget {
  final double total;
  final String method;
  final Map<String, int> items;

  const ReceiptScreen({super.key, required this.total, required this.method, required this.items});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Receipt'),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 80, color: Colors.green),
              const SizedBox(height: 24),
              const Text('Order Placed Successfully!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('Receipt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text('Payment Method: $method'),
                    const SizedBox(height: 8),
                    Text('Total: \$${total.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 16),
                    const Text('Thank you for shopping!', style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
                child: const Text('Back to Shopping'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
