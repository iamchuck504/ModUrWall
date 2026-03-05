# ModUrWall — Session Report for Opus 4.6
**Project:** ModUrWallApp (Flutter) — `modurwall.com`
**Status:** v0 Demo Complete — scaffold implemented, 0 compile errors
**Last session:** Sonnet 4.6 (implementation agent)

---

## What Was Done This Session

Three things happened in order:

1. **Codebase audit** — monolithic `main.dart` (1,391 lines) scanned and mapped
2. **Demo scaffold built** — Tetris removed, app restructured into proper layers
3. **Config system added** — hardcoded IPs replaced with `--dart-define-from-file` JSON config

---

## Current lib/ Structure

```
lib/
├── main.dart                     29 lines — thin router only
├── config/
│   └── app_config.dart           compile-time constants via String.fromEnvironment
├── theme/
│   └── app_theme.dart            AppTheme class, 8 color presets
├── models/
│   └── wallpaper.dart            WallpaperModel, WallpaperTier, WallpaperStatus + 12 mock entries
├── services/
│   ├── wallpaper_service.dart    abstract WallpaperService + MockWallpaperService
│   └── auth_service.dart         abstract AuthService + MockAuthService (OAuth 2.0 interface)
├── widgets/
│   ├── wallpaper_background.dart WallpaperBackground, WallpaperPainter, SquareData
│   └── tier_badge.dart           TierBadge chip (green FREE / amber Lempyrλ ✦)
└── screens/
    ├── home_screen.dart          gallery grid + prompt bar + upgrade BottomSheet
    └── creator_screen.dart       genre/style/flow picker, mock generation
```

---

## Routes

| Route | Screen | Description |
|---|---|---|
| `/` | `HomeScreen` | Wallpaper gallery grid, prompt bar, free/premium distinction |
| `/creator` | `CreatorScreen` | Genre/style/flow selectors, simulated 1s delay, placehold.co image |

---

## pubspec.yaml — Dependencies (unchanged)

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^2.0.0
```

**Zero third-party packages.** No http, no state management, no image handling libs.

---

## Config System

Replaces the hardcoded IP `140.238.40.238:7777` from the original spec.

```
ModUrWallApp/config/
├── dev.json              ✅ committed — dev URLs + public client_id
├── prod.json             ✅ committed — prod URLs + public client_id
└── secrets.json.example  ✅ committed — template only
    (secrets.json)        ❌ gitignored — copy from .example, fill in secrets
```

`config/dev.json`:
```json
{
  "AUTH_BASE_URL": "http://auth.lempyra.com:7777",
  "API_BASE_URL":  "https://api.lempyra.com",
  "MODURWALL_CLIENT_ID": "modurwall_dev"
}
```

Accessed in Dart via `AppConfig.*` constants (baked in at compile time, not runtime):
```dart
import '../config/app_config.dart';
final url = AppConfig.authBaseUrl;
```

Run commands:
```bash
flutter run -d macos  --dart-define-from-file=config/dev.json
flutter build apk     --dart-define-from-file=config/prod.json
# With secrets:
flutter run -d macos  --dart-define-from-file=config/dev.json \
                      --dart-define-from-file=config/secrets.json
```

---

## Key Abstractions — Seams for v1

### WallpaperService

```dart
abstract class WallpaperService {
  Future<List<WallpaperModel>> getWallpapers();
  Future<List<WallpaperModel>> getWallpapersByTier(WallpaperTier tier);
  Future<String> submitGeneration(String prompt);        // returns jobId
  Future<WallpaperModel?> checkGenerationStatus(String jobId);
}
```

v1 action: implement `LempyraWallpaperService` that hits `AppConfig.apiBaseUrl/modurwall/generate`. Swap into `HomeScreen` constructor — no UI changes needed.

### AuthService

```dart
abstract class AuthService {
  Future<bool> register(String username, String password, String email);
  Future<bool> login(String username, String password);
  Future<bool> refreshToken();
  Future<void> logout();
  Future<String?> getAccessToken();
  bool get isAuthenticated;
  String get currentTier;  // "free" | "premium"
}
```

Maps to Lempyrλ ClearingHouse OAuth 2.0 flow (`AppConfig.authBaseUrl`):
1. `POST /register`
2. `POST /authorize` → auth_code
3. `POST /token` → JWT + refresh_token

Open items before real implementation:
- [ ] Register ModUrWall as OAuth client → get `client_id` (set in `config/dev.json`)
- [ ] Define scopes (`wallpaper,generate,profile` or similar)
- [ ] Get JWT payload structure — confirm `tier`/`plan` claim name
- [ ] Decide PKCE vs client_secret (PKCE recommended for mobile — eliminates need for `secrets.json`)

---

## Mock Data — 12 Wallpapers

Uses existing `assets/animations/` GIFs. No network required.

| id | Asset | Title | Tier |
|---|---|---|---|
| wp_001 | NeuralNetwork.gif | Neural Network | free |
| wp_002 | DigitalMatrix.gif | Digital Matrix | free |
| wp_003 | CloudComputing.gif | Cloud Computing | free |
| wp_004 | DataVisualization.gif | Data Visualization | free |
| wp_005 | QuantumComputing.gif | Quantum Computing | free |
| wp_006 | Blockchain.gif | Blockchain | free |
| wp_007 | digitalSamurai.gif | Digital Samurai | premium |
| wp_008 | Cybersecurity.gif | Cybersecurity | premium |
| wp_009 | Infrastructure.gif | Infrastructure | premium |
| wp_010 | pianoAnimeAI.gif | Piano Anime | premium |
| wp_011 | cuteWitchcartoon.gif | Cute Witch | premium |
| wp_012 | vikingScream.gif | Viking Scream | premium |

---

## HomeScreen UI — Implemented

```
┌───────────────────────────────────────┐
│  ModUrWall              [FREE TIER ▾] │  ← taps → upgrade BottomSheet
├───────────────────────────────────────┤
│  ┌────────┐  ┌────────┐              │
│  │  GIF   │  │  GIF   │              │  GridView.builder
│  │ [FREE] │  │ [FREE] │              │  2 cols, spacing 12, padding 16
│  └────────┘  └────────┘              │
│  ┌────────┐  ┌────────┐              │
│  │  GIF   │  │  🔒    │              │  premium: Opacity(0.35) + lock icon
│  │ [FREE] │  │[Lmpyrλ]│              │  tap → BottomSheet (upgrade CTA)
│  └────────┘  └────────┘              │
├───────────────────────────────────────┤
│  ┌──────────────────────────┐  [➤]  │  ← TextField + send → SnackBar
│  │ Describe your wallpaper… │        │    "AI generation — coming soon!"
│  └──────────────────────────┘        │
│           [🎨 CREATOR CONSOLE]       │  ← nav to /creator
└───────────────────────────────────────┘
```

---

## Upgrade BottomSheet — Implemented

Appears on: FREE TIER chip tap, any premium card tap.

| | Free | Lempyrλ ✦ |
|---|---|---|
| Generations/day | 10 | Unlimited |
| Premium gallery | — | ✦ Full access |
| Resolution | 1080p | 4K |

CTA button: "UPGRADE TO LEMPYRΛ" → SnackBar "Upgrade flow — coming soon!"

---

## Platforms

All 6 enabled (unchanged from original):
Android · iOS · macOS · Linux · Windows · Web

---

## What's Next (v1)

### Minimum to make it functional

1. **Add `http` package** to `pubspec.yaml`
2. **Implement `LempyraWallpaperService`** — real `POST /modurwall/generate` + polling
3. **Implement `LempyraAuthService`** — real OAuth 2.0 flow against `AppConfig.authBaseUrl`
4. **Wire `client_id`** — coordinate with Lempyrλ, set in `config/dev.json`

### Secondary

5. **Wallpaper apply** — platform-specific logic (Android: `flutter_wallpaper_manager`; iOS: Photos save; macOS: `osascript`)
6. **Auth UI** — login/register screens (interface already defined)
7. **User tier from JWT** — decode claim → drive `HomeScreen` free/premium state dynamically

### Nothing to redesign

The service abstractions, config system, and UI tier logic are all in place. v1 is purely implementation work behind existing interfaces — no screen or widget changes needed to go live.
