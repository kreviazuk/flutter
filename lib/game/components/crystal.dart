import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_colors.dart';

class Crystal extends PositionComponent {
  final GameColor gameColor;
  final bool isHeart; // New special type

  Crystal({
    required this.gameColor,
    required Vector2 position,
    required Vector2 size,
    this.isHeart = false,
  }) : super(position: position, size: size);

  @override
  void onLoad() {
    if (isHeart) {
        // Red Heart / Ellipse
        add(CircleComponent(
          radius: size.x * 0.35, // Adjust width
          position: size / 2,
          anchor: Anchor.center,
          paint: Paint()..color = Colors.redAccent,
        ));
        
        // Add a highlight
         add(CircleComponent(
          radius: size.x * 0.1,
          position: Vector2(size.x * 0.35, size.y * 0.35),
          anchor: Anchor.center,
          paint: Paint()..color = Colors.white.withOpacity(0.6),
        ));
        
        // Scale Y to make it an ellipse? 
        // CircleComponent draws a circle. To make an ellipse, scale the component.
        (children.first as PositionComponent).scale = Vector2(1.0, 0.8);

    } else {
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
}
