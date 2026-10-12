# Build Audit Report

**Project:** Book Tracker by CodeToday  
**Repository:** https://github.com/eabgitbd/book-tracker-codetoday  
**Branch / Commit:** `main` (`27aaab8`)  
**Audit Date:** 2026-10-12  
**Current Milestone:** Phase 1 & 2 — Reliable Offline MVP & Reading-Life Companion  

---

## Overall Status: **PASS** ✅

All required checks (dependency resolution, static analysis, unit & widget test suite, and release Android APK build) have run and passed with full command evidence. The compiled release APK was produced, uploaded to GitHub Actions artifacts, and downloaded locally.

---

## Environment

- **Framework:** Flutter (Channel stable `3.47.7`, Dart `3.7.0`)
- **JDK:** Java Zulu JDK 17
- **Android Toolchain:** AGP `8.9.1`, Gradle `8.14`, `compileSdk = 36`, `targetSdk = 34`, `minSdk = 21`
- **Runner:** Ubuntu GitHub Actions Runner (`ubuntu-latest`)

---

## Quality Gates & Verification Evidence

| Check | Status | Command / Evidence | Notes |
|---|---|---|---|
| **Dependency Resolution** | **PASS** | `flutter pub get` | All dependencies resolved cleanly. |
| **Static Analysis** | **PASS** | `flutter analyze` | 0 errors, 0 warnings across all `lib/` and `test/` code. |
| **Unit & Widget Tests** | **PASS** | `flutter test --coverage` | 12/12 tests passed (100% pass rate). |
| **Release APK Compilation** | **PASS** | `flutter build apk --release` | Successfully assembled release APK via Gradle in 3m 58s. |
| **Artifact Generation** | **PASS** | `actions/upload-artifact@v4` | Artifact `book-tracker-release-apk` uploaded and verified. |
| **Local Artifact Delivery** | **PASS** | `gh run download` | `book-tracker-release.apk` (54MB) present in project directory. |

---

## Test Suite Coverage Summary

1. `test/domain/book_test.dart`
   - Clamping and percentage calculation for page counts (`0.0` to `1.0`).
   - Handling books without pagination (audiobooks, articles).
   - Full JSON round-trip serialization and deserialization.
2. `test/domain/streak_calculator_test.dart`
   - Active streaks across consecutive reading days.
   - Preserving streak across today/yesterday boundaries.
   - Longest historical streak calculation and total reading days.
3. `test/domain/finish_prediction_test.dart`
   - Withholding false-precision estimates when history < 2 sessions (prevents misleading predictions).
   - Accurate estimation when sufficient session pace exists.
4. `test/domain/backup_restore_test.dart`
   - JSON export with valid manifest, record counts, and payload.
   - Manifest validation and corrupt JSON rejection.
5. `test/domain/entitlement_test.dart`
   - Free plan theme gating (Paper & Ink, Forest, AMOLED vs Pro presets).
   - Pro plan access to all 6 themes and advanced analytics.
   - Preservation of core library and export access even after Pro subscription expiry.
6. `test/widget/about_screen_test.dart`
   - Verified developer attribution: **CodeToday**.
   - Verified Facebook button label: **Visit us on Facebook**.
   - Verified target URL: `https://www.facebook.com/share/1FSSXq34an/`.

---

## Automatic Repairs Executed During Audit

1. **CardThemeData Deprecation in Flutter 3.27+:**
   - *Diagnosis:* `CardTheme` in `ThemeData` parameter expected `CardThemeData?`.
   - *Fix:* Replaced `cardTheme: CardTheme(...)` with `cardTheme: CardThemeData(...)` in `app_theme.dart`.
2. **Relative Import Path in ProPaywallDialog:**
   - *Diagnosis:* Referenced `../providers/settings_provider.dart` from `screens/profile/`.
   - *Fix:* Corrected path to `../../providers/settings_provider.dart`.
3. **Unused Variables and Imports:**
   - *Diagnosis:* Unused `sortedDates` in `streak_calculator.dart` and unused `AppConstants` in `profile_screen.dart`.
   - *Fix:* Removed unused tokens.
4. **Android Gradle Plugin & SDK Compatibility:**
   - *Diagnosis:* Dependencies required AGP >= 8.9.1 and compileSdk 36.
   - *Fix:* Configured Gradle 8.14 wrapper, updated `com.android.application` to 8.9.1, and set `compileSdk = 36`.
5. **AAPT Resource Linking:**
   - *Diagnosis:* Missing XML styles (`LaunchTheme`, `NormalTheme`) and vector drawables.
   - *Fix:* Created `styles.xml`, `launch_background.xml`, `colors.xml`, and adaptive vector `ic_launcher` resources.

---

## Artifact Details

- **Local Path:** [`book-tracker-release.apk`](file:///data/data/com.termux/files/home/storage/downloads/AGY%20PROJECTS/book%20tracker/book-tracker-release.apk)
- **Size:** 54 MB (56,054,093 bytes)
- **GitHub Run:** https://github.com/eabgitbd/book-tracker-codetoday/actions/runs/38209852220
- **GitHub Artifact Name:** `book-tracker-release-apk`

---

## Final Recommendation

**Ready for deployment and usage.** The application compiles cleanly, passes all automated tests, and satisfies all requirements set forth in the Product Blueprint and Antigravity Build Auditor.
