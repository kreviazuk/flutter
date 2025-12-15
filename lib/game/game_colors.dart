import 'dart:ui';

enum GameColor {
  red(Color(0xFFFF0000)),
  green(Color(0xFF00FF00)),
  blue(Color(0xFF0000FF)),
  yellow(Color(0xFFFFFF00)),
  purple(Color(0xFF800080));

  final Color color;
  const GameColor(this.color);
}
