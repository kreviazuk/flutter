import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_colors.dart';

class Crystal extends PositionComponent {
  final GameColor gameColor;

  Crystal({
    required this.gameColor,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  @override
  void onLoad() {
    // Render as a diamond shape (rotated square)
    add(RectangleComponent(
      size: size * 0.6,
      position: size / 2,
      anchor: Anchor.center,
      angle: 0.785398, // 45 degrees in radians
      paint: Paint()..color = gameColor.color,
    ));
    
    // Shine effect
    add(CircleComponent(
      radius: size.x * 0.1,
      position: size * 0.4,
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white.withOpacity(0.8),
    ));
  }
}
