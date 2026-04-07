import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Colorful Scientific Calculator',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> with SingleTickerProviderStateMixin {
  String display = "0";
  String expression = "";
  late AnimationController _animationController;

  final Map<String, Color> buttonColors = {
    'sin': Colors.deepPurple,
    'cos': Colors.deepPurple,
    'tan': Colors.deepPurple,
    'log': Colors.deepPurple,
    'ln': Colors.deepPurple,
    '√': Colors.deepPurple,
    'abs': Colors.deepPurple,
    'π': Colors.orange,
    'e': Colors.orange,
    '(': Colors.blueGrey,
    ')': Colors.blueGrey,
    'C': Colors.red,
    '=': Colors.green,
    '^': Colors.teal,
    '+': Colors.cyan,
    '-': Colors.cyan,
    '*': Colors.cyan,
    '/': Colors.cyan,
    '.': Colors.white70,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void buttonPressed(String value) {
    setState(() {
      _animationController.forward(from: 0.0);

      if (value == "C") {
        display = "0";
        expression = "";
      }
      else if (value == "=") {
        try {
          String toEval = expression;
          toEval = toEval.replaceAll('×', '*');
          toEval = toEval.replaceAll('÷', '/');
          toEval = toEval.replaceAll('π', pi.toString());
          toEval = toEval.replaceAll('e', e.toString());

          // IMPORTANT: use Parser
          Parser p = Parser();
          Expression exp = p.parse(toEval);

          ContextModel cm = ContextModel();
          double result = exp.evaluate(EvaluationType.REAL, cm);

          if (result == result.toInt()) {
            display = result.toInt().toString();
            expression = display;
          } else {
            display = result
                .toStringAsFixed(8)
                .replaceAll(RegExp(r'0+$'), '')
                .replaceAll(RegExp(r'\.$'), '');
            expression = display;
          }
        } catch (e) {
          display = "Error";
          expression = "";
        }
      }
      else if (value == "sin") {
        expression += "sin(";
        display = expression;
      }
      else if (value == "cos") {
        expression += "cos(";
        display = expression;
      }
      else if (value == "tan") {
        expression += "tan(";
        display = expression;
      }
      else if (value == "log") {
        expression += "log(";
        display = expression;
      }
      else if (value == "ln") {
        expression += "ln(";
        display = expression;
      }
      else if (value == "√") {
        expression += "sqrt(";
        display = expression;
      }
      else if (value == "^") {
        expression += "^";
        display = expression;
      }
      else if (value == "π") {
        expression += "π";
        display = expression;
      }
      else if (value == "e") {
        expression += "e";
        display = expression;
      }
      else if (value == "abs") {
        expression += "abs(";
        display = expression;
      }
      else if (value == "(") {
        expression += "(";
        display = expression;
      }
      else if (value == ")") {
        expression += ")";
        display = expression;
      }
      else {
        expression += value;
        display = expression;
      }
    });
  }

  Widget _buildButton(String text, {double flex = 1}) {
    Color buttonColor = buttonColors[text] ?? Colors.blue;
    Color textColor = Colors.white;

    if (text == 'C') textColor = Colors.white;
    if (text == '=') textColor = Colors.white;

    return Expanded(
      flex: flex.toInt(),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 - (_animationController.value * 0.05),
              child: ElevatedButton(
                onPressed: () => buttonPressed(text),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: textColor,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                  shadowColor: buttonColor.withOpacity(0.5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Display Area
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      display,
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (expression.isNotEmpty && display != expression)
                      Text(
                        expression,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white.withOpacity(0.5),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),

              // Buttons Grid
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      // Row 1: Scientific functions
                      Row(
                        children: [
                          _buildButton("sin"),
                          _buildButton("cos"),
                          _buildButton("tan"),
                          _buildButton("log"),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Row 2: More scientific
                      Row(
                        children: [
                          _buildButton("ln"),
                          _buildButton("√"),
                          _buildButton("abs"),
                          _buildButton("C"),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Row 3: Constants and brackets
                      Row(
                        children: [
                          _buildButton("π"),
                          _buildButton("e"),
                          _buildButton("("),
                          _buildButton(")"),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Row 4: Numbers 7-9 and operators
                      Row(
                        children: [
                          _buildButton("7"),
                          _buildButton("8"),
                          _buildButton("9"),
                          _buildButton("/"),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Row 5: Numbers 4-6
                      Row(
                        children: [
                          _buildButton("4"),
                          _buildButton("5"),
                          _buildButton("6"),
                          _buildButton("*"),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Row 6: Numbers 1-3
                      Row(
                        children: [
                          _buildButton("1"),
                          _buildButton("2"),
                          _buildButton("3"),
                          _buildButton("-"),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Row 7: Numbers 0 and operators
                      Row(
                        children: [
                          _buildButton("0", flex: 2),
                          _buildButton("."),
                          _buildButton("^"),
                          _buildButton("+"),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Row 8: Equals
                      Row(
                        children: [
                          _buildButton("=", flex: 4),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
