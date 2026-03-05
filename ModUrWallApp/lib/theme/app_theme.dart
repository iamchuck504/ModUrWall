import 'package:flutter/material.dart';

class AppTheme {
  final Color bg;
  final Color fg;
  final Color accent;
  final Color dim;
  final Color darker;

  const AppTheme({
    required this.bg,
    required this.fg,
    required this.accent,
    required this.dim,
    required this.darker,
  });

  static const dark = AppTheme(
    bg: Color(0xFF0a0e1a),
    fg: Color(0xFFe0e8ff),
    accent: Color(0xFF0088ff),
    dim: Color(0xFF4a5a7a),
    darker: Color(0xFF050810),
  );

  static const cyan = AppTheme(
    bg: Color(0xFF1a3a3a),
    fg: Color(0xFFe0f5f5),
    accent: Color(0xFF4db8b8),
    dim: Color(0xFF2d5555),
    darker: Color(0xFF0f2020),
  );

  static const yellow = AppTheme(
    bg: Color(0xFF3a3a1a),
    fg: Color(0xFFf5f5e0),
    accent: Color(0xFFb8b84d),
    dim: Color(0xFF555520),
    darker: Color(0xFF202010),
  );

  static const magenta = AppTheme(
    bg: Color(0xFF3a1a3a),
    fg: Color(0xFFf5e0f5),
    accent: Color(0xFFb84db8),
    dim: Color(0xFF552055),
    darker: Color(0xFF201020),
  );

  static const orange = AppTheme(
    bg: Color(0xFF3a2a1a),
    fg: Color(0xFFf5ebe0),
    accent: Color(0xFFb8824d),
    dim: Color(0xFF554520),
    darker: Color(0xFF201810),
  );

  static const blue = AppTheme(
    bg: Color(0xFF1a1a3a),
    fg: Color(0xFFe0e0f5),
    accent: Color(0xFF4d4db8),
    dim: Color(0xFF202055),
    darker: Color(0xFF101020),
  );

  static const green = AppTheme(
    bg: Color(0xFF1a3a1a),
    fg: Color(0xFFe0f5e0),
    accent: Color(0xFF4db84d),
    dim: Color(0xFF205520),
    darker: Color(0xFF102010),
  );

  static const red = AppTheme(
    bg: Color(0xFF3a1a1a),
    fg: Color(0xFFf5e0e0),
    accent: Color(0xFFb84d4d),
    dim: Color(0xFF552020),
    darker: Color(0xFF201010),
  );

  static const light = AppTheme(
    bg: Color(0xFFf5f5f5),
    fg: Color(0xFF1a1a1a),
    accent: Color(0xFF0066cc),
    dim: Color(0xFF888888),
    darker: Color(0xFFe0e0e0),
  );

  static const themes = [cyan, yellow, magenta, orange, blue, green, red];
}
