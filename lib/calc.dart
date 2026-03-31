import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Calculator(),
    );
  }
}

class Calculator extends StatefulWidget {
  @override
  State<Calculator> createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  String display = "0";
  String expression = "";
  
  void buttonPressed(String value) {
    setState(() {
      if (value == "C") {
        display = "0";
        expression = "";
      }
      else if (value == "=") {
        try {
          String toEval = expression;
          toEval = toEval.replaceAll('×', '*');
          toEval = toEval.replaceAll('÷', '/');
          toEval = toEval.replaceAll('^', '**');
          toEval = toEval.replaceAll('π', pi.toString());
          toEval = toEval.replaceAll('e', e.toString());
          
          double result = evaluateExpression(toEval);
          display = result.toString();
          expression = result.toString();
        } catch(e) {
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
  
  double evaluateExpression(String exp) {
    // Handle functions
    exp = exp.replaceAllMapped(RegExp(r'sin\(([^)]+)\)'), (match) {
      double val = evaluateExpression(match.group(1)!);
      return sin(val).toString();
    });
    
    exp = exp.replaceAllMapped(RegExp(r'cos\(([^)]+)\)'), (match) {
      double val = evaluateExpression(match.group(1)!);
      return cos(val).toString();
    });
    
    exp = exp.replaceAllMapped(RegExp(r'tan\(([^)]+)\)'), (match) {
      double val = evaluateExpression(match.group(1)!);
      return tan(val).toString();
    });
    
    exp = exp.replaceAllMapped(RegExp(r'log\(([^)]+)\)'), (match) {
      double val = evaluateExpression(match.group(1)!);
      return log(val).toString();
    });
    
    exp = exp.replaceAllMapped(RegExp(r'ln\(([^)]+)\)'), (match) {
      double val = evaluateExpression(match.group(1)!);
      return log(val).toString();
    });
    
    exp = exp.replaceAllMapped(RegExp(r'sqrt\(([^)]+)\)'), (match) {
      double val = evaluateExpression(match.group(1)!);
      return sqrt(val).toString();
    });
    
    exp = exp.replaceAllMapped(RegExp(r'abs\(([^)]+)\)'), (match) {
      double val = evaluateExpression(match.group(1)!);
      return val.abs().toString();
    });
    
    // Basic arithmetic
    List<String> tokens = exp.split(RegExp(r'(?<=[0-9)])(?=[+\-*/])|(?<=[+\-*/])(?=[0-9(])'));
    
    // Simple evaluation for basic operations
    if (exp.contains('+')) {
      List<String> parts = exp.split('+');
      double result = evaluateExpression(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        result += evaluateExpression(parts[i]);
      }
      return result;
    }
    else if (exp.contains('-') && !exp.startsWith('-')) {
      List<String> parts = exp.split('-');
      double result = evaluateExpression(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        result -= evaluateExpression(parts[i]);
      }
      return result;
    }
    else if (exp.contains('*')) {
      List<String> parts = exp.split('*');
      double result = evaluateExpression(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        result *= evaluateExpression(parts[i]);
      }
      return result;
    }
    else if (exp.contains('/')) {
      List<String> parts = exp.split('/');
      double result = evaluateExpression(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        result /= evaluateExpression(parts[i]);
      }
      return result;
    }
    else if (exp.contains('**')) {
      List<String> parts = exp.split('**');
      double result = evaluateExpression(parts[0]);
      for (int i = 1; i < parts.length; i++) {
        result = pow(result, evaluateExpression(parts[i])).toDouble();
      }
      return result;
    }
    
    return double.parse(exp);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(display, style: TextStyle(fontSize: 40)),
                ],
              ),
            ),
          ),
          // Row 1: Scientific functions
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("sin"), child: Text("sin"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("cos"), child: Text("cos"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("tan"), child: Text("tan"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("log"), child: Text("log"))),
            ],
          ),
          // Row 2: More scientific
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("ln"), child: Text("ln"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("√"), child: Text("√"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("abs"), child: Text("abs"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("C"), child: Text("C"))),
            ],
          ),
          // Row 3: Constants and brackets
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("π"), child: Text("π"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("e"), child: Text("e"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("("), child: Text("("))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed(")"), child: Text(")"))),
            ],
          ),
          // Row 4: Numbers 7-9 and operators
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("7"), child: Text("7"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("8"), child: Text("8"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("9"), child: Text("9"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("/"), child: Text("/"))),
            ],
          ),
          // Row 5: Numbers 4-6
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("4"), child: Text("4"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("5"), child: Text("5"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("6"), child: Text("6"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("*"), child: Text("*"))),
            ],
          ),
          // Row 6: Numbers 1-3
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("1"), child: Text("1"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("2"), child: Text("2"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("3"), child: Text("3"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("-"), child: Text("-"))),
            ],
          ),
          // Row 7: Numbers 0 and operators
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("0"), child: Text("0"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("."), child: Text("."))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("^"), child: Text("^"))),
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("+"), child: Text("+"))),
            ],
          ),
          // Row 8: Equals
          Row(
            children: [
              Expanded(child: ElevatedButton(onPressed: () => buttonPressed("="), child: Text("="))),
            ],
          ),
        ],
      ),
    );
  }
}
