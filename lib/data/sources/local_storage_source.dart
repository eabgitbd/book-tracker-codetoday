import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/book.dart';
import '../../domain/models/reading_session.dart';
import '../../domain/models/book_note.dart';
import '../../domain/models/app_settings.dart';
import '../../domain/models/sync_outbox_item.dart';

class LocalStorageSource {
  static const String _keyBooks = 'bt_books_v1';
  static const String _keySessions = 'bt_sessions_v1';
  static const String _keyNotes = 'bt_notes_v1';
  static const String _keySettings = 'bt_settings_v1';
  static const String _keyOutbox = 'bt_outbox_v1';
  static const String _keySafetySnapshot = 'bt_safety_snapshot_v1';

  final SharedPreferences? _prefs;

  LocalStorageSource([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    return _prefs ?? await SharedPreferences.getInstance();
  }

  // Books
  Future<List<Book>> loadBooks() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyBooks);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBooks(List<Book> books) async {
    final prefs = await _getPrefs();
    final list = books.map((b) => b.toJson()).toList();
    await prefs.setString(_keyBooks, jsonEncode(list));
  }

  // Sessions
  Future<List<ReadingSession>> loadSessions() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keySessions);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => ReadingSession.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveSessions(List<ReadingSession> sessions) async {
    final prefs = await _getPrefs();
    final list = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_keySessions, jsonEncode(list));
  }

  // Notes & Quotes
  Future<List<BookNote>> loadNotes() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyNotes);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => BookNote.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveNotes(List<BookNote> notes) async {
    final prefs = await _getPrefs();
    final list = notes.map((n) => n.toJson()).toList();
    await prefs.setString(_keyNotes, jsonEncode(list));
  }

  // Settings
  Future<AppSettings> loadSettings() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keySettings);
    if (jsonStr == null || jsonStr.isEmpty) return const AppSettings();
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keySettings, jsonEncode(settings.toJson()));
  }

  // Sync Outbox
  Future<List<SyncOutboxItem>> loadOutbox() async {
    final prefs = await _getPrefs();
    final jsonStr = prefs.getString(_keyOutbox);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list.map((e) => SyncOutboxItem.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveOutbox(List<SyncOutboxItem> outbox) async {
    final prefs = await _getPrefs();
    final list = outbox.map((o) => o.toJson()).toList();
    await prefs.setString(_keyOutbox, jsonEncode(list));
  }

  // Safety Pre-Restore Snapshot (Blueprint Section 10: pre-restore backup before destructive replacement)
  Future<void> savePreRestoreSnapshot(String snapshotJson) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keySafetySnapshot, snapshotJson);
  }

  Future<String?> loadPreRestoreSnapshot() async {
    final prefs = await _getPrefs();
    return prefs.getString(_keySafetySnapshot);
  }
}
