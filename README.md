# ModUrWall - Technical Plan

## Project Overview
**ModUrWall**: AI-powered wallpaper generation app that creates and applies device backgrounds based on user prompts.

**Tech Stack**: Flutter (cross-platform: iOS, Android, Desktop, Web)  
**Backend**: Lempyra Oracle Cloud infrastructure  
**Philosophy**: OS-agnostic, terminal-capable where possible

---

## Core Features

### 1. Prompt-Based Generation
- User inputs text description
- App sends to Lempyra backend
- Image generated at device-specific resolution
- Preview before apply

### 2. Wallpaper Application
- **Android**: Direct wallpaper setting (1-click)
- **iOS**: Save + guided apply (2-click limitation)
- **Desktop**: Direct apply (Linux/Windows), save for macOS
- **Web**: Download only

### 3. Device Detection
- Auto-detect screen resolution
- Generate optimal dimensions
- Handle aspect ratios (portrait/landscape)

---

## Architecture

```
┌─────────────────┐
│   Flutter App   │
│  (All Platforms)│
└────────┬────────┘
         │
         │ HTTPS/REST
         │
┌────────▼────────────────────┐
│   Lempyra Oracle Backend   │
│                             │
│  ┌──────────────────────┐  │
│  │  API Layer           │  │
│  │  /generate-wallpaper │  │
│  └──────────┬───────────┘  │
│             │               │
│  ┌──────────▼───────────┐  │
│  │  Image Generation    │  │
│  │  (Stable Diffusion/  │  │
│  │   DALL-E API)        │  │
│  └──────────┬───────────┘  │
│             │               │
│  ┌──────────▼───────────┐  │
│  │  Storage & CDN       │  │
│  └──────────────────────┘  │
└─────────────────────────────┘
```

---

## Platform-Specific Implementation

### Android
**Capability**: Full automation

```dart
// Permissions needed in AndroidManifest.xml
<uses-permission android:name="android.permission.SET_WALLPAPER"/>
<uses-permission android:name="android.permission.INTERNET"/>

// Implementation
import 'package:flutter_wallpaper_manager/flutter_wallpaper_manager.dart';

Future<void> setWallpaper(String imagePath) async {
  await WallpaperManager.setWallpaperFromFile(
    imagePath,
    WallpaperManager.HOME_SCREEN
  );
}
```

**User Flow**:
1. Enter prompt → Generate → Preview → "Apply" button
2. **ONE TAP** → wallpaper changes instantly

**No additional permissions dialog needed** (declared at install time)

---

### iOS
**Limitation**: Apple does not allow programmatic wallpaper changes

**Required Permission**:
```xml
<!-- Info.plist -->
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save generated wallpapers to your library</string>
```

**User Flow**:
1. Enter prompt → Generate → Preview
2. "Save & Apply" button
3. Image saves to Photos
4. App displays instructions: "Go to Settings > Wallpaper"
5. **User must manually navigate and apply** (2 taps minimum)

**Best UX Workaround**:
```dart
// Open Settings app directly to Wallpaper section
import 'package:url_launcher/url_launcher.dart';

await launch('App-Prefs:Wallpaper'); // iOS deep link
```

**User still needs to**:
- Select the saved image
- Tap "Set"

**This is an Apple platform restriction, not a technical limitation.**

---

### Desktop (Linux/Windows)
**Capability**: Full automation

```dart
// Linux (GNOME)
Process.run('gsettings', [
  'set',
  'org.gnome.desktop.background',
  'picture-uri',
  'file://$imagePath'
]);

// Windows
Process.run('reg', [
  'add',
  'HKCU\\Control Panel\\Desktop',
  '/v',
  'Wallpaper',
  '/t',
  'REG_SZ',
  '/d',
  imagePath,
  '/f'
]);
```

**User Flow**: Same as Android - one click apply

---

### Desktop (macOS)
**Limitation**: Requires AppleScript, which needs user approval

```dart
// Requires System Events permission
Process.run('osascript', [
  '-e',
  'tell application "System Events" to set picture of every desktop to "$imagePath"'
]);
```

**First time**: macOS asks user to grant permission  
**After that**: Automatic

---

### Web (PWA)
**Limitation**: Browser sandbox - cannot modify OS settings

**User Flow**:
1. Enter prompt → Generate → Preview
2. "Download" button only
3. User manually applies via OS

**Progressive Enhancement**: Detect if running as PWA vs browser tab

---

## API Specification

### Endpoint: Generate Wallpaper

```
POST https://api.lempyra.com/modurwall/generate
Content-Type: application/json
Authorization: Bearer {user_token}

{
  "prompt": "cyberpunk neon cityscape at night",
  "width": 1170,
  "height": 2532,
  "style": "photorealistic" // optional
}

Response 200 OK:
{
  "image_url": "https://cdn.lempyra.com/wallpapers/abc123.png",
  "generation_id": "gen_abc123",
  "timestamp": 1703001234
}

Response 429 Too Many Requests:
{
  "error": "rate_limit_exceeded",
  "retry_after": 60
}
```

---

## Terminal Interface (OS Agnostic)

**CLI Tool**: `modurwall` command

```bash
# Install
curl -sSL https://lempyra.com/install/modurwall.sh | bash

# Usage
modurwall generate "abstract geometric dark" --apply
modurwall generate "nature forest" --preview
modurwall history
modurwall apply gen_abc123

# Config
~/.modurwall/config.json
{
  "api_key": "...",
  "default_resolution": "auto",
  "auto_apply": true
}
```

**Platform Detection**:
```bash
#!/bin/bash
OS=$(uname -s)
case "$OS" in
  Linux*)   SET_CMD="gsettings set org.gnome.desktop.background picture-uri";;
  Darwin*)  SET_CMD="osascript -e 'tell application System Events...'";;
  MINGW*)   SET_CMD="reg add HKCU\\Control Panel\\Desktop...";;
esac
```

---

## Flutter Project Structure

```
modurwall/
├── lib/
│   ├── main.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── generation_screen.dart
│   │   └── history_screen.dart
│   ├── services/
│   │   ├── api_service.dart          # Lempyra backend calls
│   │   ├── wallpaper_service.dart    # Platform-specific apply logic
│   │   └── storage_service.dart      # Local cache
│   ├── models/
│   │   └── wallpaper.dart
│   └── utils/
│       └── platform_detector.dart
├── android/
│   └── app/src/main/AndroidManifest.xml
├── ios/
│   └── Runner/Info.plist
├── linux/
├── macos/
├── windows/
└── web/
```

---

## User Permissions Summary

| Platform | Permission Needed | User Interaction Required |
|----------|-------------------|---------------------------|
| Android  | SET_WALLPAPER (install-time) | **None** - auto apply |
| iOS      | Photos Library (runtime) | **Manual apply in Settings** |
| Linux    | None | **None** - auto apply |
| Windows  | None | **None** - auto apply |
| macOS    | System Events (first-time) | **First time only** |
| Web      | None | **Manual download + apply** |

---

## Why iOS Requires User Interaction

**Apple's Sandbox Model**:
- iOS apps cannot modify system settings programmatically
- Security/privacy design decision
- Prevents malicious apps from changing wallpapers without consent
- **No workaround exists** (jailbreak aside)

**Even Apple's own Photos app**:
- User must tap "Use as Wallpaper"
- Then tap "Set"
- Minimum 2 interactions required

**This is intentional platform design, not a technical failure.**

---

## Revenue Share Model (51% client, 49% Lempyra)

**Client earns 51% from**:
- App sales via Lempyra platform (3% cut from sales in Lempyra marketplace)
- In-app purchases managed by Lempyra

**Lempyra earns 49% + platform fees**:
- Backend infrastructure costs
- Image generation API costs
- CDN/storage
- Support

---

## MVP Timeline

**Week 1-2: Core App**
- Flutter UI (prompt input, preview, history)
- API integration to Lempyra backend
- Android wallpaper apply

**Week 3: Multi-Platform**
- iOS save + instructions flow
- Desktop (Linux/Windows) apply
- macOS AppleScript approach

**Week 4: Polish**
- Error handling
- Offline mode (cached wallpapers)
- Rate limiting UI
- Onboarding tutorial

---

## Technical Constraints

**Image Generation**:
- Resolution limits: Max 4K (4096x2160)
- Generation time: 5-15 seconds
- Cost per generation: ~$0.02-0.05

**Rate Limiting**:
- Free tier: 10 generations/day
- Paid tier: Unlimited ($4.99/month)

**Storage**:
- User's generated wallpapers stored 30 days
- Can download for permanent local storage

---

## Terminal Version (Advanced Users)

**Why terminal matters**:
- Power users on Linux/macOS
- Server administrators wanting dynamic wallpapers
- Automation/cron jobs
- Lempyra philosophy: everything accessible via CLI

**Example automations**:
```bash
# Change wallpaper every 4 hours
0 */4 * * * modurwall generate "random abstract" --apply --quiet

# Morning/evening themes
0 7 * * * modurwall generate "sunrise landscape" --apply
0 19 * * * modurwall generate "sunset cityscape" --apply
```

---

## Security Considerations

**API Authentication**:
- JWT tokens with 7-day expiration
- Refresh token flow
- Rate limiting per user

**Image Storage**:
- CDN with signed URLs (1-hour expiration)
- No permanent public URLs
- User can request deletion (GDPR compliance)

**Privacy**:
- Prompts not logged permanently
- Images auto-deleted after 30 days
- No telemetry without opt-in

---

## Success Metrics

**Technical KPIs**:
- API response time: <2s for generation start
- Image generation: <15s average
- App crash rate: <0.1%
- Platform-specific apply success rate: >95% (Android/Desktop)

**User KPIs**:
- Daily active users
- Generations per user per day
- Paid conversion rate

---

## Open Questions for Client

1. **Pricing model preference**:
   - Freemium (10 free/day + paid unlimited)?
   - Flat $4.99/month?
   - Pay-per-generation ($0.50 each)?

2. **Style presets**:
   - Offer predefined styles (minimalist, cyberpunk, nature)?
   - Full custom prompts only?

3. **Social features**:
   - Share generated wallpapers?
   - Public gallery?
   - Or private-only?

4. **iOS limitation**:
   - Accept manual apply flow?
   - Or delay iOS launch until critical mass on Android?

---

## Next Steps

1. **Week 1**: Set up Flutter project + Lempyra API integration
2. **Week 2**: Implement Android auto-apply
3. **Week 3**: Handle iOS manual flow + desktop platforms
4. **Week 4**: Terminal CLI tool
5. **Week 5**: Beta testing with 10 internal users

---

**Document Version**: 1.0  
**Last Updated**: 2024-12-16  
**Owner**: Lempyra Engineering  
**Status**: Planning Phase
