# Book Cover Media, Genre, and Borrowing Management Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enhance Book Tracker by adding 3-source book cover selection (camera capture, file upload, download from web link), genre classification, ownership and borrowing tracking (library/person name, return due date), and direct post-creation/in-library book editing.

**Architecture:** Extend the `Book` domain entity with `genre`, `isOwned`, `borrowedFrom`, `borrowedAt`, and `returnDueDate`. Create a `BookCoverService` handling camera capture, gallery picking, and HTTP image downloading with local file persistence. Update `AddEditBookScreen`, `BookDetailsScreen`, `BookCoverWidget`, and `LibraryScreen` with intuitive UX and responsive badge indicators.

**Tech Stack:** Flutter, Dart, Riverpod, `image_picker: ^1.1.2`, `http: ^1.2.2`, `path_provider`, `intl`.

**Spec:** User request dated 2026-10-12 and Product Blueprint `Book_Tracker_Fresh_Blueprint_CodeToday.md`.

## Global Constraints
- Preserve 100% offline-first functionality; downloaded cover images must be saved locally.
- Backward compatibility: existing JSON backups and libraries without new fields must deserialize safely.
- No regression in test suite or release APK build on GitHub Actions.

---

### Task 1: Dependencies and Android Permissions Setup
**Files:**
- Modify: `pubspec.yaml` (add `image_picker`, `http`)
- Modify: `android/app/src/main/AndroidManifest.xml` (add camera permission)

Steps:
- [ ] Add `image_picker: ^1.1.2` and `http: ^1.2.2` to `pubspec.yaml`.
- [ ] Add `<uses-permission android:name="android.permission.CAMERA"/>` to `android/app/src/main/AndroidManifest.xml`.
- [ ] Verify formatting and manifest validity.

---

### Task 2: Extend `Book` Domain Model & Unit Tests
**Files:**
- Modify: `lib/domain/models/book.dart`
- Modify: `test/domain/book_test.dart`

Steps:
- [ ] Add `genre`, `isOwned`, `borrowedFrom`, `borrowedAt`, `returnDueDate` to `Book` entity.
- [ ] Add helper getters `isBorrowed`, `isReturnOverdue`, `daysUntilReturnDue`.
- [ ] Update `copyWith`, `toJson`, and `fromJson` with safe fallback defaults.
- [ ] Add unit tests in `test/domain/book_test.dart` testing genre, ownership, and due date calculations.

---

### Task 3: Book Cover Picker & Downloader Service
**Files:**
- Create: `lib/core/services/book_cover_service.dart`

Steps:
- [ ] Create `BookCoverService` with:
  - `pickCoverFromCamera()`
  - `pickCoverFromGallery()`
  - `downloadCoverFromUrl(String url)` (downloads image and saves into app private directory)
- [ ] Add URL validation and error handling for failed downloads or invalid images.

---

### Task 4: UI Updates: `AddEditBookScreen`
**Files:**
- Modify: `lib/presentation/screens/library/add_edit_book_screen.dart`

Steps:
- [ ] Add Cover Image Picker section with 3 actions:
  - "Take Photo" (Camera)
  - "Choose from Gallery / Disk" (File)
  - "Download from Web Link" (URL dialog)
- [ ] Show live cover image preview with option to remove or change.
- [ ] Add Genre selector (Popular genre chips + custom input).
- [ ] Add Ownership & Borrowing toggle:
  - Segmented button: "Owned by Me" vs "Borrowed"
  - If Borrowed: Lender name ("Library or Person") and Return Due Date picker.
- [ ] On save: provide SnackBar with an immediate "Edit" action button to allow quick post-creation editing.

---

### Task 5: UI Updates: `BookDetailsScreen` & `BookCoverWidget`
**Files:**
- Modify: `lib/presentation/widgets/book_cover_widget.dart`
- Modify: `lib/presentation/screens/library/book_details_screen.dart`

Steps:
- [ ] Support local file covers and network URL fallbacks in `BookCoverWidget`.
- [ ] Display Genre chip in `BookDetailsScreen`.
- [ ] Display Ownership & Borrowing card:
  - If borrowed: show lender name, due date, countdown chip ("Due in X days" / "Overdue by X days"), and "Mark Returned" quick action.
- [ ] Ensure "Edit Details" app bar action opens `AddEditBookScreen` with all existing data pre-filled.

---

### Task 6: UI Updates: `LibraryScreen` & Filters
**Files:**
- Modify: `lib/presentation/screens/library/library_screen.dart`

Steps:
- [ ] Add Genre and Ownership filter options.
- [ ] Display borrowed status badge on book cards/list tiles.

---

### Task 7: Verification, Test Suite & GitHub Actions CI Build
**Files:**
- Modify: `test/domain/book_test.dart`
- GitHub Actions: push to `main` and verify workflow run produces signed release APK.

Steps:
- [ ] Run git commit & push.
- [ ] Monitor GitHub Actions workflow run `Build Book Tracker APK`.
- [ ] Confirm tests pass and release APK artifact is compiled.
