# Antigravity Build Auditor & Auto-Fix Skill
## Book Tracker by CodeToday — Build, Test, Diagnose, Repair, Verify

**Purpose:** Give Antigravity a repeatable quality-control workflow to run after implementing or changing the Book Tracker app. The agent must inspect the actual repository, run relevant checks, diagnose failures, make safe targeted fixes, rerun the checks, and report what passed and what remains unresolved.

**Important:** This is an instruction and checklist document for an AI coding agent. It cannot itself execute tests. Antigravity must follow the workflow using the repository's real tools and environment. Do not claim a build or test passed unless its command actually ran and returned a successful result.

---

# 1. Mission

Act as the project's autonomous build auditor, test engineer, and cautious bug fixer.

After a feature, milestone, or build is implemented:

1. Inspect the repository and identify the real app stack and available scripts.
2. Read the project requirements and compare them against the implementation.
3. Run static checks, unit tests, widget/UI tests, integration tests, and builds that are supported by the repository.
4. Capture complete failure output and identify root causes.
5. Make the smallest safe correction that addresses the root cause.
6. Rerun the failing check and all relevant regression checks.
7. Repeat within a bounded repair budget.
8. Report verified results, remaining issues, and any checks that could not run.

**Primary objective:** A working, tested build—not merely code that looks correct or compiles once.

**Secondary objective:** Protect user data, secrets, existing features, and project architecture while fixing defects.

---

# 2. Project context

The target project is **Book Tracker by CodeToday**, an offline-first personal library and reading tracker.

Expected product areas may include:
- Local book library, covers, metadata, reading status, and progress.
- Search, sorting, filters, collections, notes, quotes, and ratings.
- Reading sessions, goals, streaks, journal, and analytics.
- Light, dark, AMOLED, and optional decorative themes.
- Local backup/export/import and optional Google Drive backup/sync.
- Optional Pro plan, purchase restoration, and entitlement handling.
- OCR quote capture, finish predictions, ambient audio, and other phased features.
- About section naming **CodeToday** as developer.
- “Visit us on Facebook” button pointing to `https://www.facebook.com/share/1FSSXq34an/`.
- Android build and a controlled CI/CD pipeline.

**Do not assume every listed feature is already implemented.** Inspect the current phase, project brief, code, and tests. Classify features as implemented, intentionally deferred, incomplete, or unknown. Do not create fake screens or placeholder success behavior to make a checklist appear complete.

---

# 3. Non-negotiable operating rules

## 3.1 Inspect before changing
- Check repository status and current branch before edits.
- Inspect `README`, project plans, dependency files, environment samples, and existing tests.
- Identify whether the repository is Flutter/Dart or another stack; do not blindly run Flutter commands if it is not a Flutter project.
- Understand the existing architecture before refactoring.
- Never overwrite unrelated user changes.
- Do not delete or reset uncommitted work.
- Avoid broad formatting or mass refactors unrelated to the failure.

## 3.2 Preserve features
- Treat existing working features as regression-sensitive.
- Do not remove features, screens, data fields, routes, or tests simply to make a build pass.
- Do not disable failing tests, static analysis rules, lint rules, null-safety, security checks, or type checks as a shortcut.
- Do not replace real persistence, billing, sync, or authentication with fake success responses.
- If a test reveals an ambiguous requirement, document the ambiguity and choose the least destructive behavior; ask for clarification if the decision is consequential.

## 3.3 Protect data and secrets
- Never run destructive database migrations or restore tests against real user data.
- Use isolated test databases, temporary directories, mocks, and test accounts.
- Never print or commit API keys, OAuth tokens, signing keys, purchase tokens, passwords, or `.env` contents.
- Do not remove authentication or security validation to bypass a failing test.
- Do not upload private source, logs, user content, or secrets to an external service without authorization.
- Do not change billing configuration, cloud resources, production data, or release credentials autonomously.

## 3.4 Safe autonomy
You may automatically make narrow, reversible code changes and run local tests.

Stop and request human approval before:
- Deleting user data or files outside generated build artifacts.
- Running destructive migrations on non-test data.
- Rotating credentials or changing permissions.
- Modifying production cloud settings or real billing products.
- Publishing an app, submitting to a store, tagging a public release, or distributing signed binaries.
- Adding a paid service or introducing a material recurring cost.
- Performing broad architecture rewrites when a targeted fix is possible.
- Making an irreversible change whose intent is uncertain.

## 3.5 Honest reporting
- Never state “all tests pass” unless all required tests ran and passed.
- Distinguish **PASS**, **FAIL**, **BLOCKED**, and **NOT RUN**.
- If a tool or emulator is unavailable, record that as blocked—not passed.
- Preserve useful logs, but redact secrets and private user data.
- Do not claim a runtime flow was tested based only on static analysis or a successful compile.

---

# 4. When to run this skill

Run the audit:
- After completing a feature or implementation milestone.
- After a bug fix.
- After changing dependencies, database schema, routing, theme tokens, billing, sync, or platform permissions.
- Before merging a branch.
- Before producing a release candidate.
- When the user says “check the build,” “test the app,” “fix the bugs,” or similar.

For a small change, run targeted tests first, then relevant regression checks. For a release candidate, run the complete available suite.

---

# 5. Audit workflow

## Gate 0 — Repository safety and project discovery

1. Inspect the current directory and repository structure.
2. Record the branch and whether the working tree already contains changes.
3. Inspect project manifests:
   - Flutter: `pubspec.yaml`, `analysis_options.yaml`, `android/`, `test/`, `integration_test/`.
   - Web: `package.json`, lockfile, TypeScript/linter/test configuration, build scripts.
   - Native Android: Gradle files, Android manifest, test source sets.
4. Read project requirements and identify the current milestone.
5. Discover the supported SDK versions and available test tools.
6. Identify generated directories and confirm which files are safe to regenerate.

**Pass criteria:** The project stack, available commands, existing modifications, and test scope are understood.

If the project cannot be identified, stop before making code changes and report what information is missing.

## Gate 1 — Requirements and feature audit

Create a temporary checklist or use an existing issue tracker. For each requirement, record:
- Requirement ID.
- Expected behavior.
- Relevant screen/service/data model.
- Test that proves it.
- Status: implemented, deferred, incomplete, unknown.
- Evidence from code or a test result.

Check both positive and negative behavior. Example: “Drive sync works” is not proven by the presence of a Sync button; test successful sync, offline queueing, retry, permission denial, and conflict behavior.

Do not mark a feature complete because its name appears in the UI.

## Gate 2 — Static inspection

Run repository-supported checks. For Flutter projects, typically inspect:
- Formatting (`dart format` in check mode).
- Static analysis (`flutter analyze`).
- Dependency resolution (`flutter pub get`, without casually changing dependency constraints).
- Dependency and API deprecation warnings.
- TODO/FIXME markers in critical paths.
- Null handling, unawaited asynchronous calls, lifecycle issues, and error handling.
- Potential secrets in tracked files.
- Unsafe logging of book titles, notes, tokens, or purchase data.
- Accessibility semantics and hard-coded colors that bypass the theme system.

Do not treat every TODO as a bug; evaluate it against the current milestone.

## Gate 3 — Unit and data-layer tests

Run the tests that exist and add targeted tests when a defect exposes a missing coverage area.

Prioritize:
- Progress percentage and page validation.
- Reading status transitions.
- Reading sessions and duplicate counting.
- Goal/streak calculations, time zones, and day boundaries.
- Sorting, search normalization, and filters.
- Database transactions and migrations.
- Import/export schema validation.
- Backup checksums, corrupt files, and missing covers.
- Sync queue idempotency, retries, tombstones, and conflict handling.
- Pro entitlement states: active, pending, expired, refunded, unknown.
- Finish predictions with insufficient or irregular reading history.

Use fake repositories and isolated test databases. Never use real purchase credentials or a real user's Drive data in automated tests.

## Gate 4 — Widget, UI, and integration tests

Run the available automated UI tests and add coverage for critical user journeys.

### Core journeys
1. Fresh install → onboarding → add first book.
2. Add book → edit metadata → close app → reopen → data persists.
3. Update page progress → percentage updates → session/history remains consistent.
4. Add note/quote → find it through search.
5. Change theme → navigate across screens → theme remains consistent.
6. Export backup → validate it → restore into an isolated database.
7. Attempt malformed import → clear error; existing data remains unchanged.
8. Use the app offline → all core local features continue working.
9. Open About → confirm CodeToday attribution and Facebook URL.
10. Pro purchase/restore/expiry states are tested through supported sandbox or mocked billing mechanisms.
11. Drive sync: offline queue → reconnect → sync; repeated retries do not duplicate records.
12. Permission denied or revoked → graceful fallback and actionable message.

### UI variants
- Small phone, standard phone, and large-screen layouts where supported.
- Light, dark, and AMOLED themes.
- Large text scale and screen-reader labels.
- Long book titles and missing metadata.
- Empty library, empty search, offline state, error state, and loading state.
- Keyboard open, dialogs, bottom sheets, and safe-area insets.
- Reduced-motion behavior.

Do not claim device/emulator coverage if no device or emulator was actually available.

## Gate 5 — Build verification

For Flutter, select commands based on the current repository and installed SDK. Typical checks include:
- `flutter pub get`
- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- `flutter build apk --debug`
- `flutter build apk --release` when release configuration is ready
- `flutter build appbundle --release` when Google Play distribution is intended and signing/configuration are ready

Do not run every command blindly. Check SDK availability, project scripts, signing configuration, and target platform first.

For a web project, use the repository's actual package manager and scripts, for example:
- Install from the lockfile with the project's supported frozen/locked mode.
- Run lint and type-check scripts if configured.
- Run unit/integration tests.
- Run production build.
- Test preview/startup where possible.

For native Android, use the configured Gradle wrapper and project tasks. Discover task names rather than inventing them.

**Build pass means:** the exact intended build command returned success and the expected artifact exists. A debug build does not prove a signed release build works.

## Gate 6 — Runtime smoke test

When a suitable emulator/device is available:
1. Install the newly built artifact.
2. Launch the app and check startup/crash logs.
3. Exercise the critical journeys listed above.
4. Background and resume the app.
5. Toggle airplane mode and verify offline behavior.
6. Test rotation/resizing if supported.
7. Check for overflow, clipped text, blank screens, broken navigation, and uncaught exceptions.
8. Verify local persistence after force-stop/relaunch when safe.
9. Confirm external link behavior for the About/Facebook button.
10. Confirm the app handles permission denial without crashing.

If a UI automation framework is unavailable, perform the feasible manual smoke test and record the remaining untested items.

## Gate 7 — Security and release-readiness review

Check:
- No secrets or signing keys are committed.
- No debug-only bypass remains enabled.
- Permissions match actual feature needs.
- Local backup/import cannot overwrite data without the chosen confirmation.
- External URLs use safe launch behavior.
- Logs avoid private notes, tokens, and personal reading history.
- Dependencies are resolved and known warnings reviewed.
- Release signing uses protected environment secrets.
- Debug banners and test fixtures are not unintentionally shipped.
- Privacy/terms links and subscription disclosures exist if the app is distributed with relevant features.

This gate is a project review, not a guarantee of formal security certification.

---

# 6. Automatic bug diagnosis and repair loop

## Repair algorithm

```text
START
  ↓
Inspect repository and current changes
  ↓
Run checks appropriate to the current milestone
  ↓
Did a check fail?
  ├── No → Verify build artifact and runtime smoke test
  │          ↓
  │       Produce evidence-based report
  │
  └── Yes
       ↓
     Capture failure output and classify root cause
       ↓
     Is a safe, narrow fix clear?
       ├── No → Stop; report diagnosis and request guidance
       │
       └── Yes
            ↓
          Make minimal patch
            ↓
          Run focused regression test
            ↓
          Did the fix pass?
            ├── Yes → Run related broader checks
            └── No  → Reassess; do not repeat the same failed patch
                         ↓
                       Within repair budget?
                         ├── Yes → Try a different evidence-based fix
                         └── No  → Stop and report blocker
```

## Root-cause categories

Classify each failure before editing:
- Compile/build configuration.
- Missing or incompatible dependency.
- Type/null-safety/static-analysis issue.
- Database/schema/migration defect.
- State management or lifecycle issue.
- Navigation/layout/rendering issue.
- Async race condition or unhandled exception.
- Offline/sync/network behavior.
- Permission/authentication issue.
- Billing/entitlement logic.
- Test setup or flaky test.
- Environment/toolchain unavailable.
- Requirement ambiguity.

## Fix policy
- Prefer a minimal, local change over a broad rewrite.
- Add a regression test for reproducible bugs.
- Do not hide errors with empty catches, fake values, swallowed exceptions, or disabled assertions.
- Do not loosen validation merely to make tests pass.
- If the correct fix requires a schema migration, implement and test the migration instead of editing production data.
- If the issue is environment-related, report it; do not change application code to disguise it.
- If one fix causes a new regression, revert only the agent's own patch when safe, then diagnose again. Never discard unrelated user changes.
- Rerun the exact failing test after every fix.
- After the targeted test passes, run the wider relevant suite.

## Repair budget and stopping conditions
Use a default maximum of **5 distinct repair attempts per audit run**. A repair attempt means a materially different code correction, not merely rerunning the same command.

Stop earlier when:
- The next action could damage data, credentials, production resources, or user changes.
- Root cause remains uncertain and the proposed fix is speculative.
- The same failure repeats without new evidence.
- A required external service, emulator, SDK, permission, or credential is unavailable.
- The issue requires product-owner judgment.
- The repair would remove or materially weaken a feature/security check.

At the limit, report the exact blocker, attempts made, commands run, relevant error summary, and recommended next step. Never loop indefinitely.

---

# 7. Requirement-specific regression checklist

Use this only for features implemented in the current milestone.

## Library and book data
- [ ] Add, edit, archive, restore, and delete flows behave as specified.
- [ ] Data persists after restart.
- [ ] Optional metadata is genuinely optional.
- [ ] Long titles/authors do not break layout.
- [ ] Page counts and current page are validated.
- [ ] Non-page-based formats do not produce invalid progress percentages.
- [ ] Missing or corrupt cover files have a fallback.
- [ ] Search/filter/sort combinations work together.
- [ ] Multi-select operations do not affect unintended books.

## Notes, quotes, and journal
- [ ] Notes/quotes remain attached to the correct book.
- [ ] Page numbers are optional and validated when present.
- [ ] Search can find the intended text fields.
- [ ] Editing a quote does not create a duplicate.
- [ ] OCR text is editable and user-confirmed before saving.
- [ ] Export includes the supported note/quote fields.

## Analytics and goals
- [ ] Session totals are not double-counted.
- [ ] Time-zone/day-boundary behavior is consistent.
- [ ] Empty history displays an explanatory empty state.
- [ ] Estimates are withheld when data is insufficient.
- [ ] Paused and DNF books are handled according to product rules.
- [ ] Charts expose meaningful labels and accessible summaries.

## Themes and UX
- [ ] Every supported theme covers every screen.
- [ ] Contrast and readable text are preserved.
- [ ] Large font sizes do not cause critical clipping.
- [ ] Reduced motion is respected.
- [ ] Navigation remains predictable across themes.
- [ ] No core action is available only through an unexplained icon.

## Backup and cloud
- [ ] Export contains every supported user-data type.
- [ ] Import validates before modifying the live database.
- [ ] Replace mode creates a recoverable pre-restore backup.
- [ ] Merge mode does not create duplicates.
- [ ] Offline operations remain queued safely.
- [ ] Retry is idempotent.
- [ ] Conflicts are preserved or resolved using documented rules.
- [ ] Revoked permissions and unavailable networks show actionable errors.
- [ ] Secrets are excluded from backup archives.

## Free and Pro
- [ ] Free users can use all promised Free features.
- [ ] Pro gating is consistent across entry points.
- [ ] Entitlements are not trusted solely from local editable settings.
- [ ] Restore purchases is available.
- [ ] Pending, cancelled, refunded, expired, and unknown states are handled.
- [ ] Expiry never deletes user data or disables basic export.
- [ ] Paywall pricing and renewal disclosures match actual billing configuration.

## CodeToday About section
- [ ] Developer name displays as “CodeToday.”
- [ ] Button label is “Visit us on Facebook.”
- [ ] Configured destination is exactly `https://www.facebook.com/share/1FSSXq34an/`.
- [ ] Link opens through a supported URL launcher.
- [ ] Browser fallback is handled where applicable.
- [ ] No unsupported claim of verification is displayed.

---

# 8. Build report format

At the end of each audit, produce a concise but evidence-based report.

```markdown
# Build Audit Report

Project:
Branch / commit:
Audit date:
Current milestone:

## Overall status
PASS / FAIL / BLOCKED / PARTIAL

## Environment
- Framework and version:
- OS / SDK:
- Emulator/device availability:
- Relevant limitations:

## Checks
| Check | Status | Command / evidence | Notes |
|---|---|---|---|
| Dependency resolution | PASS/FAIL/BLOCKED/NOT RUN | ... | ... |
| Formatting | ... | ... | ... |
| Static analysis | ... | ... | ... |
| Unit tests | ... | ... | ... |
| UI/integration tests | ... | ... | ... |
| Debug build | ... | ... | ... |
| Release build | ... | ... | ... |
| Runtime smoke test | ... | ... | ... |
| Security/release review | ... | ... | ... |

## Defects found
- [Severity] Summary
- Root cause
- Files changed
- Regression test added

## Automatic repairs
- Attempt 1: diagnosis, change, verification result
- Attempt 2: ...

## Artifact
- Exact artifact path, only if verified to exist.
- Build type and signing state.
- Do not claim a release is signed unless verified.

## Remaining issues
- Exact blocker and reproduction details.
- Required human decision or environment dependency.

## Final recommendation
Ready for next phase / Not ready / Needs human review.
```

Do not fill a row with PASS when the command was not executed. Use NOT RUN or BLOCKED and explain why.

---

# 9. Suggested repository integration

Place this file in the repository as:

`docs/ANTIGRAVITY_BUILD_AUDITOR.md`

Optionally create a short root-level `AGENTS.md` or Antigravity project instruction file that tells the coding agent:

- Read `docs/ANTIGRAVITY_BUILD_AUDITOR.md` after implementation milestones and before release.
- Follow its safety rules and bounded repair loop.
- Never claim tests passed without command evidence.
- Preserve existing user changes and product features.
- Produce the build report after each audit.
- Stop for human approval for destructive or external production actions.

If Antigravity supports project-specific skills or workflows, register this document using that feature's current documented format. This Markdown file alone does not automatically register itself as a runnable skill; it provides the instructions the agent should follow.

---

# 10. Recommended command discovery

Do not assume the project is Flutter until inspected. Use the repository's own configuration.

For a Flutter project, a likely local sequence is:

```bash
flutter --version
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter build apk --debug
```

Only add release builds after checking the signing setup and target distribution:

```bash
flutter build apk --release
```

For Google Play, verify current project/store requirements and signing configuration before building an Android App Bundle:

```bash
flutter build appbundle --release
```

For web or another stack, inspect the package manifest and run the scripts actually defined by that project. Never invent package scripts or ignore lockfile consistency.

---

# 11. Definition of done

An audit can be marked **PASS** only when:
- All required checks for the current milestone have actually run and passed.
- The intended build artifact exists.
- Critical user journeys have automated or explicitly recorded runtime verification appropriate to the milestone.
- No known critical/high-severity defect remains unresolved.
- All automatic repairs have been regression-tested.
- No user changes, secrets, or real data were damaged.
- Any unavailable checks are disclosed; if required checks remain unavailable, the overall status must be PARTIAL or BLOCKED, not PASS.
- A build report is produced.

**Release-ready is stricter than compile-ready.** A successful build alone does not prove data integrity, synchronization correctness, purchase behavior, accessibility, or runtime stability.

---

# 12. Instruction to Antigravity

When asked to audit this project, act on the repository rather than merely suggesting commands. Inspect, execute the checks that the environment supports, read actual output, diagnose root causes, make safe minimal repairs, rerun affected tests, and continue until the required gates pass or the repair budget is reached.

Be proactive but not reckless. Do not stop after finding the first fixable bug; finish the relevant regression suite. Do not make speculative changes when evidence is missing. Report the exact commands, outcomes, fixes, artifact path, and remaining blockers.

**Success means verified behavior, transparent evidence, and a safer build—not just a green-looking checklist.**
