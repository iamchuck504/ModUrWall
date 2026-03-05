enum WallpaperTier { free, premium }

enum WallpaperStatus { completed, generating, failed }

class WallpaperModel {
  final String id;
  final String title;
  final String assetPath; // "assets/animations/xyz.gif" for v0, CDN URL in v1
  final String? prompt;   // null for predefined wallpapers
  final WallpaperTier tier;
  final WallpaperStatus status;
  final List<String> tags;
  final DateTime createdAt;

  WallpaperModel({
    required this.id,
    required this.title,
    required this.assetPath,
    this.prompt,
    required this.tier,
    this.status = WallpaperStatus.completed,
    this.tags = const [],
    required this.createdAt,
  });

  /// Ready for v1 — shape matches the API contract at api.lempyra.com/modurwall
  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      assetPath: json['full_url'] as String,
      prompt: json['prompt'] as String?,
      tier: json['tier'] == 'premium' ? WallpaperTier.premium : WallpaperTier.free,
      status: WallpaperStatus.completed,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

/// 12 mock wallpapers using existing assets/animations/ GIFs
final List<WallpaperModel> kMockWallpapers = [
  // --- Free tier (6) ---
  WallpaperModel(
    id: 'wp_001',
    title: 'Neural Network',
    assetPath: 'assets/animations/NeuralNetwork.gif',
    tier: WallpaperTier.free,
    tags: ['ai', 'tech', 'neural'],
    createdAt: DateTime(2025, 12, 1),
  ),
  WallpaperModel(
    id: 'wp_002',
    title: 'Digital Matrix',
    assetPath: 'assets/animations/DigitalMatrix.gif',
    tier: WallpaperTier.free,
    tags: ['matrix', 'code', 'cyber'],
    createdAt: DateTime(2025, 12, 2),
  ),
  WallpaperModel(
    id: 'wp_003',
    title: 'Cloud Computing',
    assetPath: 'assets/animations/CloudComputing.gif',
    tier: WallpaperTier.free,
    tags: ['cloud', 'tech', 'infrastructure'],
    createdAt: DateTime(2025, 12, 3),
  ),
  WallpaperModel(
    id: 'wp_004',
    title: 'Data Visualization',
    assetPath: 'assets/animations/DataVisualization.gif',
    tier: WallpaperTier.free,
    tags: ['data', 'visualization', 'analytics'],
    createdAt: DateTime(2025, 12, 4),
  ),
  WallpaperModel(
    id: 'wp_005',
    title: 'Quantum Computing',
    assetPath: 'assets/animations/QuantumComputing.gif',
    tier: WallpaperTier.free,
    tags: ['quantum', 'physics', 'computing'],
    createdAt: DateTime(2025, 12, 5),
  ),
  WallpaperModel(
    id: 'wp_006',
    title: 'Blockchain',
    assetPath: 'assets/animations/Blockchain.gif',
    tier: WallpaperTier.free,
    tags: ['blockchain', 'crypto', 'tech'],
    createdAt: DateTime(2025, 12, 6),
  ),

  // --- Premium tier (6) ---
  WallpaperModel(
    id: 'wp_007',
    title: 'Digital Samurai',
    assetPath: 'assets/animations/digitalSamurai.gif',
    tier: WallpaperTier.premium,
    tags: ['samurai', 'cyberpunk', 'warrior'],
    createdAt: DateTime(2025, 12, 7),
  ),
  WallpaperModel(
    id: 'wp_008',
    title: 'Cybersecurity',
    assetPath: 'assets/animations/Cybersecurity.gif',
    tier: WallpaperTier.premium,
    tags: ['security', 'hacking', 'defense'],
    createdAt: DateTime(2025, 12, 8),
  ),
  WallpaperModel(
    id: 'wp_009',
    title: 'Infrastructure',
    assetPath: 'assets/animations/Infrastructure.gif',
    tier: WallpaperTier.premium,
    tags: ['infrastructure', 'systems', 'network'],
    createdAt: DateTime(2025, 12, 9),
  ),
  WallpaperModel(
    id: 'wp_010',
    title: 'Piano Anime',
    assetPath: 'assets/animations/pianoAnimeAI.gif',
    tier: WallpaperTier.premium,
    tags: ['anime', 'music', 'piano'],
    createdAt: DateTime(2025, 12, 10),
  ),
  WallpaperModel(
    id: 'wp_011',
    title: 'Cute Witch',
    assetPath: 'assets/animations/cuteWitchcartoon.gif',
    tier: WallpaperTier.premium,
    tags: ['witch', 'cartoon', 'fantasy'],
    createdAt: DateTime(2025, 12, 11),
  ),
  WallpaperModel(
    id: 'wp_012',
    title: 'Viking Scream',
    assetPath: 'assets/animations/vikingScream.gif',
    tier: WallpaperTier.premium,
    tags: ['viking', 'warrior', 'epic'],
    createdAt: DateTime(2025, 12, 12),
  ),
];
