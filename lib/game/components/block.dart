import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_colors.dart';

class GameBlock extends PositionComponent {
  final GameColor gameColor;
  
  GameBlock({
    required this.gameColor,
    required Vector2 position,
    required Vector2 size,
  }) : super(position: position, size: size);

  double fallDelay = 0.5;
  final Vector2 _originalPosition = Vector2.zero();
  bool _isShaking = false;
  double _shakeTimer = 0;

  @override
  void onLoad() {
    // For now, render as a simple colored rectangle
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = gameColor.color,
    ));
    // Add a border to distinguish blocks
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    ));
    // Save original relative position (usually 0,0 locally, but we modify 'position' property of component)
    // Wait, position is managed by GridManager. We should apply shake as an offset NOT to position directly?
    // Actually, GridManager sets .position.
    // If we modify .position here, GridManager might overwrite it or get confused.
    // Better: Add a child for visuals and offset THAT, or modify anchor?
    // Easiest: Add a child wrapper for the rectangle and shake that.
    // Or just jitter position slightly, GridManager sets it every frame?
    // GridManager set position in _moveBlock. If block is stationary waiting to fall, _moveBlock is NOT called.
    // So we can modify position safely as long as we reset it before moving.
  }

  void startShake(double dt) {
     _isShaking = true;
     fallDelay -= dt;
     
     // Visual Shake
     // Random offset +/- 2 pixels
     // We need to store base position if we modify 'position'.
     // But GridManager expects 'position' to be grid-aligned.
     // Let's modify the *children's* position? Or adding a transform?
     // Let's just modify the children (rectangles).
     for (final child in children) {
       if (child is PositionComponent) {
          child.position = Vector2(
             (DateTime.now().millisecond % 5 - 2).toDouble(), 
             (DateTime.now().millisecond % 5 - 2).toDouble()
          );
       }
     }
  }

  void resetShake() {
    _isShaking = false;
    fallDelay = 0.5;
    
    // Reset children
     for (final child in children) {
       if (child is PositionComponent) {
          child.position = Vector2.zero();
       }
     }
  }
}
