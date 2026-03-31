import 'package:flutter/material.dart';

void main() {
  runApp(PharmacyApp());
}

class PharmacyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pharmacy App',
      home: MedicineListPage(),
    );
  }
}

class Medicine {
  final int id;
  final String name;
  final double price;
  final bool requiresPrescription;
  final int maxLimit;
  final String category;
  
  Medicine({
    required this.id,
    required this.name,
    required this.price,
    required this.requiresPrescription,
    required this.maxLimit,
    required this.category,
  });
}

class CartItem {
  final Medicine medicine;
  int quantity;
  
  CartItem({
    required this.medicine,
    required this.quantity,
  });
}

class MedicineListPage extends StatefulWidget {
  @override
  _MedicineListPageState createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  List<Medicine> medicines = [];
  List<CartItem> cart = [];
  bool prescriptionDisclaimerAccepted = false;
  
  @override
  void initState() {
    super.initState();
    loadMedicines();
  }
  
  void loadMedicines() {
    medicines = [
      Medicine(id: 1, name: "Paracetamol 500mg", price: 5.0, requiresPrescription: false, maxLimit: 10, category: "Pain Relief"),
      Medicine(id: 2, name: "Ibuprofen 400mg", price: 8.0, requiresPrescription: false, maxLimit: 8, category: "Pain Relief"),
      Medicine(id: 3, name: "Amoxicillin 250mg", price: 15.0, requiresPrescription: true, maxLimit: 3, category: "Antibiotic"),
      Medicine(id: 4, name: "Azithromycin 500mg", price: 25.0, requiresPrescription: true, maxLimit: 2, category: "Antibiotic"),
      Medicine(id: 5, name: "Vitamin C 1000mg", price: 12.0, requiresPrescription: false, maxLimit: 15, category: "Supplements"),
      Medicine(id: 6, name: "Cetirizine 10mg", price: 6.0, requiresPrescription: false, maxLimit: 12, category: "Antihistamine"),
      Medicine(id: 7, name: "Metformin 500mg", price: 10.0, requiresPrescription: true, maxLimit: 5, category: "Diabetes"),
      Medicine(id: 8, name: "Omeprazole 20mg", price: 9.0, requiresPrescription: false, maxLimit: 10, category: "Gastric"),
      Medicine(id: 9, name: "Aspirin 75mg", price: 4.0, requiresPrescription: false, maxLimit: 20, category: "Blood Thinner"),
      Medicine(id: 10, name: "Ciprofloxacin 500mg", price: 18.0, requiresPrescription: true, maxLimit: 2, category: "Antibiotic"),
    ];
  }
  
  void addToCart(Medicine medicine) {
    // Check if already in cart
    int existingIndex = cart.indexWhere((item) => item.medicine.id == medicine.id);
    
    if (existingIndex != -1) {
      // Check max limit
      if (cart[existingIndex].quantity < medicine.maxLimit) {
        setState(() {
          cart[existingIndex].quantity++;
        });
        showSnackBar("Added one more ${medicine.name}");
      } else {
        showSnackBar("Cannot add more than ${medicine.maxLimit} units of ${medicine.name}");
      }
    } else {
      // Check if prescription required
      if (medicine.requiresPrescription && !prescriptionDisclaimerAccepted) {
        showPrescriptionDialog(medicine);
      } else {
        setState(() {
          cart.add(CartItem(medicine: medicine, quantity: 1));
        });
        showSnackBar("Added ${medicine.name} to cart");
      }
    }
  }
  
  void showPrescriptionDialog(Medicine medicine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Prescription Required"),
        content: Text("${medicine.name} requires a valid prescription. Do you have a prescription?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                prescriptionDisclaimerAccepted = true;
                cart.add(CartItem(medicine: medicine, quantity: 1));
              });
              Navigator.pop(context);
              showSnackBar("Added ${medicine.name} to cart (Prescription acknowledged)");
            },
            child: Text("Yes, I have"),
          ),
        ],
      ),
    );
  }
  
  void removeFromCart(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cart.remove(item);
      }
    });
    showSnackBar("Removed ${item.medicine.name} from cart");
  }
  
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 1)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Pharmacy App"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Medicines (${medicines.length})"),
              Tab(text: "Cart (${cart.length})"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MedicineList(medicines: medicines, onAdd: addToCart),
            CartPage(cart: cart, onRemove: removeFromCart),
          ],
        ),
      ),
    );
  }
}

class MedicineList extends StatelessWidget {
  final List<Medicine> medicines;
  final Function(Medicine) onAdd;
  
  MedicineList({required this.medicines, required this.onAdd});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        Medicine med = medicines[index];
        return ListTile(
          title: Text(med.name),
          subtitle: Text("${med.category} | ₹${med.price} | Max: ${med.maxLimit}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (med.requiresPrescription)
                Icon(Icons.medical_services, color: Colors.red, size: 20),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => onAdd(med),
                child: Text("Add"),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CartPage extends StatefulWidget {
  final List<CartItem> cart;
  final Function(CartItem) onRemove;
  
  CartPage({required this.cart, required this.onRemove});
  
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  String selectedOffer = "None";
  double discountPercent = 0;
  
  double getSubtotal() {
    double total = 0;
    for (var item in widget.cart) {
      total += item.medicine.price * item.quantity;
    }
    return total;
  }
  
  double getDiscount() {
    if (selectedOffer == "10% Off") {
      return getSubtotal() * 0.10;
    } else if (selectedOffer == "20% Off on ₹500+") {
      return getSubtotal() >= 500 ? getSubtotal() * 0.20 : 0;
    } else if (selectedOffer == "Flat ₹50 Off") {
      return getSubtotal() >= 300 ? 50 : 0;
    }
    return 0;
  }
  
  double getGST() {
    return (getSubtotal() - getDiscount()) * 0.12; // 12% GST
  }
  
  double getTotal() {
    return getSubtotal() - getDiscount() + getGST();
  }
  
  void generateReceipt() {
    if (widget.cart.isEmpty) {
      showSnackBar("Cart is empty!");
      return;
    }
    
    String receipt = "===== PHARMACY RECEIPT =====\n";
    receipt += "Date: ${DateTime.now()}\n";
    receipt += "===============================\n\n";
    receipt += "ITEMS:\n";
    
    for (var item in widget.cart) {
      receipt += "${item.medicine.name} x${item.quantity} = ₹${item.medicine.price * item.quantity}\n";
      if (item.medicine.requiresPrescription) {
        receipt += "  [Prescription Verified]\n";
      }
    }
    
    receipt += "\n===============================\n";
    receipt += "Subtotal: ₹${getSubtotal().toStringAsFixed(2)}\n";
    receipt += "Discount (${selectedOffer}): -₹${getDiscount().toStringAsFixed(2)}\n";
    receipt += "GST (12%): +₹${getGST().toStringAsFixed(2)}\n";
    receipt += "===============================\n";
    receipt += "TOTAL: ₹${getTotal().toStringAsFixed(2)}\n";
    receipt += "===============================\n";
    receipt += "Thank you for shopping!\n";
    receipt += "Prescriptions are verified.";
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Receipt"),
        content: Container(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(receipt, style: TextStyle(fontFamily: 'monospace')),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }
  
  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (widget.cart.isEmpty) {
      return Center(child: Text("Cart is empty. Add medicines to continue."));
    }
    
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.cart.length,
            itemBuilder: (context, index) {
              CartItem item = widget.cart[index];
              return ListTile(
                title: Text(item.medicine.name),
                subtitle: Text("₹${item.medicine.price} × ${item.quantity} = ₹${item.medicine.price * item.quantity}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (item.medicine.requiresPrescription)
                      Icon(Icons.verified, color: Colors.green, size: 16),
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () => widget.onRemove(item),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        
        // Bill Summary
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey)),
          ),
          child: Column(
            children: [
              // Offer Selection
              Row(
                children: [
                  Text("Select Offer: "),
                  DropdownButton<String>(
                    value: selectedOffer,
                    items: ["None", "10% Off", "20% Off on ₹500+", "Flat ₹50 Off"]
                        .map((offer) => DropdownMenuItem(value: offer, child: Text(offer)))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedOffer = value!;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Subtotal:"),
                  Text("₹${getSubtotal().toStringAsFixed(2)}"),
                ],
              ),
              if (getDiscount() > 0)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Discount:"),
                    Text("-₹${getDiscount().toStringAsFixed(2)}"),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("GST (12%):"),
                  Text("+₹${getGST().toStringAsFixed(2)}"),
                ],
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Total:", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("₹${getTotal().toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: generateReceipt,
                child: Text("Generate Receipt & Checkout"),
                style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 50)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
