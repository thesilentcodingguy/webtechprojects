import 'package:flutter/material.dart';

class AnimatedObject {
  final int id;
  Offset position;
  final AnimationController animationController;
  
  AnimatedObject({
    required this.id,
    required this.position,
    required this.animationController,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimatedObject && other.id == id;
  }
  
  @override
  int get hashCode => id.hashCode;
}
