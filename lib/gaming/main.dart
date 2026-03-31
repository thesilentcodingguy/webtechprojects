import 'package:flutter/material.dart';
import 'game_screen.dart';

void main() {
  runApp(const MyGameApp());
}

class MyGameApp extends StatelessWidget {
  const MyGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gesture Catcher Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
