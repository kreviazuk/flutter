import 'package:flutter/material.dart';

class WorldMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint();

    // 1. Ocean Background
    final Rect rect = Rect.fromLTWH(0, 0, w, h);
    final Gradient gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Colors.blue[900]!, Colors.blue[500]!],
    );
    paint.shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    paint.shader = null; // Reset shader

    // 2. Grid Lines (Latitude / Longitude)
    paint.color = Colors.white.withOpacity(0.1);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;

    // Longitude
    for (int i = 1; i < 12; i++) {
       double x = w * (i / 12);
       canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
    }
    // Latitude
    for (int i = 1; i < 6; i++) {
       double y = h * (i / 6);
       canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }

    // 3. Continents
    paint.color = const Color(0xFF4CAF50); // Land Green
    paint.style = PaintingStyle.fill;
    
    // Americas
    Path americas = Path();
    americas.moveTo(w * 0.15, h * 0.15); // Alaska
    americas.lineTo(w * 0.28, h * 0.15); // Canada East
    americas.lineTo(w * 0.25, h * 0.35); // Florida/Mexico
    americas.lineTo(w * 0.30, h * 0.45); // Central America
    americas.lineTo(w * 0.35, h * 0.50); // Brazil bump
    americas.lineTo(w * 0.32, h * 0.75); // Argentina tip
    americas.lineTo(w * 0.25, h * 0.70); // Chile
    americas.lineTo(w * 0.20, h * 0.50); // Peru
    americas.lineTo(w * 0.15, h * 0.40); // Mexico West
    americas.close();
    canvas.drawPath(americas, paint);

    // Europe & Asia
    Path eurasia = Path();
    eurasia.moveTo(w * 0.45, h * 0.20); // Europe West
    eurasia.lineTo(w * 0.55, h * 0.15); // Europe North
    eurasia.lineTo(w * 0.85, h * 0.15); // Siberia
    eurasia.lineTo(w * 0.90, h * 0.30); // Japan/Korea area
    eurasia.lineTo(w * 0.80, h * 0.45); // SE Asia
    eurasia.lineTo(w * 0.70, h * 0.45); // India
    eurasia.lineTo(w * 0.60, h * 0.40); // Middle East
    eurasia.lineTo(w * 0.55, h * 0.35); // Turkey/Med
    eurasia.lineTo(w * 0.45, h * 0.30); // Spain
    eurasia.close();
    canvas.drawPath(eurasia, paint);

    // Africa
    Path africa = Path();
    africa.moveTo(w * 0.45, h * 0.35); // NW Africa
    africa.lineTo(w * 0.60, h * 0.35); // NE Africa
    africa.lineTo(w * 0.65, h * 0.50); // Horn
    africa.lineTo(w * 0.55, h * 0.70); // South Africa
    africa.lineTo(w * 0.45, h * 0.55); // West Africa bulge
    africa.close();
    canvas.drawPath(africa, paint);

    // Australia
    Path australia = Path();
    australia.moveTo(w * 0.75, h * 0.60);
    australia.lineTo(w * 0.88, h * 0.60);
    australia.lineTo(w * 0.85, h * 0.75);
    australia.lineTo(w * 0.78, h * 0.72);
    australia.close();
    canvas.drawPath(australia, paint);

    // Antarctica
    Path antarctica = Path();
    antarctica.moveTo(w * 0.20, h * 0.90);
    antarctica.lineTo(w * 0.80, h * 0.90);
    antarctica.lineTo(w * 0.75, h * 0.98);
    antarctica.lineTo(w * 0.25, h * 0.98);
    antarctica.close();
    paint.color = Colors.white; // Ice
    canvas.drawPath(antarctica, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
