import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_colors.dart';

enum CrystalType {
  normal,
  heart,
  verticalDrill, // Clears below
  aoeBlast, // Clears around
}

class Crystal extends PositionComponent {
  final GameColor gameColor;
  final CrystalType type;

  late int health;
  
  Crystal({
    required this.gameColor,
    required Vector2 position,
    required Vector2 size,
    this.type = CrystalType.normal,
  }) : super(position: position, size: size) {
     health = maxHealth;
  }
  
  int get maxHealth => (gameColor == GameColor.brown) ? 5 : 1;

  double fallDelay = 1.0; // Same as block now
  bool _isShaking = false;

  @override
  void render(Canvas canvas) {
    if (_isShaking) {
      canvas.save();
      canvas.translate(
         (DateTime.now().millisecond % 5 - 2).toDouble(), 
         (DateTime.now().millisecond % 5 - 2).toDouble()
      );
    }
    
    // Draw body for brown crystals (manual style like block)
    if (gameColor == GameColor.brown) {
       final rect = size.toRect();
       final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
       final bodyPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
               gameColor.color.withOpacity(0.8),
               gameColor.color,
               gameColor.color.withOpacity(0.9),
            ],
          ).createShader(rect);
       canvas.drawRRect(rrect, bodyPaint);
       _drawNumber(canvas, rect);
    }
    
    super.render(canvas);
    if (_isShaking) {
      canvas.restore();
    }
  }

  void _drawNumber(Canvas canvas, Rect rect) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$health',
        style: TextStyle(
          color: Colors.white,
          fontSize: rect.width * 0.4, // Match block style
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    // Position at Top-Left corner
    textPainter.paint(
      canvas, 
      rect.topLeft + const Offset(4, 2),
    );
  }

  bool hit() {
    health--;
    if (health <= 0) return true;
    return false;
  }

  void startShake(double dt) {
     _isShaking = true;
     fallDelay -= dt;
  }

  void resetShake() {
    _isShaking = false;
    fallDelay = 1.0;
  }
  // Helper for backward compatibility or simple checks
  bool get isHeart => type == CrystalType.heart;

  @override
  void onLoad() {
    switch (type) {
      case CrystalType.heart:
        _drawHeart();
        break;
      case CrystalType.verticalDrill:
        _drawDrill();
        break;
      case CrystalType.aoeBlast:
        _drawBlast();
        break;
      case CrystalType.normal:
      default:
        _drawNormal();
        break;
    }
  }

  void _drawHeart() {
      // Red Heart / Ellipse - Scaled down
      add(CircleComponent(
        radius: size.x * 0.25,
        position: size / 2,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.redAccent,
      ));
      
      add(CircleComponent(
        radius: size.x * 0.08,
        position: Vector2(size.x * 0.4, size.y * 0.4),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.white.withOpacity(0.6),
      ));
      
      (children.first as PositionComponent).scale = Vector2(1.0, 0.8);
  }

  void _drawDrill() {
      // Downwards Arrow/Drill shape (White/Silver) - Center and scale
      const double scale = 0.7;
      add(PolygonComponent(
        [
          Vector2(size.x * 0.5, size.y * 0.8 * scale + (size.y * (1-scale)/2)), // Tip
          Vector2(size.x * 0.3, size.y * 0.3 * scale + (size.y * (1-scale)/2)), // Top Left
          Vector2(size.x * 0.7, size.y * 0.3 * scale + (size.y * (1-scale)/2)), // Top Right
        ],
        paint: Paint()..color = Colors.white,
      ));
      add(RectangleComponent(
        size: Vector2(size.x * 0.15, size.y * 0.3),
        position: Vector2(size.x * 0.5, size.y * 0.35),
        anchor: Anchor.bottomCenter,
        paint: Paint()..color = Colors.blueGrey,
      ));
  }

  void _drawBlast() {
      // Star shape (Gold) - Ensure it stays within bounds
      add(CircleComponent(
        radius: size.x * 0.2,
        position: size / 2,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.amber,
      ));
      // Outer rays - Shortened to stay inside
      for (int i = 0; i < 8; i++) {
        add(RectangleComponent(
          size: Vector2(size.x * 0.08, size.y * 0.35),
          position: size / 2,
          anchor: Anchor.center,
          angle: (3.14159 / 4) * i,
          paint: Paint()..color = Colors.amberAccent,
        ));
      }
  }

  void _drawNormal() {
      if (gameColor == GameColor.brown) return; // Handled in render

      add(RectangleComponent(
        size: size * 0.5,
        position: size / 2,
        anchor: Anchor.center,
        angle: 0.785398, // 45 degrees
        paint: Paint()..color = gameColor.color,
      ));
      
      add(CircleComponent(
        radius: size.x * 0.08,
        position: size * 0.42,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.white.withOpacity(0.8),
      ));
  }
}
