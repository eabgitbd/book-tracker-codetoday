# Book Tracker — Product Strategy & Technical Blueprint
## A modern, offline-first digital library by CodeToday

**Document purpose:** A redesigned, implementation-oriented plan based on the original *Book Tracker Blueprint.md*, expanded with product strategy, Free and Pro tiers, UX/UI system, data architecture, synchronization reliability, privacy, monetization, testing, and release planning.

**Product vision:** Make keeping a reading life effortless. The app should feel like a personal library and reading journal—not a spreadsheet—while remaining fast, private, dependable offline, and useful to both casual readers and serious book collectors.

**Developer:** CodeToday  
**Facebook:** https://www.facebook.com/share/1FSSXq34an/

---

# 1. Executive summary

Build a mobile-first book tracker with an offline-first data model, an expressive visual bookshelf, useful reading analytics, rich notes and quotes, reliable backup/restore, and an optional Pro subscription.

The free tier must be a genuinely useful long-term product. Pro should sell convenience, depth, customization, and advanced workflows—not access to a user's own basic data. Users should never lose access to their locally stored library simply because a subscription expires.

## Product principles

1. **Offline first:** Core library actions work without an account or internet connection.
2. **Local ownership:** The device is the primary source of truth; cloud sync is an optional layer.
3. **Beautiful by default:** A clear, editorial interface with carefully controlled decorative details.
4. **Low-friction tracking:** Updating reading progress should take seconds and require minimal typing.
5. **No lock-in:** Users can export and restore their data in documented formats.
6. **Honest monetization:** Clearly explain what is free, what is Pro, renewal terms, and what happens after cancellation.
7. **Accessible and fast:** Readable type, adequate contrast, reduced-motion support, responsive layouts, and graceful performance on mid-range Android devices.
8. **Privacy as a feature:** No silent upload of notes, quotes, reading history, or analytics.

# 2. Analysis of the original blueprint

The source plan establishes a strong starting scope:
- Flutter/Dart, with Drift/SQLite or Isar as the local database and Riverpod for state management.
- A custom bookshelf whose book ordering can reflect recent activity.
- Book metadata, cover photography, progress, notes, quotes, and page references.
- A centrally managed collection of visual themes.
- Google Drive app-data backup, offline export/import, and queued sync.
- OCR quote capture, estimated finish dates, and ambient audio.
- GitHub Actions to build Android APK artifacts.

These are valuable foundations, but the implementation plan needs several additional layers.

## Main gaps and recommended changes

### A. The data model is too small
A single `Book` model with embedded notes does not fully represent reading sessions, multiple editions, reading goals, tags, shelves, reviews, attachments, or sync conflicts. Use related tables and stable IDs.

### B. Progress needs history, not only a current page
A current page can show where the reader is now, but cannot accurately power trends, streaks, reading-time reports, or reliable finish predictions. Record reading sessions and progress events.

### C. Background sync needs failure handling
A five-second debounce is useful for reducing upload frequency, but not enough on its own. Add a durable outbox/change queue, retry with backoff, idempotent operations, schema versions, checksums, conflict resolution, and a visible sync status.

### D. Backup and synchronization are different jobs
A backup is a recoverable snapshot. Sync keeps multiple copies coordinated. Treat them separately, explain their differences, and test restore—not just export.

### E. Theme choice needs a design system
A list of themes is a good concept, but each theme must use the same semantic tokens and component rules. Otherwise screens will look inconsistent and become difficult to maintain.

### F. Monetization and entitlements are absent
The app needs a clear Free/Pro matrix, purchase and restore flows, subscription expiry behavior, and a secure way to verify Pro status. Basic access to personal data must never depend on an active subscription.

### G. Build automation is not release governance
Builds on every push are useful for CI, but signing and public release publication should be separate, controlled steps. Add tests, dependency checks, release tags, protected secrets, and a rollback strategy.

# 3. Target users and jobs to be done

## Primary audiences
- Casual readers who want a simple list of books to read.
- Students and researchers who need page-specific notes and quotes.
- Habit builders who want reading goals and streaks.
- Book collectors who enjoy visual shelves, editions, and cover art.
- Journal-style readers who want reflections, ratings, and memorable passages.
- Readers who prefer offline tools and local control over their data.

## Core jobs
- “Help me remember what I own, have read, and want to read.”
- “Let me update my progress without navigating through many screens.”
- “Help me retrieve a quote or note later.”
- “Show me my reading patterns without making me feel judged.”
- “Let me back up and restore everything confidently.”
- “Make my library feel personal and beautiful.”

# 4. Information architecture and navigation

Use a bottom navigation bar with five destinations on mobile:

1. **Home** — Continue Reading, quick progress update, daily goal, recent activity.
2. **My Library** — All books, filters, sorting, shelves, grid/list/spine layouts.
3. **Insights** — Reading statistics, goals, streaks, trends, and milestones.
4. **Journal** — Notes, quotes, reviews, and reading-session history.
5. **Profile / Settings** — Appearance, backup, sync, data tools, Pro, About.

Use a prominent, consistent **Add Book** action available from Home and Library. Avoid adding a sixth permanent navigation item for settings or search; use a search icon and profile/settings entry.

## Main screens

### Onboarding
- A short three-screen introduction: beautiful library, private offline storage, optional backup.
- Let users start without account creation.
- Offer “Add your first book,” “Import existing data,” and “Explore with sample data.”
- Explain cloud permissions before requesting sign-in.
- Allow skipping personalization and theme selection.

### Home
- Greeting and date, with minimal visual weight.
- “Continue reading” card with cover, current page, progress bar, and one-tap update.
- Daily/weekly goal progress.
- Recently updated books.
- Reading streak and a small milestone, if relevant.
- A quick action menu: Add book, Log session, Scan quote, Add note.
- Empty state that guides users to add their first book without showing fake statistics.

### My Library
- Default polished cover-grid view.
- Optional spine bookshelf view inspired by the original plan.
- Compact list view for users with large collections.
- Filters: status, author, genre, format, rating, tags, collection, year, language.
- Sorting: recently read, recently added, title, author, rating, completion date, manual order.
- Search across title, author, series, ISBN, tags, notes, and quotes where appropriate.
- Multi-select actions: move to shelf, tag, export, archive, or delete with confirmation.

### Book details
- Cover, title, author, series/volume, edition, publisher, publication date, ISBN, language, page count, format.
- Status: Want to Read, Reading, Paused, Read, DNF (Did Not Finish), Archived.
- Current page and percentage; quick increment/decrement and direct page entry.
- Start/completion dates and optional rating.
- Tabs or segmented sections for Overview, Notes & Quotes, Sessions, Reviews, Editions.
- Actions: Edit, log session, add quote, scan page, share a reading card, archive.
- Unknown fields remain optional; do not force users to fill out a bibliographic form.

### Add/edit book
- Quick-add flow first: title, author (optional), page count (optional), status.
- Expandable “More details” section for metadata.
- Add cover from camera, gallery, or file.
- Duplicate detection based on ISBN and a soft match on title/author.
- Support books without page counts (poetry, audiobooks, articles, and other formats).

### Reading session
- Start/end time or duration, pages read, optional note, mood/focus tag.
- Manual logging must remain available; do not require a timer.
- If a timer is used, it must survive navigation and accidental app closure gracefully.
- Prevent impossible page counts and flag inconsistent entries without silently rewriting user data.

### Journal
- Searchable timeline of quotes, notes, reviews, and reading sessions.
- Filters by book, date, tags, and item type.
- Link every quote/note to its source book; page number is optional.
- Support Markdown-lite formatting or a small, safe rich-text subset.
- Export notes and quotes independently.

### Insights
- Books finished by month/year.
- Pages and reading minutes over time.
- Daily and weekly goal completion.
- Current and longest reading streak.
- Genre/author distribution.
- Average rating and completion patterns.
- Estimated finish date when there is enough reading history.
- Insights must explain their time range and data source; never fabricate missing history.

### Settings
- Appearance and themes.
- Reading goals and reminders.
- Local backup, restore, export, and import.
- Google Drive connection and sync status.
- Privacy controls and data deletion.
- Pro subscription and purchase restoration.
- About CodeToday, acknowledgements, licenses, version, and diagnostics export.

# 5. Feature roadmap

## 5.1 Core features — launch essentials
- Local library and offline CRUD (create, read, update, delete).
- Book covers and optional metadata.
- Reading status, current page, page count, and progress.
- Search, filters, sorting, and collections/shelves.
- Notes, quotes, page references, and ratings.
- Reading sessions and basic history.
- Light, dark, and AMOLED-black themes.
- Local export/import and backup verification.
- Data migration and safe deletion.
- Accessible typography, touch targets, and empty/error states.
- About section and Facebook visit button for CodeToday.

## 5.2 High-value additions
- **Fast progress controls:** +1, +5, +10 pages and custom increment.
- **Reading goals:** daily pages, minutes, or sessions; weekly targets.
- **Calendar heatmap:** show logged reading activity, with accessible labels.
- **Smart collections:** e.g. “Currently reading,” “Finished this year,” “Unrated.”
- **Series tracking:** series name, sequence number, and reading order.
- **Multiple formats:** physical, ebook, audiobook, PDF, article, other.
- **Book status and DNF tracking:** normalize reading statuses rather than using ambiguous booleans.
- **Import/export:** versioned JSON backup, CSV for book metadata, Markdown/CSV for notes where feasible.
- **Duplicate detection:** flag likely duplicates and let the user decide.
- **Widgets and shortcuts:** quick-add or progress update where supported by the platform.
- **Reminders:** opt-in and user-scheduled, with quiet hours.
- **Accessibility:** dynamic text scaling, screen reader semantics, contrast checks, reduced motion.
- **Reading cards:** share a selected quote, review, or milestone as an image; sharing must be user initiated.

## 5.3 Advanced features
- **OCR quote capture:** on-device OCR where available; show the extracted text for review before saving.
- **Finish prediction:** calculate from recent sessions and display a confidence/estimate range rather than a false-precision date.
- **Ambient sound player:** optional offline or properly licensed sounds, sleep timer, and automatic stop controls.
- **Reading journal prompts:** optional prompts after a session; never interrupt the reading flow.
- **Book metadata lookup:** optional external lookup with user consent and clear source attribution.
- **Home-screen widgets:** current book, goal progress, or a quick-log action, if supported by the chosen Flutter/platform implementation.
- **Multiple libraries/profiles:** consider only after validating demand; this adds meaningful data and entitlement complexity.
- **Encrypted export:** optional password-protected backup using a well-reviewed cryptographic library and a documented recovery warning.
- **AI-assisted summaries or reflections:** later phase only, with explicit opt-in, clear cost limits, and transparent data handling. Never send private notes to a model without consent.

# 6. Free vs Pro plan

The free tier should be complete enough for everyday use. Pro should provide premium convenience, deeper analysis, and customization.

| Feature | Free | Pro |
|---|---|---|
| Local library and offline access | Unlimited core use | Unlimited |
| Book metadata and covers | Yes | Yes |
| Reading status and page progress | Yes | Yes |
| Search, sorting, basic filters | Yes | Yes, advanced saved filters |
| Notes, quotes, ratings | Core features | Advanced organization and bulk tools |
| Collections/shelves | Core collections | Unlimited/custom smart collections, if a free cap is adopted |
| Basic statistics | Essential stats | Advanced trends, comparisons, richer reports |
| Reading goals and streaks | One active goal and basic streaks | Multiple goals, flexible schedules, deeper history |
| Themes | Light, dark, AMOLED, one or two curated themes | Full theme collection and advanced customization |
| Custom bookshelf layout | Standard grid/list | Advanced spine, shelf styling, layout controls |
| Local export/import | Yes | Yes; never paywall basic portability |
| Manual backup | Yes | Yes |
| Google Drive backup/sync | Optional limited or manual integration, subject to implementation cost | Automatic background sync and advanced backup history |
| OCR quote capture | Limited trial allowance or manual text entry | Higher/unlimited allowance, subject to device performance |
| Finish prediction | Basic estimate when sufficient data exists | Advanced trends and configurable prediction |
| Ambient sounds | A small starter set | Full sound library and more controls |
| Reading cards | Basic templates | Premium themes and customization |
| Advanced exports/reports | Standard formats | Detailed reports and advanced export options |
| App experience | No disruptive full-screen ads recommended | Ad-free |

**Important pricing principle:** Do not promise unlimited cloud sync, OCR, or AI usage until hosting, API, storage, and maintenance costs are understood. If a limit is necessary, display it clearly before the user invests time in the feature.

## Suggested launch policy
- Avoid intrusive ads; they undermine a calm reading experience.
- Keep books, progress, notes, quotes, and local backup/export available even after Pro expires.
- Pro expiry should turn off only premium capabilities; it must not delete data or prevent data export.
- Offer monthly and annual pricing only after testing local purchasing expectations and store fees.
- If lifetime access is ever offered, calculate long-term maintenance costs carefully before promising it.

## Subscription flow requirements
1. Show a comparison page with exact feature differences.
2. Display price, billing period, trial terms (if any), renewal and cancellation details.
3. Use the official store billing flow on supported platforms.
4. Restore purchases on a new device.
5. Handle pending, cancelled, refunded, expired, and grace-period states.
6. Recheck entitlements after app launch and when store state changes.
7. Provide a clear “Manage subscription” route.
8. Never treat a local boolean as authoritative proof of purchase.
9. For Google Play, follow current Play Billing requirements; for other platforms, use the corresponding official purchase flow.
10. Keep the application usable if billing verification is temporarily unavailable, using a safe cached entitlement policy.

# 7. UX/UI and visual design system

## Design direction
**Modern editorial library + quiet productivity + optional vintage warmth.**

The interface should feel premium without being visually busy. Book covers provide color; the surrounding UI should stay calm and legible.

### Recommended default palette
- Background: warm paper `#F7F5EF`
- Surface: `#FFFFFF`
- Primary ink: `#222521`
- Forest green: `#315B48`
- Muted sage: `#DDE6DB`
- Accent amber: `#D39A48`
- Secondary text: `#6B706A`
- Dark background: `#101210`
- Dark surface: `#191D19`
- Dark primary text: `#F4F2EA`

These are initial design tokens, not rigid brand requirements. Verify contrast and adjust in implementation.

### Typography
- Use a highly legible sans-serif for controls, labels, and data.
- Use a restrained serif for book titles, editorial headings, or selected reading-journal details.
- Limit the system to two type families and a consistent scale.
- Support system font scaling and long translated strings.

### Spacing and shapes
- Base spacing unit: 4 dp; use a consistent 4/8/12/16/24/32 scale.
- Use 16–24 dp card radii, but avoid rounding every nested element.
- Keep touch targets approximately 48 dp or larger where practical.
- Use subtle borders and restrained shadows; avoid heavy blur and glow as the default.
- Respect safe areas, keyboard insets, and small-screen widths.

### Motion
- Short, purposeful transitions for opening a book, switching shelves, and updating progress.
- Gentle progress animation, not an endless decorative animation.
- Provide reduced-motion behavior.
- Avoid expensive shader effects on low-end devices; keep decorative rendering optional.

### Theme presets
1. **Paper & Ink** — default warm editorial.
2. **Forest Library** — sage, moss, earthy neutrals.
3. **Midnight / AMOLED** — true-black backgrounds and restrained accent colors.
4. **Vintage Parchment** — sepia paper and bookish serif headings.
5. **Glass Library** — optional translucent surfaces, used sparingly.
6. **Sketch Journal** — doodle-like accents and paper grid, while preserving legibility.

The same components, navigation, and interaction patterns must work in every theme. Themes change tokens and decorative treatments—not core usability.

## Design rules
- Show one dominant action per screen.
- Use progressive disclosure for advanced metadata and settings.
- Prefer clear text labels for important actions; do not rely on icons alone.
- Use skeletons only for network-dependent content; local data should appear quickly.
- Every screen needs empty, loading, error, success, and offline states where relevant.
- Avoid guilt-based streak language. Missed days should not shame the reader.
- Do not make decorative bookshelf mode the only way to access books; provide grid/list alternatives.

# 8. Modern technical architecture

## Recommended stack
- **App:** Flutter and Dart.
- **State management:** Riverpod.
- **Local database:** Drift over SQLite, with migrations and transactions.
- **Routing:** a declarative router such as `go_router`.
- **Preferences:** a small preferences store for non-critical UI settings; database for structured app data.
- **Secure credentials:** platform secure storage for tokens and secrets.
- **Images/files:** app-private directory with explicit cache management.
- **Background work:** platform-appropriate scheduling; do not promise exact execution times on Android.
- **OCR:** on-device ML Kit or a maintained equivalent, isolated behind an interface.
- **Cloud:** Google Drive API as an optional adapter, not a hard dependency of the domain layer.
- **CI/CD:** GitHub Actions with pinned major action versions, tests, artifact retention, and protected signing secrets.

Choose maintained package versions at implementation time; the blueprint should not hard-code unverified “latest” versions.

## Layered architecture

```text
Presentation
  Screens • Widgets • Theme • Routing • Accessibility
          ↓
Application
  Use cases • Commands • Validation • Riverpod providers
          ↓
Domain
  Entities • Value objects • Repository interfaces • Rules
          ↓
Data
  Drift/SQLite • File storage • Sync engine • Import/export
          ↓
Integrations
  Google Drive • OCR • Billing • Notifications • Platform APIs
```

### Architectural rules
- UI widgets must not execute SQL or call Google Drive directly.
- Business rules belong in use cases/domain services.
- External providers are accessed through interfaces and adapters.
- Core library features must work if every network integration fails.
- Keep image decoding, OCR, archive processing, and large exports off the main UI thread when appropriate.
- Use typed failures and actionable user-facing error messages.
- Add dependency injection so repositories can be tested with fakes.

# 9. Data model

Use stable UUIDs or equivalent unique IDs and UTC timestamps internally. Store the user’s display timezone separately where needed.

## Suggested entities/tables

### Book
- `id`
- `title` (required)
- `sortTitle` (optional, for stable alphabetical sorting)
- `subtitle`
- `description`
- `publisher`
- `publicationDate`
- `isbn`
- `languageCode`
- `pageCount` (nullable; must be positive when present)
- `currentPage` (validated against page count where applicable)
- `coverLocalPath`
- `format` (physical, ebook, audiobook, PDF, article, other)
- `status` (wantToRead, reading, paused, read, dnf, archived)
- `rating` (nullable, bounded scale)
- `startedAt`, `completedAt`, `lastReadAt`
- `createdAt`, `updatedAt`, `deletedAt` (nullable tombstone for sync)
- `metadataSource` (optional)
- `schemaVersion` (if required for export records)

Do not require page count for audiobooks, poetry collections without pagination, or other non-page-based material.

### Author and book-author relation
Allow multiple authors, editors, translators, and illustrators rather than a single author string only.

### Edition
- `id`, `bookId`, `isbn`, `publisher`, `publicationDate`, `format`, `pageCount`, `coverPath`, `languageCode`

For the MVP, edition handling can be simplified to optional edition fields on Book, but keep the domain model ready to separate editions later.

### ReadingSession
- `id`, `bookId`
- `startedAt`, `endedAt` or `durationSeconds`
- `startPage`, `endPage`, `pagesRead`
- `sessionNote`, `focusTag`
- `createdAt`

Validate sessions and handle corrections without double-counting totals.

### Note and Quote
- `id`, `bookId`
- `type` (note, quote, reflection)
- `content`
- `pageNumber` (nullable)
- `createdAt`, `updatedAt`
- `tags`
- `sourceType` (typed manually, OCR, imported)
- Optional OCR confidence/source image reference

### Collection
- `id`, `name`, `description`, `sortOrder`, `createdAt`
- Many-to-many book membership
- Optional smart collection rule stored in a validated schema, not executable arbitrary code

### ReadingGoal
- `id`, `goalType` (pages, minutes, sessions, books)
- `targetValue`, `period`, `activeFrom`, `activeTo`, `isActive`

### ReadingEvent / Audit event
Use a lightweight event/history model where needed to explain progress changes and support analytics. Do not turn this into unnecessary event-sourcing complexity for the entire app.

### AppSettings
Theme, layout, font scale, default sort, reminders, goal preferences, privacy settings, and feature preferences.

### Sync metadata
- Remote revision/ETag where available
- Last successful sync timestamp
- Last attempted sync timestamp
- Pending operation count
- Conflict state
- Backup schema version
- Sync cursor or revision
- Last error category (avoid storing secrets or full sensitive payloads)

# 10. Sync, backup, and restore

## Define the difference
- **Local data:** the main copy used by the app.
- **Backup:** a point-in-time recoverable snapshot.
- **Sync:** a process to keep multiple copies coordinated.

## Recommended behavior
1. Commit local changes to SQLite immediately.
2. Add a durable pending operation to the sync outbox in the same transaction.
3. Coalesce rapid edits where safe.
4. Schedule sync when connectivity and platform conditions permit.
5. Use bounded retries with exponential backoff and jitter.
6. Verify remote upload completion and record the new revision/ETag.
7. Never delete the only known-good backup before a replacement is verified.
8. Show last sync time, pending count, and any action required.
9. Offer “Sync now,” “Retry,” “Disconnect,” and “Restore backup.”
10. Keep a visible-file export option as an alternative to hidden Drive app data.

## Conflict handling
- Do not silently overwrite a newer remote record.
- Use timestamps/revisions as signals, not as infallible truth.
- For simple independent fields, merge only when the rule is safe and documented.
- For conflicting edits to notes or book metadata, preserve both versions or ask the user.
- Use tombstones for deletions so removed records do not reappear on another device.
- Make sync idempotent: retrying the same operation must not create duplicates.

## Backup format
Use a versioned archive such as `.booktracker` or `.zip` containing:
- `manifest.json` (format version, app version, creation date, counts, checksum metadata)
- `books.json`
- `authors.json`
- `sessions.json`
- `notes.json`
- `collections.json`
- `settings.json` (exclude secrets)
- `covers/` for referenced local cover images

Requirements:
- Validate file type, archive paths, sizes, schema, and checksums before import.
- Preview record counts before replacing or merging data.
- Offer **Merge** and **Replace** with clear consequences.
- Make a pre-restore backup before destructive replacement.
- Do not include OAuth tokens, purchase tokens, or other secrets.
- Test backups from older schema versions and damaged files.

# 11. Privacy, security, and permissions

- No account required for local-only use.
- Request permissions only when the user invokes a feature that needs them.
- Explain why camera/photo access is needed before the system prompt where possible.
- Store OAuth tokens only in platform secure storage.
- Request the minimum Google Drive scope required by the chosen backup model.
- Do not log book titles, note contents, tokens, or backup payloads to analytics/crash logs by default.
- Keep crash reporting opt-in or privacy-reviewed and redact user content.
- Provide “Export my data,” “Delete local data,” “Disconnect cloud,” and “Delete cloud backup” controls with clear confirmation.
- Encrypt transport using standard platform/network protections.
- If encrypted backups are offered, use a reputable cryptographic implementation; never invent a custom cipher.
- Document what is stored locally, what is uploaded, and what third parties process.
- Avoid collecting data that is not needed for product functionality.

# 12. Search, sorting, and performance

- Use database indexes for frequently queried fields: title, normalized title, status, updated time, author relation, and session date.
- Use full-text search where supported and worthwhile for books, notes, and quotes.
- Debounce interactive search modestly, but ensure the UI remains responsive.
- Paginate large note/session timelines.
- Use thumbnail sizes and image caching for covers.
- Decode and resize camera images before persisting them as covers.
- Provide fallback cover art when an image is missing or corrupt.
- Virtualize long lists and avoid rebuilding the entire bookshelf on every progress update.
- Benchmark with large synthetic libraries, not only a handful of books.

# 13. Analytics and prediction rules

## Core calculations
- Progress percentage: current page divided by page count, clamped to a valid range when page-based.
- Pages read: derive from validated sessions or a consistent progress-history strategy; avoid counting the same pages twice.
- Reading time: sum valid session durations.
- Streak: define the day boundary and timezone explicitly; support grace/goal rules only if clearly communicated.
- Completion date: use explicit status/date changes, not just reaching the final page.
- Finish estimate: use recent reading pace and remaining pages; display “not enough history” when there is insufficient evidence.

## UX safeguards
- Explain why an estimate appears.
- Let the user correct a session.
- Do not punish paused books or DNF books in goal metrics.
- Make date ranges selectable.
- Distinguish “unknown” from zero.
- Avoid false precision in charts.

# 14. About CodeToday

Create a dedicated **About** screen under Profile / Settings.

## Content
- App name and app icon.
- “Developed by CodeToday.”
- Short description: “A personal reading library built to help you organize books, track progress, and keep your reading memories.”
- App version and build number.
- Privacy Policy and Terms links when those pages exist.
- Open-source licenses and acknowledgements.
- Support/contact link when a real contact address is configured.
- **Visit us on Facebook** button.

## Required Facebook button
Label: **Visit us on Facebook**  
Destination: `https://www.facebook.com/share/1FSSXq34an/`

Implementation requirements:
- Open the URL through the operating system’s supported URL launcher.
- If the Facebook app is unavailable, allow opening the link in a browser.
- Use a clearly labeled accessible button with a Facebook icon.
- Do not imply the page is verified or official unless the owner confirms that status.
- Keep the URL in a central link/configuration constant so it can be updated without searching the codebase.

# 15. Monetization implementation

## Entitlement design
Create a centralized `EntitlementService` that answers questions such as:
- Is Pro active?
- Which premium capabilities are enabled?
- When was entitlement last verified?
- Is the current state pending, active, grace, expired, or unknown?

Do not scatter `if (isPro)` checks across arbitrary widgets. UI visibility and feature enforcement should call a shared policy layer.

## Purchase integrity
- Integrate the platform’s supported billing system.
- Validate purchase state using the official store mechanism and, where appropriate, a secure backend.
- Never trust a client-editable preference as proof of purchase.
- Support restore purchases and device changes.
- Avoid storing raw purchase tokens in logs.
- Decide how offline entitlement caching works and document its limitations.

## Expiration
- Keep all user-owned local data accessible.
- Disable only Pro features after the applicable entitlement period ends.
- Preserve existing customizations when possible, but explain if new edits require Pro.
- Allow users to export data at any time.
- Provide clear cancellation and renewal guidance.

# 16. Testing and quality gates

## Unit tests
- Progress calculations and page-count validation.
- Goal/streak calculations across timezone and daylight-saving changes.
- Search normalization and sorting.
- Import/export schema validation.
- Conflict resolution and tombstone behavior.
- Entitlement rules and expiry states.
- Finish prediction with insufficient or irregular data.

## Database tests
- Fresh installation and every migration path.
- Transaction rollback.
- Large libraries.
- Duplicate detection.
- Corrupt or missing cover files.
- Backup restore and merge.

## Integration tests
- Offline create/edit/read/delete.
- Sync interruption and retry.
- Duplicate sync operations.
- Drive permission denial and revoked access.
- OCR failure and permission denial.
- Purchase success, cancellation, pending state, refund/expiry, and restore.
- Deep links and About/Facebook button behavior.

## UI/accessibility tests
- Small and large Android screens.
- Light, dark, AMOLED, and decorative themes.
- Large font sizes and screen readers.
- Keyboard and dialog behavior.
- Reduced motion.
- Empty, loading, offline, and error states.
- Long titles, missing metadata, and right-to-left text if supported.

## Release gates
- Static analysis and formatting pass.
- Unit and integration tests pass.
- No secrets in repository or build logs.
- Dependency and license review.
- Signed release artifact produced only in protected release workflows.
- Backup/restore smoke test passes before each stable release.

# 17. CI/CD and distribution

## Pull request workflow
1. Checkout source.
2. Install a pinned Flutter SDK version.
3. Resolve dependencies reproducibly where possible.
4. Run formatter check and `flutter analyze`.
5. Run unit/widget tests.
6. Build a debug APK or run a build smoke test.
7. Upload test reports and build artifacts.

## Main branch workflow
- Repeat quality gates.
- Build release candidates where appropriate.
- Store artifacts with versioned names and retention policy.

## Release workflow
- Trigger from a protected tag or manual approval.
- Inject Android signing secrets from GitHub Actions secrets.
- Build a signed APK/AAB.
- Verify output and record checksums.
- Publish artifacts or submit to the chosen store through a controlled step.
- Never commit signing keys, passwords, service-account keys, or OAuth secrets.

The original plan’s `flutter build apk --release --split-per-abi` is suitable for producing APK variants for direct distribution. For Google Play distribution, plan for the current store-required bundle and signing process instead of assuming an APK alone is sufficient.

# 18. Phased implementation roadmap

## Phase 0 — Product decisions and prototypes
- Confirm Android-first scope and future platform needs.
- Finalize Free/Pro boundaries and target price model.
- Create screen wireframes and design tokens.
- Define backup guarantees and privacy policy.
- Write acceptance criteria for each MVP feature.

**Exit criteria:** Approved navigation, data model, visual system, and monetization policy.

## Phase 1 — Reliable offline MVP
- Flutter foundation, routing, Riverpod, Drift.
- Onboarding and no-account local mode.
- Add/edit book, cover, statuses, page progress.
- Library grid/list, search, sorting, filters.
- Book details, notes, quotes, ratings.
- Light/dark/AMOLED themes.
- About CodeToday and Facebook link.
- JSON/archive export and validated restore.

**Exit criteria:** A user can create a library, use it fully offline, close/reopen the app, and restore a verified backup.

## Phase 2 — Reading-life features
- Reading sessions and history.
- Goals, streaks, calendar, basic analytics.
- Collections and tags.
- Improved accessibility and performance.
- Reading cards and basic reminders.

**Exit criteria:** Progress and analytics are based on reliable recorded history.

## Phase 3 — Cloud reliability
- Google sign-in and Drive integration.
- Durable outbox, retry, conflict handling, schema versioning.
- Sync status, manual retry, disconnect, restore.
- Multi-device and failure-injection tests.

**Exit criteria:** Interrupted and repeated sync operations do not silently lose or duplicate data.

## Phase 4 — Pro and advanced features
- Billing, entitlement service, restore purchases.
- Premium themes, advanced insights and collections.
- OCR quote capture and prediction enhancements.
- Ambient sound library and premium reading cards.
- Subscription expiry and refund tests.

**Exit criteria:** Purchase lifecycle and data portability work end to end.

## Phase 5 — Release readiness
- Security, accessibility, performance, and migration review.
- Signed release pipeline.
- Privacy policy, terms, support channel, store listing.
- Closed testing and feedback loop.
- Crash triage and release rollback plan.

**Exit criteria:** A tested release can be distributed and maintained safely.

# 19. Recommended MVP priorities

Do not try to ship every feature at once. Build the reliable core first.

### P0 — Required for first useful release
- Offline library and database migrations.
- Book CRUD, status, progress, notes, quotes.
- Search, sorting, cover handling.
- Light/dark/AMOLED themes.
- Backup/export/restore.
- About CodeToday and Facebook button.
- Accessibility, error handling, and tests.

### P1 — High value after MVP
- Sessions, goals, streaks, collections, analytics.
- Google Drive backup and synchronization.
- Pro purchase flow and entitlement service.
- Additional themes and premium customization.

### P2 — Differentiators
- OCR.
- Finish prediction improvements.
- Ambient audio.
- Widgets, smart collections, advanced exports.
- Optional AI features, only after privacy/cost validation.

# 20. Risks and mitigation

| Risk | Mitigation |
|---|---|
| Data loss during restore/sync | Verified snapshots, pre-restore backup, migrations, failure-injection tests |
| Conflicting edits across devices | Durable queue, revision tracking, conflict UI, idempotency |
| Pro feels too restrictive | Keep core tracking and portability free; validate paywall with real users |
| Cloud costs grow unexpectedly | Measure usage, set transparent limits, avoid unlimited promises before costing |
| Performance degrades with large libraries | Indexed queries, pagination, image resizing, benchmark datasets |
| Decorative UI reduces readability | Strong contrast, restrained effects, alternate grid/list layouts |
| Android kills background tasks | Use platform-appropriate scheduling and never promise exact sync timing |
| External APIs change | Adapter interfaces, integration tests, graceful offline fallback |
| OCR misreads text | Show editable extracted text and require user confirmation |
| Subscription state becomes stale | Store billing integration, restore purchases, safe cached entitlement policy |
| Secrets leak in CI | Protected secrets, least privilege, no credentials in source or logs |

# 21. Definition of done

A feature is not complete merely because its screen looks correct. It is complete when:
- Its behavior is defined and testable.
- It works offline where promised.
- It has empty, loading, error, and success states where applicable.
- Data survives app restart and supported migrations.
- Accessibility and theme behavior are verified.
- Destructive actions are reversible or clearly confirmed.
- Analytics and permissions respect privacy choices.
- Documentation and automated tests are updated.

# 22. Final product recommendation

Build **Book Tracker by CodeToday** as an offline-first reading companion with a beautiful, adaptable bookshelf and a dependable personal reading journal.

The strongest order of work is:

1. Nail the offline data model and portability.
2. Make adding books and updating progress effortless.
3. Deliver a coherent, premium-looking interface with accessible theme variants.
4. Add reading history, goals, and useful analytics.
5. Implement cloud sync as a robust optional service.
6. Introduce Pro around advanced customization, analytics, and convenience.
7. Add OCR, ambient sound, prediction, and AI only after the core product is stable.

The key product promise should be simple: **your library is yours, your progress is easy to maintain, and your reading life looks as good as it feels.**
