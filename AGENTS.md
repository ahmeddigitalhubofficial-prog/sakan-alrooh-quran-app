# Development & Release Guidelines for Sakan Al-Rooh (سكن الروح)

## 🚨 MANDATORY RELEASE RULE: Always Build With Shorebird
- **Rule**: Whenever building or publishing any release package (`.aab` or `.apk`) for Google Play, Huawei AppGallery, Xiaomi, or Samsung stores, **YOU MUST ALWAYS USE SHOREBIRD** (e.g. via `.\release_auto.ps1` or `shorebird release android`).
- **Rationale**: The application relies on Shorebird CodePush (`shorebird_code_push`) to deliver instant OTA (Over-The-Air) bugfixes and feature updates to users across all stores without requiring manual store re-reviews.
- **Commands**:
  - To build a new official release bundle: `.\release_auto.ps1` or `shorebird release android`
  - To push instant live patches: `shorebird patch android --release-version=<version>` or `.\patch_all_releases.ps1` / `.\patch_phone_version.bat`

## 🎯 PROTOCOL FOR CRASH / CRASHLYTICS EMAILS:
Whenever the user shares an error, stack trace, or Crashlytics email/link:
1. **Analyze Severity & Urgency**:
   - **Critical / Urgent (P0)**: Fatal Exception affecting multiple users (> 1 user) or blocking core features (Prayer times, Azan notifications, Quran, Qibla, or App launch) -> **Requires immediate action**.
   - **Tolerable / Deferred (P1)**: 1 isolated user / rare OEM / non-fatal log -> Can wait for the next scheduled bi-weekly or monthly release.
2. **Explicit Recommendation to User**:
   - **Advise Shorebird Patch vs New Store AAB**:
     - If the fix is Dart-only code (logic, UI, timers, service fixes, formatting) on an already released version -> **Recommend Shorebird Patch** (`shorebird patch android`) so users get it instantly without store re-review.
     - If the fix touches native Android code (Kotlin `MainActivity.kt`, Gradle plugins, AndroidManifest permissions, ProGuard, C++ libraries) or requires a version bump for the stores -> **Recommend a Full Shorebird Release** (`.\release_auto.ps1`) to upload to Google Play and Huawei.
     - If the error is a one-off/stale version event -> **Advise the user that it can be safely ignored/monitored without urgent patching**.

## 🛡️ ESTABLISHED REPOSITORY PATTERNS (DO NOT BREAK):
1. **Background Lifecycle Safety (`AppLifecycleHelper`)**:
   - Never keep periodic 1-second timers, compass streams, or live camera sessions active while the app is in background (`AppLifecycleHelper.isBackground`).
   - Late graphics frames after engine detach crash `FlutterJNI` if timers fire in the background.
2. **CameraX & Qibla Fallback**:
   - Never initialize `CameraController` or invoke `availableCameras()` on app startup or outside the Qibla tab.
   - Always wrap camera initialization in `try/catch` with a graceful fallback to 2D Digital Compass mode (`_statusMessage = 'وضع البوصلة الرقمية (2D)'`) to protect against OEM bugs (e.g. Vivo Android 12 Pigeon codec serialization `g0.h`).
3. **Notification Assets**:
   - Always use native drawable bitmaps (`@mipmap/ic_launcher`) for notification icons instead of large in-memory base64 strings to prevent Android 16 memory corruption and `FormatException: Invalid padding character`.

## 🔡 TERMINAL & SCRIPT ENCODING MANDATE (ENGLISH ONLY):
- **Rule**: ALL current and future automation scripts (`.bat`, `.ps1`, `.py`, `.sh`, `.cmd`) MUST use **English only** for all terminal outputs, interactive prompts, prints, logs, echoes, and status indicators.
- **Rationale**: Windows cmd and PowerShell render Arabic characters as garbled mojibake or reverse-order glyphs.
- **Scope**:
  - Script output, progress bars, debug logs, error messages, and batch menus: **100% English**.
  - App UI text, Islamic content, and social post payloads/captions published to social media remain in Arabic as intended.

## 🔍 AUTOMATED PROBLEMS & DIAGNOSTICS PROTOCOL:
- Whenever the user asks to "صلح المشاكل", "افحص الأخطاء", "send problems to agent", or "fix problems":
  1. The agent executes `python scripts/send_problems_to_agent.py lib` (or `python tool/send_problems_to_agent.py lib`).
  2. Reads `PROBLEMS.md`.
  3. Inspects and fixes every reported compiler error and warning in the codebase.
  4. Re-runs the script to confirm that all problems are resolved with 0 issues.



