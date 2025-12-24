import 'dart:math';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../game_colors.dart';
import '../geo_journey_game.dart';

class GameBlock extends PositionComponent with HasGameRef<GeoJourneyGame> {
  final GameColor gameColor;
  final bool isLevelExit;
  
  late int health;
  
  GameBlock({
    required this.gameColor,
    required Vector2 position,
    required Vector2 size,
    this.isLevelExit = false,
  }) : super(position: position, size: size) {
    health = (gameColor == GameColor.brown) ? 5 : 1;
  }

  double fallDelay = 1.0;
  bool _isShaking = false;
  double _shakeTimer = 0;

  @override
  void render(Canvas canvas) {
    if (_isShaking) {
      canvas.save();
      canvas.translate(
         (DateTime.now().millisecond % 5 - 2).toDouble(), 
         (DateTime.now().millisecond % 5 - 2).toDouble()
      );
    }

    final rect = size.toRect();
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    
    // 1. Main Body Gradient (Glossy look)
    Paint bodyPaint;
    
    if (isLevelExit) {
        // Bedrock Style (Grey/Dark)
        bodyPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
               Colors.grey.shade800,
               Colors.grey.shade900,
               Colors.black,
            ],
          ).createShader(rect);
    } else {
        // Normal Gem Style
        bodyPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
               gameColor.color.withOpacity(0.8),
               gameColor.color,
               gameColor.color.withOpacity(0.9),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(rect);
    }

    canvas.drawRRect(rrect, bodyPaint);
    
    // 2. Inner Glow / Edge Highlight (Inset)
    final Path highlightPath = Path()
      ..addRRect(rrect)
      ..addRRect(RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(6)))
      ..fillType = PathFillType.evenOdd;
      
    canvas.drawPath(highlightPath, Paint()..color = Colors.white.withOpacity(0.3));
    
    // 3. Top Gloss (Shininess)
    final Path glossPath = Path();
    glossPath.moveTo(rect.left, rect.top + 10);
    glossPath.quadraticBezierTo(rect.left, rect.top, rect.left + 10, rect.top);
    glossPath.lineTo(rect.right - 10, rect.top);
    glossPath.quadraticBezierTo(rect.right, rect.top, rect.right, rect.top + 10);
    glossPath.lineTo(rect.right, rect.height * 0.4);
    glossPath.quadraticBezierTo(rect.center.dx, rect.height * 0.55, rect.left, rect.height * 0.4);
    glossPath.close();
    
    // Clip gloss to rounded rect
    canvas.save();
    canvas.clipRRect(rrect);
    canvas.drawPath(glossPath, Paint()..color = Colors.white.withOpacity(0.3));
    canvas.restore();

    // 4. Decoration
    if (gameColor == GameColor.brown) {
      _drawNumber(canvas, rect);
    } else {
      _drawMoon(canvas, rect);
    }
    
    if (_isShaking) {
      canvas.restore();
    }
  }
  
  void _drawMoon(Canvas canvas, Rect rect) {
      final center = rect.center;
      final moonSize = rect.width * 0.5;
      
      canvas.save();
      canvas.translate(center.dx, center.dy);
      
      Path moonPath = Path();
      // Outer Circle
      moonPath.addOval(Rect.fromCircle(center: Offset.zero, radius: moonSize * 0.5));
      
      // Inner Circle (Subtraction)
      Path subtractPath = Path();
      subtractPath.addOval(Rect.fromCircle(center: Offset(moonSize * 0.15, -moonSize * 0.1), radius: moonSize * 0.45));
      
      final finalMoon = Path.combine(PathOperation.difference, moonPath, subtractPath);
      
      // Rotate slightly for style
      canvas.rotate(-0.5); 
      
      canvas.drawPath(finalMoon, Paint()..color = Colors.white.withOpacity(0.9));
      
      canvas.restore();
  }

  void startShake(double dt) {
     _isShaking = true;
     fallDelay -= dt;
  }

  void resetShake() {
    _isShaking = false;
    fallDelay = 1.0;
  }

  void _drawNumber(Canvas canvas, Rect rect) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$health',
        style: TextStyle(
          color: Colors.white,
          fontSize: rect.width * 0.3, // Reduce font size further
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    textPainter.layout();
    
    // Draw closer to the top-left edge
    textPainter.paint(
      canvas, 
      const Offset(3, 1), 
    );
  }

  bool hit() {
    health--;
    if (health <= 0) return true;
    return false;
  }
}
