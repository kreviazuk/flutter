import 'dart:ui';

enum GameColor {
  red(Color(0xFFFF0000)),
  orange(Color(0xFFFFA500)),
  yellow(Color(0xFFFFFF00)),
  green(Color(0xFF00FF00)),
  cyan(Color(0xFF00FFFF)),
  blue(Color(0xFF0000FF)),
  purple(Color(0xFF800080)),
  brown(Color(0xFF8B4513));

  final Color color;
  const GameColor(this.color);
}
