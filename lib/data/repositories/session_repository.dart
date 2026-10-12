import '../sources/local_storage_source.dart';
import '../../domain/models/reading_session.dart';
import '../../domain/models/book_note.dart';

class SessionRepository {
  final LocalStorageSource _storage;

  SessionRepository(this._storage);

  Future<List<ReadingSession>> getAllSessions() async {
    final sessions = await _storage.loadSessions();
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  Future<List<ReadingSession>> getSessionsForBook(String bookId) async {
    final sessions = await _storage.loadSessions();
    return sessions.where((s) => s.bookId == bookId).toList()
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  Future<void> addSession(ReadingSession session) async {
    final sessions = await _storage.loadSessions();
    sessions.add(session);
    await _storage.saveSessions(sessions);
  }

  Future<List<BookNote>> getAllNotes() async {
    final notes = await _storage.loadNotes();
    notes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return notes;
  }

  Future<List<BookNote>> getNotesForBook(String bookId) async {
    final notes = await _storage.loadNotes();
    return notes.where((n) => n.bookId == bookId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addNote(BookNote note) async {
    final notes = await _storage.loadNotes();
    final index = notes.indexWhere((n) => n.id == note.id);
    if (index >= 0) {
      notes[index] = note;
    } else {
      notes.add(note);
    }
    await _storage.saveNotes(notes);
  }

  Future<void> deleteNote(String id) async {
    final notes = await _storage.loadNotes();
    notes.removeWhere((n) => n.id == id);
    await _storage.saveNotes(notes);
  }
}
