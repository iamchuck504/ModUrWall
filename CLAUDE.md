# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ModUrWall** is an AI-powered wallpaper generation app with two components:
1. **Flutter app** (`ModUrWallApp/`) — cross-platform mobile/desktop app (iOS, Android, macOS, Linux, Windows, Web)
2. **Website** (`docs/`, `index.html`) — static marketing/landing pages served via nginx with autoindex

Backend: Lempyrλ Oracle Cloud infrastructure at `api.lempyra.com`

---

## Flutter App Commands

All commands run from `ModUrWallApp/`. Always pass a config file:

```bash
# Run
flutter run -d macos  --dart-define-from-file=config/dev.json
flutter run -d ios    --dart-define-from-file=config/dev.json
flutter run -d chrome --dart-define-from-file=config/dev.json

# Build for production
flutter build macos --dart-define-from-file=config/prod.json
flutter build ios   --dart-define-from-file=config/prod.json
flutter build apk   --dart-define-from-file=config/prod.json

# Run with secrets merged (local only, never committed)
flutter run -d macos --dart-define-from-file=config/dev.json \
                     --dart-define-from-file=config/secrets.json

# Tests / analyze / deps
flutter test
flutter test test/widget_test.dart
flutter analyze
flutter pub get
```

---

## Runtime Configuration

Config lives in `ModUrWallApp/config/`, baked into the binary at compile time via `--dart-define-from-file`. All values are accessed through `AppConfig.*` — never hardcode URLs in service files.

| File | Committed | Purpose |
|---|---|---|
| `config/dev.json` | ✅ yes | Dev URLs + public `client_id` |
| `config/prod.json` | ✅ yes | Prod URLs + public `client_id` |
| `config/secrets.json.example` | ✅ yes | Template — copy to `secrets.json` |
| `config/secrets.json` | ❌ gitignored | `client_secret` if needed (PKCE preferred) |

`lib/config/app_config.dart` exposes: `AppConfig.authBaseUrl`, `AppConfig.apiBaseUrl`, `AppConfig.clientId`, `AppConfig.clientSecret`.

---

## App Architecture

```
lib/
├── main.dart                     thin router, ~29 lines
├── config/
│   └── app_config.dart           compile-time constants via String.fromEnvironment
├── theme/
│   └── app_theme.dart            AppTheme class, 8 color presets
├── models/
│   └── wallpaper.dart            WallpaperModel, WallpaperTier enum, kMockWallpapers list
├── services/
│   ├── wallpaper_service.dart    abstract WallpaperService + MockWallpaperService
│   └── auth_service.dart         abstract AuthService + MockAuthService
├── widgets/
│   ├── wallpaper_background.dart WallpaperBackground (animated square-grid CustomPainter)
│   └── tier_badge.dart           TierBadge chip
└── screens/
    ├── home_screen.dart          gallery grid + prompt bar + upgrade BottomSheet
    └── creator_screen.dart       genre/style/flow picker, mock generation
```

**Routes:**
- `/` → `HomeScreen` — wallpaper gallery grid, prompt bar, free/premium tier distinction
- `/creator` → `CreatorScreen` — genre/style/flow selectors, simulated generation

**Key abstractions:**
- `AppConfig` — all URLs and client IDs. Swap environment via `--dart-define-from-file`. Never read at runtime.
- `AppTheme` — 8 color presets (dark, cyan, yellow, magenta, orange, blue, green, red, light). `AppTheme.themes` cycles through non-dark variants.
- `WallpaperService` / `MockWallpaperService` — the seam between UI and backend. Implement `LempyraWallpaperService` here for v1; no screen changes needed.
- `AuthService` / `MockAuthService` — OAuth 2.0 interface matching Lempyrλ ClearingHouse flow at `AppConfig.authBaseUrl`. 3-step: `/register` → `/authorize` → `/token`.
- `WallpaperBackground` / `WallpaperPainter` — animated square-grid canvas, used in `CreatorScreen`. Not used on `HomeScreen` (clean dark background per spec).

**Assets:** `ModUrWallApp/assets/animations/` — 22 GIFs declared in `pubspec.yaml`, used as mock wallpaper thumbnails in `kMockWallpapers` (12 selected: 6 free, 6 premium).

**Dependencies:** Only `cupertino_icons` beyond Flutter SDK. No http package yet.

---

## API Contract (Not Yet Integrated)

All base URLs come from `AppConfig`. Add `http` package to `pubspec.yaml` before implementing.

```
# Wallpaper generation
POST ${AppConfig.apiBaseUrl}/modurwall/generate
Authorization: Bearer <jwt>
{ "prompt": "...", "width": 1170, "height": 2532, "style": "photorealistic" }
→ { "image_url": "...", "generation_id": "...", "timestamp": ... }

# Auth (Lempyrλ ClearingHouse OAuth 2.0)
POST ${AppConfig.authBaseUrl}/register   { username, password, email }
POST ${AppConfig.authBaseUrl}/authorize  { username, password, client_id, scope } → auth_code
POST ${AppConfig.authBaseUrl}/token      { grant_type, code, client_id, client_secret } → JWT
POST ${AppConfig.authBaseUrl}/token      { grant_type: refresh_token, refresh_token }
POST ${AppConfig.authBaseUrl}/revoke     { token }
```

Rate limits: 10 generations/day free, unlimited paid. JWT expiry: 7 days.

**Open items before auth implementation:**
- [ ] Register ModUrWall as OAuth client → receive `client_id` → put in `config/dev.json`
- [ ] Define scopes with Lempyrλ team
- [ ] Confirm JWT payload — which claim carries `tier`/`plan`?
- [ ] PKCE vs client_secret decision (PKCE recommended for mobile)

---

## Website Structure

Static site served via nginx with autoindex. All commands from repo root.

- `index.html` — file navigator (matrix-rain aesthetic, fetches nginx autoindex at `__autoindex` endpoint)
- `docs/index.html` — main marketing landing page with interactive canvas ripple effect
- `docs/app/tetris/index.html` — Tetris standalone web page
- `docs/app/creatorConsole/index.html` — Creator Console web page

Consistent aesthetic: `#0a0e1a` background, `#0088ff` accent, `Courier New` font.

---

## Platform Wallpaper Apply (Not Yet Implemented)

- **Android**: `flutter_wallpaper_manager` package — 1-tap apply (not in pubspec yet)
- **iOS**: Save to Photos only, user applies manually via Settings (Apple restriction, no workaround)
- **Linux/Windows**: `Process.run` system commands — 1-tap apply
- **macOS**: `osascript` via `Process.run` — requires System Events permission on first run
- **Web**: Download only
