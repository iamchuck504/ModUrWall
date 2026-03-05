import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class WallpaperBackground extends StatefulWidget {
  final AppTheme theme;

  const WallpaperBackground({super.key, required this.theme});

  @override
  State<WallpaperBackground> createState() => _WallpaperBackgroundState();
}

class _WallpaperBackgroundState extends State<WallpaperBackground>
    with SingleTickerProviderStateMixin {
  final List<SquareData> squares = [];
  Timer? autoWaveTimer;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    )..repeat();

    scheduleAutoWave();
  }

  @override
  void dispose() {
    _controller.dispose();
    autoWaveTimer?.cancel();
    super.dispose();
  }

  void scheduleAutoWave() {
    final delay = 3000 + Random().nextInt(4000);
    autoWaveTimer = Timer(Duration(milliseconds: delay), () {
      createAutoWave();
      scheduleAutoWave();
    });
  }

  void createAutoWave() {
    if (!mounted) return;
    final size = MediaQuery.of(context).size;
    final cols = (size.width / 55).ceil();
    final rows = (size.height / 55).ceil();
    Random().nextInt(cols);
    Random().nextInt(rows);

    setState(() {
      // Trigger wave animation
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: WallpaperPainter(
        theme: widget.theme,
        animation: _controller,
      ),
    );
  }
}

class SquareData {
  final int col;
  final int row;
  double scale;
  double brightness;
  Color currentColor;

  SquareData({
    required this.col,
    required this.row,
    this.scale = 1.0,
    this.brightness = 0.0,
    required this.currentColor,
  });
}

class WallpaperPainter extends CustomPainter {
  final AppTheme theme;
  final Animation<double> animation;

  WallpaperPainter({required this.theme, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = theme.bg;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    const squareSize = 50.0;
    const gap = 5.0;
    final cols = (size.width / (squareSize + gap)).ceil();
    final rows = (size.height / (squareSize + gap)).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = col * (squareSize + gap);
        final y = row * (squareSize + gap);

        final squarePaint = Paint()
          ..color = theme.bg
          ..style = PaintingStyle.fill;

        final rect = Rect.fromLTWH(x, y, squareSize, squareSize);
        canvas.drawRect(rect, squarePaint);

        final borderPaint = Paint()
          ..color = theme.accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(WallpaperPainter oldDelegate) {
    return oldDelegate.theme != theme;
  }
}
