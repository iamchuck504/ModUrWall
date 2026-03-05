# ModUrWall — Agent Build Spec (from Opus 4.6)

**For:** Coding Agent (Sonnet / Agent mode)
**From:** Opus 4.6 Architecture Session
**Project:** ModUrWallApp (Flutter/Dart)
**Goal:** Transform monolith into demo-ready wallpaper app scaffold

---

## Context

The agent already audited the codebase (see `reportForOpus46.md`). This spec contains
all architectural decisions made in the Opus session. The agent should execute exactly
this plan — no freelancing on structure or naming.

---

## Decisions Already Made

- **Background:** Home screen uses clean dark background (NOT animated WallpaperBackground)
- **WallpaperBackground** stays in codebase for CreatorConsole and future splash screens
- **Auth:** Lempyrλ already has an `/auth/` model — we will integrate their spec later.
  For now, create a placeholder `AuthService` interface with no implementation.
- **Structure:** 7-file scaffold (see below)
- **No new pub.dev packages** for this phase

---

## Step 0 — Delete Tetris Code from main.dart

Remove these blocks entirely (~435 lines):

| Block | Action |
|---|---|
| `TetrisWaitingRoom` + `_TetrisWaitingRoomState` | DELETE |
| `TetrisGameWidget` + `_TetrisGameWidgetState` | DELETE |
| `TetrisPainter` | DELETE |
| `TetrisPiece` | DELETE |
| `ControlButton` | DELETE |
| `ThemeButton` | DELETE |
| `/tetris` route in MaterialApp | DELETE |
| `WAITING ROOM` MenuButton on HomeScreen | DELETE |

---

## Step 1 — Create Target File Structure

```
lib/
├── main.dart                          REWRITE — <50 lines, routes + theme ref only
├── theme/
│   └── app_theme.dart                 EXTRACT from main.dart
├── models/
│   └── wallpaper.dart                 NEW
├── services/
│   ├── wallpaper_service.dart         NEW — abstract + mock implementation
│   └── auth_service.dart              NEW — placeholder interface only
├── widgets/
│   ├── wallpaper_background.dart      EXTRACT from main.dart (WallpaperBackground + WallpaperPainter + SquareData)
│   └── tier_badge.dart                NEW
└── screens/
    ├── home_screen.dart               NEW — gallery grid + prompt bar
    └── creator_screen.dart            EXTRACT from main.dart (CreatorConsole + CreatorControlSquare)
```

---

## Step 2 — File Specifications

### `lib/models/wallpaper.dart`

```dart
enum WallpaperTier { free, premium }
enum WallpaperStatus { completed, generating, failed }

class WallpaperModel {
  final String id;               // "wp_001" format
  final String title;
  final String assetPath;        // "assets/animations/xyz.gif" for v0
  final String? prompt;          // null for predefined wallpapers
  final WallpaperTier tier;
  final WallpaperStatus status;
  final List<String> tags;
  final DateTime createdAt;

  const WallpaperModel({
    required this.id,
    required this.title,
    required this.assetPath,
    this.prompt,
    required this.tier,
    this.status = WallpaperStatus.completed,
    this.tags = const [],
    required this.createdAt,
  });

  /// Ready for v1 — unused in v0, but the shape matches the API contract
  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    return WallpaperModel(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      assetPath: json['full_url'] as String,  // CDN URL in v1
      prompt: json['prompt'] as String?,
      tier: json['tier'] == 'premium' ? WallpaperTier.premium : WallpaperTier.free,
      status: WallpaperStatus.completed,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
```

Mock data list — use 12 items from existing `assets/animations/`:

| # | Asset File | Title | Tier |
|---|---|---|---|
| 1 | NeuralNetwork.gif | Neural Network | free |
| 2 | DigitalMatrix.gif | Digital Matrix | free |
| 3 | CloudComputing.gif | Cloud Computing | free |
| 4 | DataVisualization.gif | Data Visualization | free |
| 5 | QuantumComputing.gif | Quantum Computing | free |
| 6 | Blockchain.gif | Blockchain | free |
| 7 | digitalSamurai.gif | Digital Samurai | premium |
| 8 | Cybersecurity.gif | Cybersecurity | premium |
| 9 | Infrastructure.gif | Infrastructure | premium |
| 10 | pianoAnimeAI.gif | Piano Anime | premium |
| 11 | cuteWitchcartoon.gif | Cute Witch | premium |
| 12 | vikingScream.gif | Viking Scream | premium |

Create a `const List<WallpaperModel> kMockWallpapers` with these 12 entries.

---

### `lib/services/wallpaper_service.dart`

This is the **critical abstraction** — the seam between UI and backend.

```dart
import '../models/wallpaper.dart';

/// Abstract contract — screens depend on this, never on an implementation
abstract class WallpaperService {
  Future<List<WallpaperModel>> getWallpapers();
  Future<List<WallpaperModel>> getWallpapersByTier(WallpaperTier tier);
  Future<String> submitGeneration(String prompt);          // returns jobId
  Future<WallpaperModel?> checkGenerationStatus(String jobId);
}

/// v0 mock — returns hardcoded data with simulated delays
class MockWallpaperService implements WallpaperService {
  @override
  Future<List<WallpaperModel>> getWallpapers() async {
    await Future.delayed(const Duration(milliseconds: 300)); // simulate network
    return kMockWallpapers;
  }

  @override
  Future<List<WallpaperModel>> getWallpapersByTier(WallpaperTier tier) async {
    final all = await getWallpapers();
    return all.where((w) => w.tier == tier).toList();
  }

  @override
  Future<String> submitGeneration(String prompt) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'mock_job_${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Future<WallpaperModel?> checkGenerationStatus(String jobId) async {
    await Future.delayed(const Duration(seconds: 2)); // simulate processing
    // Return a random mock wallpaper as the "generated" result
    return kMockWallpapers.first;
  }
}
```

---

### `lib/services/auth_service.dart`

**Interface matches Lempyrλ ClearingHouse OAuth 2.0 flow.**
Server: `http://140.238.40.238:7777`
Docs: `http://140.238.40.238:7777/docs`

The flow is a 3-step OAuth 2.0 Authorization Code grant:
1. `POST /register` — create account (username, password, email)
2. `POST /authorize` — (username, password, client_id, scope) → returns auth code
3. `POST /token` — (grant_type: authorization_code, code, client_id, client_secret) → JWT + refresh token

Refresh: `POST /token` with `grant_type: refresh_token`
Logout: `POST /revoke` with the token

```dart
/// ClearingHouse OAuth 2.0 flow — Lempyrλ auth server
/// Server: http://140.238.40.238:7777
///
/// For this phase: interface only + a MockAuthService that simulates
/// the flow without network calls. Real implementation comes when
/// we add the http package and coordinate client_id/scope with Lempyrλ.

abstract class AuthService {
  /// POST /register → create account
  Future<bool> register(String username, String password, String email);

  /// Combined: POST /authorize → auth code, then POST /token → JWT
  /// UI calls this as one action; implementation handles both steps
  Future<bool> login(String username, String password);

  /// POST /token (grant_type: refresh_token)
  Future<bool> refreshToken();

  /// POST /revoke → invalidate token
  Future<void> logout();

  /// Current access token for Authorization: Bearer header
  Future<String?> getAccessToken();

  /// Auth state
  bool get isAuthenticated;

  /// User tier derived from JWT claims (TBD — need JWT payload spec from Lempyrλ)
  String get currentTier; // "free" | "premium"
}

/// Mock for v0 demo — no network calls
class MockAuthService implements AuthService {
  bool _authenticated = false;
  String _tier = 'free';

  @override
  Future<bool> register(String username, String password, String email) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true; // always succeeds in mock
  }

  @override
  Future<bool> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _authenticated = true;
    _tier = 'free';
    return true;
  }

  @override
  Future<bool> refreshToken() async => _authenticated;

  @override
  Future<void> logout() async {
    _authenticated = false;
  }

  @override
  Future<String?> getAccessToken() async =>
      _authenticated ? 'mock_jwt_token' : null;

  @override
  bool get isAuthenticated => _authenticated;

  @override
  String get currentTier => _tier;
}
```

**Open items for Lempyrλ coordination:**
- [ ] Register ModUrWall as a client → get our own `client_id` (not `"portal"`)
- [ ] Define ModUrWall scopes (e.g. `wallpaper,generate,profile`)
- [ ] Get JWT payload structure — does it include `tier`/`plan` claim?
- [ ] Confirm if PKCE is supported (recommended for mobile OAuth clients)

---

### `lib/theme/app_theme.dart`

Extract the existing `AppTheme` class verbatim from main.dart.
Keep all 8 color presets. No changes to logic.

---

### `lib/widgets/wallpaper_background.dart`

Extract from main.dart:
- `WallpaperBackground` (StatefulWidget)
- `_WallpaperBackgroundState`
- `WallpaperPainter` (CustomPainter)
- `SquareData` (data class)

No logic changes. Just add proper imports.

---

### `lib/widgets/tier_badge.dart`

Small reusable widget:

```dart
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
        color: isFree ? Colors.green.withOpacity(0.8) : Colors.amber.withOpacity(0.8),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        isFree ? 'FREE' : 'Lempyrλ ✦',
        style: TextStyle(
          color: isFree ? Colors.white : Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
```

---

### `lib/screens/home_screen.dart`

Layout spec (clean dark background, NO animated grid):

```
┌───────────────────────────────────────┐
│  ModUrWall              [FREE TIER ▾] │  ← AppBar or custom header
│                                       │     dark background (scaffold bg)
├───────────────────────────────────────┤
│                                       │
│  ┌────────┐  ┌────────┐              │
│  │ GIF    │  │ GIF    │              │  GridView.builder
│  │ thumb  │  │ thumb  │              │  2 columns, crossAxisSpacing: 12
│  │ [FREE] │  │ [FREE] │              │  mainAxisSpacing: 12
│  └────────┘  └────────┘              │  padding: 16 all sides
│  ┌────────┐  ┌────────┐              │
│  │ GIF    │  │ 🔒dim  │              │  Free items: full opacity, green FREE badge
│  │ thumb  │  │ thumb  │              │  Premium items: Opacity(0.4) + lock icon
│  │ [FREE] │  │[Lmpyrλ]│              │    + amber "Lempyrλ ✦" badge
│  └────────┘  └────────┘              │  Tapping premium → BottomSheet (upgrade CTA)
│  ...                                  │
│                                       │
├───────────────────────────────────────┤
│  ┌──────────────────────────┐  [➤]  │  ← Prompt bar (pinned bottom)
│  │ Describe your wallpaper… │        │    TextField + IconButton
│  └──────────────────────────┘        │    Send button: DISABLED (no logic)
│                                       │    Tapping send → SnackBar: "Coming soon!"
│  [🎨 CREATOR CONSOLE]                │  ← TextButton nav to /creator
└───────────────────────────────────────┘
```

**Grid card widget (inline or private class):**
- `ClipRRect` with `borderRadius: 12`
- `Image.asset(wallpaper.assetPath, fit: BoxFit.cover)`
- `Positioned` bottom-left: `TierBadge`
- If premium: `Stack` with `Opacity(opacity: 0.4)` on image + centered `Icon(Icons.lock)`
- `GestureDetector` — free: opens detail/preview (phase 2),