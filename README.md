# 📚 Book Tracker — by CodeToday

[![Build Book Tracker APK](https://github.com/eabgitbd/book-tracker-codetoday/actions/workflows/build.yml/badge.svg)](https://github.com/eabgitbd/book-tracker-codetoday/actions/workflows/build.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An elegant, offline-first digital library, reading journal, and bookshelf companion for book lovers and researchers.

---

## 🌟 Highlights

* **100% Offline-First:** Core library actions work immediately without accounts, logins, or internet connection.
* **Dynamic Spine Bookshelf:** A real visual bookshelf where book spine thickness and height automatically adapt to the total page count, resting on realistic wooden rails.
* **Low-Friction Progress Tracking:** One-tap `+1`, `+5`, `+10` page updates and quick session logging right from the Home screen.
* **Literary Themes System:** 6 curated design presets:
  1. **Paper & Ink** (Warm editorial paper with forest green & amber accents)
  2. **Forest Library** (Earthy sage, moss tones, and natural surfaces)
  3. **Midnight / AMOLED** (True pure OLED `#000000` with high-contrast accents)
  4. **Vintage Parchment** (Aged sepia paper with warm literary brown accents)
  5. **Glass Library** (Modern slate & indigo tones)
  6. **Sketch Journal** (Pencil slate and quiet journal monochrome)
* **Accurate Reading Analytics & Predictions:** Finish date calculation based on actual historical reading pace—never fabricated.
* **Reading Journal & Quotes:** Page-referenced quotes, notes, and reflections with a shareable reading card generator.
* **Safe Local Backup & Restore:** Versioned JSON format with manifest validation and automatic pre-restore safety snapshot before replacement.
* **Cloud Sync Outbox:** Google Drive integration with durable operation queue, idempotent retries, and transparent status.
* **Ambient Audio:** Relaxing reading atmospheres (Gentle Rain, Old Library, Cozy Fireplace, Parisian Cafe).

---

## 🏗️ Architecture

```text
Presentation Layer
  Screens (Home, Library, Insights, Journal, Profile, About)
  Widgets (BookshelfSpineView, BookCover, ReadingProgressBar, ReadingCard)
  Riverpod State Providers (Books, Sessions, Notes, Settings, DriveSync, Audio)
         ↓
Application / Domain Layer
  Services (EntitlementService, FinishPredictionService, StreakCalculator, BackupRestoreService)
  Models (Book, ReadingSession, BookNote, ReadingGoal, AppSettings, SyncOutboxItem)
         ↓
Data Layer
  Repositories (BookRepository, SessionRepository)
  Sources (LocalStorageSource, CloudDriveAdapter)
```

---

## 📱 Navigation & Features

| Destination | Purpose |
|---|---|
| **Home** | Continue Reading hero card, daily goal progress bar, reading streak, and recently read shelf. |
| **My Library** | Switch between **Cover Grid**, **Dynamic Spine Bookshelf**, and **Compact List**. Full search, status filters, and sorting. |
| **Insights** | Books finished, total pages, reading minutes, finish predictions, and status distribution charts. |
| **Journal** | Searchable timeline of quotes, notes, and reflections with page numbers and shareable cards. |
| **Profile & Settings** | Theme selector, reading goals, JSON backup/restore, Google Drive sync, Pro plan management, and CodeToday attribution. |

---

## 🚀 Building & CI/CD

This repository includes an automated GitHub Actions pipeline (`.github/workflows/build.yml`) that:
1. Runs static analysis (`flutter analyze`).
2. Executes the full unit and widget test suite (`flutter test`).
3. Compiles the release Android APK (`flutter build apk --release`).
4. Uploads the compiled APK artifact directly to the GitHub Actions workflow run for download.

### Local Development

```bash
# Clone the repository
git clone https://github.com/eabgitbd/book-tracker-codetoday.git
cd book-tracker-codetoday

# Get dependencies
flutter pub get

# Run analyzer & tests
flutter analyze
flutter test

# Run app
flutter run
```

---

## 👨‍💻 Developed by CodeToday

* **Developer:** CodeToday
* **Connect on Facebook:** [Visit us on Facebook](https://www.facebook.com/share/1FSSXq34an/) (`https://www.facebook.com/share/1FSSXq34an/`)
