import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Scientific Calculator',
      theme: ThemeData.dark(),
      home: const Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  const Calculator({super.key});

  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator>
    with SingleTickerProviderStateMixin {
  String display = "0";
  String expression = "";
  late AnimationController _controller;

  final Map<String, Color> colors = {
    'sin': Colors.deepPurple,
    'cos': Colors.deepPurple,
    'tan': Colors.deepPurple,
    'log': Colors.deepPurple,
    'ln': Colors.deepPurple,
    '√': Colors.deepPurple,
    'abs': Colors.deepPurple,
    'π': Colors.orange,
    'e': Colors.orange,
    'C': Colors.red,
    '=': Colors.green,
    '^': Colors.teal,
    '+': Colors.cyan,
    '-': Colors.cyan,
    '*': Colors.cyan,
    '/': Colors.cyan,
  };

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void press(String val) {
    setState(() {
      _controller.forward(from: 0);

      if (val == "C") {
        display = "0";
        expression = "";
        return;
      }

      if (val == "=") {
        calculate();
        return;
      }

      switch (val) {
        case "sin":
        case "cos":
        case "tan":
        case "log":
        case "ln":
        case "abs":
          expression += "$val(";
          break;

        case "√":
          expression += "sqrt(";
          break;

        case "π":
          expression += pi.toString();
          break;

        case "e":
          expression += e.toString();
          break;

        default:
          expression += val;
      }

      display = expression;
    });
  }

  void calculate() {
    try {
      String expStr = expression;

      // Replace power a^b → pow(a,b)
      expStr = expStr.replaceAllMapped(
        RegExp(r'(\d+(\.\d+)?)\^(\d+(\.\d+)?)'),
            (m) => 'pow(${m[1]},${m[3]})',
      );

      Parser p = Parser();
      Expression exp = p.parse(expStr);
      ContextModel cm = ContextModel();

      double result = exp.evaluate(EvaluationType.REAL, cm);

      String formatted = (result % 1 == 0)
          ? result.toInt().toString()
          : result
          .toStringAsFixed(8)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');

      display = formatted;
      expression = formatted;
    } catch (e) {
      display = "Error";
      expression = "";
    }
  }

  Widget btn(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Transform.scale(
              scale: 1 - (_controller.value * 0.05),
              child: ElevatedButton(
                onPressed: () => press(text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors[text] ?? Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: text.length > 3 ? 16 : 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget row(List<String> items, {List<int>? flex}) {
    return Row(
      children: List.generate(items.length, (i) {
        return btn(items[i], flex: flex?[i] ?? 1);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey.shade900, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // DISPLAY
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  display,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 48,
                    color: Colors.white,
                  ),
                ),
              ),

              // BUTTONS
              Expanded(
                child: Column(
                  children: [
                    row(["sin", "cos", "tan", "log"]),
                    row(["ln", "√", "abs", "C"]),
                    row(["π", "e", "(", ")"]),
                    row(["7", "8", "9", "/"]),
                    row(["4", "5", "6", "*"]),
                    row(["1", "2", "3", "-"]),
                    row(["0", ".", "^", "+"], flex: [2, 1, 1, 1]),
                    row(["="], flex: [4]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
