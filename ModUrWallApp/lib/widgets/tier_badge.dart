import 'package:flutter/material.dart';
import '../models/wallpaper.dart';

class TierBadge extends StatelessWidget {
  final WallpaperTier tier;

  const TierBadge({super.key, required this.tier});

  @override
  Widget build(BuildContext context) {
    final isFree = tier == WallpaperTier.free;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isFree
            ? Colors.green.withValues(alpha: 0.85)
            : Colors.amber.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isFree ? 'FREE' : 'Lempyrλ ✦',
        style: TextStyle(
          color: isFree ? Colors.white : Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
