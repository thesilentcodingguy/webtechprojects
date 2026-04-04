import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: PharmacyApp()));
}

class Medicine {
  final int id;
  final String name;
  final String dosage;
  final double price;
  final bool requiresPrescription;
  final int maxLimit;
  final String category;
  final bool isExpiringSoon;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.price,
    required this.requiresPrescription,
    required this.maxLimit,
    required this.category,
    required this.isExpiringSoon,
  });
}

class CartItem {
  final Medicine medicine;
  int quantity;

  CartItem({required this.medicine, required this.quantity});
}

class PharmacyApp extends StatefulWidget {
  @override
  State<PharmacyApp> createState() => _PharmacyAppState();
}

class _PharmacyAppState extends State<PharmacyApp> {
  List<Medicine> medicines = [];
  List<CartItem> cart = [];
  bool prescriptionAccepted = false;

  @override
  void initState() {
    super.initState();
    medicines = [
      Medicine(id: 1, name: "Paracetamol", dosage: "500mg", price: 5, requiresPrescription: false, maxLimit: 10, category: "Pain", isExpiringSoon: false),
      Medicine(id: 2, name: "Ibuprofen", dosage: "400mg", price: 8, requiresPrescription: false, maxLimit: 8, category: "Pain", isExpiringSoon: true),
      Medicine(id: 3, name: "Amoxicillin", dosage: "250mg", price: 15, requiresPrescription: true, maxLimit: 3, category: "Antibiotic", isExpiringSoon: false),
      Medicine(id: 4, name: "Azithromycin", dosage: "500mg", price: 25, requiresPrescription: true, maxLimit: 2, category: "Antibiotic", isExpiringSoon: true),
    ];
  }

  void addToCart(Medicine med) {
    int index = cart.indexWhere((c) => c.medicine.id == med.id);

    if (index != -1) {
      if (cart[index].quantity < med.maxLimit) {
        setState(() => cart[index].quantity++);
      }
    } else {
      if (med.requiresPrescription && !prescriptionAccepted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Prescription Required"),
            content: Text("Do you have prescription?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("No")),
              TextButton(
                  onPressed: () {
                    setState(() {
                      prescriptionAccepted = true;
                      cart.add(CartItem(medicine: med, quantity: 1));
                    });
                    Navigator.pop(context);
                  },
                  child: Text("Yes"))
            ],
          ),
        );
      } else {
        setState(() => cart.add(CartItem(medicine: med, quantity: 1)));
      }
    }
  }

  void removeFromCart(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cart.remove(item);
      }
    });
  }

  void increaseQty(CartItem item) {
    if (item.quantity < item.medicine.maxLimit) {
      setState(() => item.quantity++);
    }
  }

  double subtotal() {
    return cart.fold(0, (sum, item) => sum + item.quantity * item.medicine.price);
  }

  double tax() {
    return subtotal() * 0.12;
  }

  double total() {
    return subtotal() + tax();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(title: Text("Pharmacy"), bottom: TabBar(tabs: [
          Tab(text: "Medicines"),
          Tab(text: "Cart (${cart.length})")
        ])),
        body: TabBarView(children: [
          ListView.builder(
            itemCount: medicines.length,
            itemBuilder: (_, i) {
              var m = medicines[i];
              return Card(
                child: ListTile(
                  title: Text("${m.name} (${m.dosage})"),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("₹${m.price} | ${m.category}"),
                      if (m.isExpiringSoon)
                        Text("Expiring Soon!", style: TextStyle(color: Colors.orange)),
                    ],
                  ),
                  trailing: Column(
                    children: [
                      if (m.requiresPrescription)
                        Icon(Icons.medical_services, color: Colors.red),
                      ElevatedButton(onPressed: () => addToCart(m), child: Text("Add"))
                    ],
                  ),
                ),
              );
            },
          ),
          Column(
            children: [
              Expanded(
                child: cart.isEmpty
                    ? Center(child: Text("Cart Empty"))
                    : ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (_, i) {
                          var item = cart[i];
                          return ListTile(
                            title: Text(item.medicine.name),
                            subtitle: Text("₹${item.medicine.price} x ${item.quantity}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: Icon(Icons.remove), onPressed: () => removeFromCart(item)),
                                IconButton(icon: Icon(Icons.add), onPressed: () => increaseQty(item)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("Subtotal"), Text("₹${subtotal().toStringAsFixed(2)}")
                    ]),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("Tax (12%)"), Text("₹${tax().toStringAsFixed(2)}")
                    ]),
                    Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text("Total", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("₹${total().toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold))
                    ]),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => CheckoutPage(cart, subtotal(), tax(), total()),
                                ),
                              );
                            },
                      child: Text("Confirm & Checkout"),
                      style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
                    )
                  ],
                ),
              )
            ],
          )
        ]),
      ),
    );
  }
}

class CheckoutPage extends StatelessWidget {
  final List<CartItem> cart;
  final double subtotal;
  final double tax;
  final double total;

  CheckoutPage(this.cart, this.subtotal, this.tax, this.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Checkout")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Text("INVOICE", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Divider(),
                  ...cart.map((item) => ListTile(
                        title: Text(item.medicine.name),
                        subtitle: Text("${item.quantity} x ₹${item.medicine.price}"),
                        trailing: Text("₹${item.quantity * item.medicine.price}"),
                      )),
                  Divider(),
                  Text("Subtotal: ₹${subtotal.toStringAsFixed(2)}"),
                  Text("Tax: ₹${tax.toStringAsFixed(2)}"),
                  Text("Total: ₹${total.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 20),
                  Text(
                    "Health Disclaimer:\nConsult a doctor before consuming medicines. Follow dosage instructions carefully.",
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text("Order Placed"),
                    content: Text("Your medicines will be delivered soon."),
                    actions: [
                      TextButton(onPressed: () => Navigator.popUntil(context, (route) => route.isFirst), child: Text("OK"))
                    ],
                  ),
                );
              },
              child: Text("Confirm & Place Order"),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
            )
          ],
        ),
      ),
    );
  }
}
