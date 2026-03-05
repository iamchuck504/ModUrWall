import 'package:flutter/material.dart';
import '../models/wallpaper.dart';
import '../services/wallpaper_service.dart';
import '../widgets/tier_badge.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WallpaperService _service = MockWallpaperService();
  final TextEditingController _promptController = TextEditingController();
  List<WallpaperModel> _wallpapers = [];
  bool _isLoading = true;

  static const _bg = Color(0xFF0a0e1a);
  static const _fg = Color(0xFFe0e8ff);
  static const _accent = Color(0xFF0088ff);
  static const _dim = Color(0xFF4a5a7a);
  static const _darker = Color(0xFF050810);

  @override
  void initState() {
    super.initState();
    _loadWallpapers();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<void> _loadWallpapers() async {
    final wallpapers = await _service.getWallpapers();
    setState(() {
      _wallpapers = wallpapers;
      _isLoading = false;
    });
  }

  void _showUpgradeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _darker,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        side: BorderSide(color: _accent, width: 1),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Lempyrλ ✦',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Courier',
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: _dim),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Unlock premium wallpapers and AI generation powered by Lempyrλ infrastructure.',
              style: TextStyle(
                color: _fg,
                fontSize: 15,
                height: 1.5,
                fontFamily: 'Courier',
              ),
            ),
            const SizedBox(height: 24),
            const _UpgradeStat(label: 'Generations/day', free: '10', premium: 'Unlimited'),
            const SizedBox(height: 12),
            const _UpgradeStat(label: 'Premium gallery', free: '—', premium: '✦ Full access'),
            const SizedBox(height: 12),
            const _UpgradeStat(label: 'Resolution', free: '1080p', premium: '4K'),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Upgrade flow — coming soon!'),
                      backgroundColor: _darker,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.amber, width: 2),
                  foregroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('UPGRADE TO LEMPYRΛ'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'ModUrWall',
                    style: TextStyle(
                      color: _accent,
                      fontSize: 28,
                      fontWeight: FontWeight.w300,
                      letterSpacing: -1,
                      fontFamily: 'Courier',
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showUpgradeSheet(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: _dim, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'FREE TIER',
                            style: TextStyle(
                              color: _dim,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              fontFamily: 'Courier',
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down,
                              color: _dim, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Gallery grid ─────────────────────────────────────────
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _accent),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemCount: _wallpapers.length,
                      itemBuilder: (context, index) {
                        return _WallpaperCard(
                          wallpaper: _wallpapers[index],
                          onPremiumTap: () => _showUpgradeSheet(context),
                        );
                      },
                    ),
            ),

            // ── Prompt bar ───────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: _darker,
                border: Border(top: BorderSide(color: _dim, width: 1)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _promptController,
                          style: const TextStyle(
                              color: _fg,
                              fontFamily: 'Courier',
                              fontSize: 14),
                          decoration: InputDecoration(
                            hintText: 'Describe your wallpaper…',
                            hintStyle: const TextStyle(
                                color: _dim, fontFamily: 'Courier'),
                            filled: true,
                            fillColor: _bg,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: _dim, width: 1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: _dim, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide:
                                  const BorderSide(color: _accent, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('AI generation — coming soon!'),
                              backgroundColor: _darker,
                            ),
                          );
                        },
                        icon: const Icon(Icons.send_rounded, color: _accent),
                        style: IconButton.styleFrom(
                          backgroundColor: _bg,
                          side: const BorderSide(color: _accent, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/creator'),
                    icon: const Icon(Icons.palette_outlined,
                        color: _dim, size: 16),
                    label: const Text(
                      'CREATOR CONSOLE',
                      style: TextStyle(
                        color: _dim,
                        fontSize: 11,
                        fontFamily: 'Courier',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Wallpaper card ────────────────────────────────────────────────────────────

class _WallpaperCard extends StatelessWidget {
  final WallpaperModel wallpaper;
  final VoidCallback onPremiumTap;

  const _WallpaperCard({
    required this.wallpaper,
    required this.onPremiumTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPremium = wallpaper.tier == WallpaperTier.premium;

    return GestureDetector(
      onTap: isPremium ? onPremiumTap : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail
            Opacity(
              opacity: isPremium ? 0.35 : 1.0,
              child: Image.asset(
                wallpaper.assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFF0d1220),
                  child: const Center(
                    child: Icon(Icons.image_not_supported_outlined,
                        color: Color(0xFF4a5a7a), size: 32),
                  ),
                ),
              ),
            ),

            // Premium lock overlay
            if (isPremium)
              const Center(
                child: Icon(
                  Icons.lock_rounded,
                  color: Colors.white54,
                  size: 36,
                ),
              ),

            // Tier badge — bottom left
            Positioned(
              bottom: 8,
              left: 8,
              child: TierBadge(tier: wallpaper.tier),
            ),

            // Title — bottom right (subtle)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  wallpaper.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                    fontFamily: 'Courier',
                    shadows: [
                      Shadow(color: Colors.black, blurRadius: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Upgrade stat row ──────────────────────────────────────────────────────────

class _UpgradeStat extends StatelessWidget {
  final String label;
  final String free;
  final String premium;

  const _UpgradeStat({
    required this.label,
    required this.free,
    required this.premium,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: const TextStyle(
                color: Color(0xFF4a5a7a),
                fontSize: 13,
                fontFamily: 'Courier'),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            free,
            style: const TextStyle(
                color: Color(0xFF4a5a7a),
                fontSize: 13,
                fontFamily: 'Courier'),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            premium,
            style: const TextStyle(
                color: Colors.amber,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'Courier'),
          ),
        ),
      ],
    );
  }
}
