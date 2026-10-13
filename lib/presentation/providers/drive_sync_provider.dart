import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/sources/cloud_drive_adapter.dart';
import '../../domain/models/sync_outbox_item.dart';
import '../../domain/services/backup_restore_service.dart';
import 'book_provider.dart';
import 'session_provider.dart';
import 'journal_provider.dart';
import 'settings_provider.dart';

class DriveSyncState {
  final bool isConnected;
  final String? accountEmail;
  final String? accountDisplayName;
  final String? accountPhotoUrl;
  final bool isSyncing;
  final bool isRestoring;
  final int pendingCount;
  final String? lastError;
  final DateTime? lastSyncTime;
  final String? lastSyncMessage;

  const DriveSyncState({
    this.isConnected = false,
    this.accountEmail,
    this.accountDisplayName,
    this.accountPhotoUrl,
    this.isSyncing = false,
    this.isRestoring = false,
    this.pendingCount = 0,
    this.lastError,
    this.lastSyncTime,
    this.lastSyncMessage,
  });

  DriveSyncState copyWith({
    bool? isConnected,
    String? accountEmail,
    String? accountDisplayName,
    String? accountPhotoUrl,
    bool? isSyncing,
    bool? isRestoring,
    int? pendingCount,
    String? lastError,
    bool clearLastError = false,
    DateTime? lastSyncTime,
    String? lastSyncMessage,
  }) {
    return DriveSyncState(
      isConnected: isConnected ?? this.isConnected,
      accountEmail: accountEmail ?? this.accountEmail,
      accountDisplayName: accountDisplayName ?? this.accountDisplayName,
      accountPhotoUrl: accountPhotoUrl ?? this.accountPhotoUrl,
      isSyncing: isSyncing ?? this.isSyncing,
      isRestoring: isRestoring ?? this.isRestoring,
      pendingCount: pendingCount ?? this.pendingCount,
      lastError: clearLastError ? null : (lastError ?? this.lastError),
      lastSyncTime: lastSyncTime ?? this.lastSyncTime,
      lastSyncMessage: lastSyncMessage ?? this.lastSyncMessage,
    );
  }
}

class DriveSyncNotifier extends StateNotifier<DriveSyncState> {
  final CloudDriveAdapter _adapter;
  final Ref _ref;

  DriveSyncNotifier(this._ref, {CloudDriveAdapter? adapter})
      : _adapter = adapter ?? CloudDriveAdapter(),
        super(const DriveSyncState()) {
    _init();
  }

  Future<void> _init() async {
    final storage = _ref.read(localStorageSourceProvider);
    final outbox = await storage.loadOutbox();
    final settings = _ref.read(settingsProvider);

    // Initial state from settings
    state = state.copyWith(
      pendingCount: outbox.length,
      lastSyncTime: settings.lastDriveSyncTime,
      isConnected: settings.isDriveSyncEnabled,
    );

    // Try silent sign in if user previously enabled Drive sync
    if (settings.isDriveSyncEnabled) {
      final restored = await _adapter.signInSilently();
      if (restored) {
        state = state.copyWith(
          isConnected: true,
          accountEmail: _adapter.userAccount,
          accountDisplayName: _adapter.displayName,
          accountPhotoUrl: _adapter.photoUrl,
        );
      }
    }
  }

  /// Interactive sign in with Google
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isSyncing: true, clearLastError: true);
    try {
      final account = await _adapter.signIn();
      if (account != null) {
        await _ref.read(settingsProvider.notifier).toggleDriveSync(true);
        state = state.copyWith(
          isConnected: true,
          accountEmail: account.email,
          accountDisplayName: account.displayName,
          accountPhotoUrl: account.photoUrl,
          isSyncing: false,
          lastSyncMessage: 'Connected as ${account.email}',
        );
        // Automatically perform first sync upon connecting
        await triggerSync();
        return true;
      } else {
        state = state.copyWith(
          isSyncing: false,
          lastError: 'Google Sign-In was cancelled.',
        );
        return false;
      }
    } catch (e) {
      final rawError = e.toString();
      String errText;
      if (rawError.contains('10') || rawError.contains('sign_in_failed')) {
        errText = 'Google Sign-In Error 10 (Developer Error):\n'
            'Detail: $rawError\n\n'
            'Checklist:\n'
            '1. In Google Cloud Console, check if your Android Client has package "com.codetoday.booktracker"\n'
            '2. Confirm SHA-1: 7F:3E:8E:54:0D:8D:60:78:47:87:06:23:3E:B1:DF:86:84:B3:A5:54\n'
            '3. Check OAuth Consent Screen: Add your email to "Test users"\n'
            '4. Try clearing Google Play Services cache if newly added.';
      } else {
        errText = 'Sign-in error: $rawError';
      }
      state = state.copyWith(
        isSyncing: false,
        lastError: errText,
      );
      return false;
    }
  }

  /// Disconnect Google Account
  Future<void> disconnect() async {
    await _adapter.disconnectAccount();
    await _ref.read(settingsProvider.notifier).toggleDriveSync(false);
    state = const DriveSyncState();
  }

  /// Full backup sync to Google Drive
  Future<bool> triggerSync() async {
    if (state.isSyncing) return false;
    state = state.copyWith(isSyncing: true, clearLastError: true);

    try {
      final books = _ref.read(booksProvider);
      final sessions = _ref.read(sessionsProvider);
      final notes = _ref.read(notesProvider);
      final settings = _ref.read(settingsProvider);

      final backupJson = BackupRestoreService.createBackupJson(
        books: books,
        sessions: sessions,
        notes: notes,
        settings: settings,
      );

      final result = await _adapter.uploadBackup(backupJson);

      if (result.success) {
        final storage = _ref.read(localStorageSourceProvider);
        await storage.saveOutbox([]);
        await _ref.read(settingsProvider.notifier).recordSyncCompleted();

        state = state.copyWith(
          isSyncing: false,
          pendingCount: 0,
          lastSyncTime: result.syncTime,
          lastSyncMessage: 'Library synced to Google Drive successfully',
        );
        return true;
      } else {
        state = state.copyWith(
          isSyncing: false,
          lastError: result.errorMessage ?? 'Drive sync failed',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSyncing: false,
        lastError: 'Sync error: ${e.toString()}',
      );
      return false;
    }
  }

  /// Restore library data from Google Drive
  Future<BackupPayload?> restoreFromDrive() async {
    if (state.isRestoring) return null;
    state = state.copyWith(isRestoring: true, clearLastError: true);

    try {
      final backupJson = await _adapter.downloadBackup();
      if (backupJson == null || backupJson.trim().isEmpty) {
        state = state.copyWith(
          isRestoring: false,
          lastError: 'No backup found in your Google Drive AppData folder.',
        );
        return null;
      }

      final validation = BackupRestoreService.validateBackupJson(backupJson);
      if (!validation.isValid) {
        state = state.copyWith(
          isRestoring: false,
          lastError: 'Invalid Drive backup: ${validation.errorMessage}',
        );
        return null;
      }

      // Save pre-restore safety snapshot of local data
      final currentBooks = _ref.read(booksProvider);
      final currentSessions = _ref.read(sessionsProvider);
      final currentNotes = _ref.read(notesProvider);
      final currentSettings = _ref.read(settingsProvider);
      final snapshotJson = BackupRestoreService.createBackupJson(
        books: currentBooks,
        sessions: currentSessions,
        notes: currentNotes,
        settings: currentSettings,
      );
      await _ref.read(localStorageSourceProvider).savePreRestoreSnapshot(snapshotJson);

      // Parse payload and restore
      final payload = BackupRestoreService.parseBackupPayload(backupJson);

      final bookRepo = _ref.read(bookRepositoryProvider);
      final sessionRepo = _ref.read(sessionRepositoryProvider);

      for (final book in payload.books) {
        await bookRepo.saveBook(book);
      }
      for (final session in payload.sessions) {
        await sessionRepo.addSession(session);
      }
      for (final note in payload.notes) {
        await sessionRepo.addNote(note);
      }

      // Refresh providers
      await _ref.read(booksProvider.notifier).loadBooks();
      await _ref.read(sessionsProvider.notifier).loadSessions();
      await _ref.read(notesProvider.notifier).loadNotes();

      final now = DateTime.now();
      await _ref.read(settingsProvider.notifier).recordSyncCompleted();

      state = state.copyWith(
        isRestoring: false,
        lastSyncTime: now,
        lastSyncMessage:
            'Restored ${payload.books.length} books, ${payload.sessions.length} sessions, and ${payload.notes.length} notes.',
      );

      return payload;
    } catch (e) {
      state = state.copyWith(
        isRestoring: false,
        lastError: 'Restore failed: ${e.toString()}',
      );
      return null;
    }
  }

  Future<void> queueSyncItem(SyncOutboxItem item) async {
    final storage = _ref.read(localStorageSourceProvider);
    final outbox = await storage.loadOutbox();
    outbox.add(item);
    await storage.saveOutbox(outbox);
    state = state.copyWith(pendingCount: outbox.length);
  }
}

final driveSyncProvider =
    StateNotifierProvider<DriveSyncNotifier, DriveSyncState>((ref) {
  return DriveSyncNotifier(ref);
});
