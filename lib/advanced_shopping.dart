import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

// ── Models ────────────────────────────────────────────────────────────────────

class Product {
  final String name;
  final String category;
  final double price;
  final double discount; // percentage e.g. 10 = 10%

  const Product(this.name, this.category, this.price, {this.discount = 0});

  double get discountedPrice => price * (1 - discount / 100);
}

const double kGstRate = 5.0; // 5% GST

final List<Product> products = [
  Product("Urad Dal",            "Pulses",     100, discount: 10),
  Product("Boost",               "Beverages",  200, discount: 5),
  Product("Horlicks",            "Beverages",  199),
  Product("Bournvita",           "Beverages",  299, discount: 8),
  Product("Raw Rice",            "Rice",        99, discount: 5),
  Product("Half Boiled Rice",    "Rice",       149),
  Product("Idly Rice",           "Rice",       199, discount: 12),
  Product("Garam Masala 100g",   "Masalas",     50, discount: 15),
  Product("Chicken Masala 100g", "Masalas",     20),
  Product("Milk 250ml",          "Dairy",       50),
  Product("Paneer 250g",         "Dairy",      150, discount: 5),
];

final Map<Product, int> cart = {};

// ── App ───────────────────────────────────────────────────────────────────────

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool loggedIn = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
      ),
      home: loggedIn
          ? HomePage(onLogout: () => setState(() { loggedIn = false; cart.clear(); }))
          : LoginPage(onLogin: () => setState(() => loggedIn = true)),
    );
  }
}

// ── Login ─────────────────────────────────────────────────────────────────────

class LoginPage extends StatefulWidget {
  final VoidCallback onLogin;
  const LoginPage({super.key, required this.onLogin});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _pw = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      body: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: SizedBox(
              width: 320,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_grocery_store, size: 56, color: Colors.green),
                  const SizedBox(height: 12),
                  const Text("Fresh Grocery", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Sign in to continue", style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _pw,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: "Password",
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () { if (_pw.text.isNotEmpty) widget.onLogin(); },
                      child: const Text("Login", style: TextStyle(fontSize: 16)),
                    ),
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

// ── Home ──────────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  final VoidCallback onLogout;
  const HomePage({super.key, required this.onLogout});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _category = "All";
  String _search = "";

  List<String> get categories =>
      ["All", ...products.map((p) => p.category).toSet().toList()];

  int get cartCount => cart.values.fold(0, (s, v) => s + v);

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((p) {
      final catOk = _category == "All" || p.category == _category;
      final searchOk = p.name.toLowerCase().contains(_search.toLowerCase());
      return catOk && searchOk;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fresh Grocery"),
        actions: [
          Stack(children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CartPage()),
              ).then((_) => setState(() {})),
            ),
            if (cartCount > 0)
              Positioned(
                right: 6, top: 6,
                child: CircleAvatar(
                  radius: 9,
                  backgroundColor: Colors.red,
                  child: Text("$cartCount", style: const TextStyle(fontSize: 11, color: Colors.white)),
                ),
              ),
          ]),
          IconButton(icon: const Icon(Icons.logout), onPressed: widget.onLogout),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search products…",
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          // Category chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: categories.map((c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c),
                  selected: _category == c,
                  selectedColor: Colors.green,
                  labelStyle: TextStyle(color: _category == c ? Colors.white : null),
                  onSelected: (_) => setState(() => _category = c),
                ),
              )).toList(),
            ),
          ),
          // Product grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: filtered.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.78,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (_, i) => _ProductCard(
                product: filtered[i],
                onAdd: () => setState(() => cart[filtered[i]] = (cart[filtered[i]] ?? 0) + 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;
  const _ProductCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final inCart = cart[product] ?? 0;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.shopping_bag, size: 40, color: Colors.green),
            ),
            const SizedBox(height: 8),
            Text(product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              maxLines: 2, overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            if (product.discount > 0)
              Text("₹${product.price.toStringAsFixed(0)}",
                style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 11)),
            Text("₹${product.discountedPrice.toStringAsFixed(0)}",
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
            if (product.discount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(color: Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
                child: Text("${product.discount.toInt()}% OFF", style: const TextStyle(fontSize: 10, color: Colors.deepOrange)),
              ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 32,
              child: inCart == 0
                  ? ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: onAdd,
                      child: const Text("Add"),
                    )
                  : Row(children: [
                      _qtyBtn(Icons.remove, () {
                        if (inCart > 1) cart[product] = inCart - 1;
                        else cart.remove(product);
                        (context as Element).markNeedsBuild();
                      }),
                      Expanded(child: Center(child: Text("$inCart", style: const TextStyle(fontWeight: FontWeight.bold)))),
                      _qtyBtn(Icons.add, () { cart[product] = inCart + 1; (context as Element).markNeedsBuild(); }),
                    ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onPressed) => InkWell(
    onTap: onPressed,
    child: Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
      child: Icon(icon, size: 16, color: Colors.white),
    ),
  );
}

// ── Cart ──────────────────────────────────────────────────────────────────────

class CartPage extends StatefulWidget {
  const CartPage({super.key});
  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  double get subtotal => cart.entries.fold(0.0, (s, e) => s + e.key.discountedPrice * e.value);
  double get totalDiscount => cart.entries.fold(0.0, (s, e) => s + (e.key.price - e.key.discountedPrice) * e.value);
  double get gst => subtotal * kGstRate / 100;
  double get grandTotal => subtotal + gst;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Cart")),
      body: cart.isEmpty
          ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.shopping_cart_outlined, size: 72, color: Colors.grey),
              SizedBox(height: 12),
              Text("Your cart is empty", style: TextStyle(color: Colors.grey)),
            ]))
          : Column(children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    ...cart.entries.map((e) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.green.shade50,
                          child: const Icon(Icons.shopping_bag, color: Colors.green)),
                        title: Text(e.key.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (e.key.discount > 0)
                            Text("₹${e.key.price} - ${e.key.discount.toInt()}% off",
                              style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          Text("₹${e.key.discountedPrice.toStringAsFixed(0)} × ${e.value} = "
                              "₹${(e.key.discountedPrice * e.value).toStringAsFixed(0)}",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                        ]),
                        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                          _iconBtn(Icons.remove, () => setState(() {
                            if (e.value > 1) cart[e.key] = e.value - 1; else cart.remove(e.key);
                          })),
                          Text("${e.value}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          _iconBtn(Icons.add, () => setState(() => cart[e.key] = e.value + 1)),
                        ]),
                      ),
                    )),
                    // Summary card
                    const SizedBox(height: 8),
                    _SummaryCard(subtotal: subtotal, discount: totalDiscount, gst: gst, total: grandTotal),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      final snapshot = Map<Product, int>.from(cart);
                      cart.clear();
                      Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => ReceiptPage(
                          items: snapshot,
                          subtotal: subtotal,
                          discount: totalDiscount,
                          gst: gst,
                          total: grandTotal,
                        )));
                    },
                    child: Text("Pay ₹${grandTotal.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ]),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) => IconButton(
    icon: Icon(icon, size: 18),
    padding: const EdgeInsets.all(4),
    constraints: const BoxConstraints(),
    onPressed: onTap,
  );
}

class _SummaryCard extends StatelessWidget {
  final double subtotal, discount, gst, total;
  const _SummaryCard({required this.subtotal, required this.discount, required this.gst, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text("Order Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const Divider(height: 20),
          _row("Subtotal (MRP)", "₹${(subtotal + discount).toStringAsFixed(2)}"),
          _row("Discount", "- ₹${discount.toStringAsFixed(2)}", color: Colors.green),
          _row("GST (${kGstRate.toInt()}%)", "+ ₹${gst.toStringAsFixed(2)}", color: Colors.orange.shade800),
          const Divider(height: 16),
          _row("Grand Total", "₹${total.toStringAsFixed(2)}", bold: true, size: 16),
        ]),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color, bool bold = false, double size = 14}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: size, color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
}

// ── Receipt ───────────────────────────────────────────────────────────────────

class ReceiptPage extends StatelessWidget {
  final Map<Product, int> items;
  final double subtotal, discount, gst, total;

  const ReceiptPage({super.key, required this.items,
      required this.subtotal, required this.discount, required this.gst, required this.total});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Scaffold(
      appBar: AppBar(title: const Text("Receipt")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              const Icon(Icons.check_circle, size: 60, color: Colors.green),
              const SizedBox(height: 8),
              const Text("Order Confirmed!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text("${now.day}/${now.month}/${now.year} ${now.hour}:${now.minute.toString().padLeft(2,'0')}",
                style: const TextStyle(color: Colors.grey)),
              const Divider(height: 24),
              // Items
              ...items.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.key.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text("₹${e.key.discountedPrice.toStringAsFixed(0)} × ${e.value}",
                      style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ])),
                  Text("₹${(e.key.discountedPrice * e.value).toStringAsFixed(2)}",
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                ]),
              )),
              const Divider(height: 24),
              _row("Subtotal (MRP)", "₹${(subtotal + discount).toStringAsFixed(2)}"),
              _row("Discount", "- ₹${discount.toStringAsFixed(2)}", color: Colors.green),
              _row("GST (${kGstRate.toInt()}%)", "+ ₹${gst.toStringAsFixed(2)}", color: Colors.orange.shade800),
              const Divider(height: 12),
              _row("Total Paid", "₹${total.toStringAsFixed(2)}", bold: true, size: 17),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.local_shipping, color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text("Delivery in 30–45 minutes", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
                ]),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.home),
                  label: const Text("Back to Home"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pushAndRemoveUntil(context,
                    MaterialPageRoute(builder: (_) => const MyApp()), (r) => false),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value, {Color? color, bool bold = false, double size = 14}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: size, fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: size, color: color,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      ]),
    );
}
