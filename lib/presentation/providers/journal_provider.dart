import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/book_note.dart';
import 'session_provider.dart';

class NotesNotifier extends StateNotifier<List<BookNote>> {
  final Ref _ref;

  NotesNotifier(this._ref) : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    final repo = _ref.read(sessionRepositoryProvider);
    final list = await repo.getAllNotes();
    state = list;
  }

  Future<void> addNote(BookNote note) async {
    final repo = _ref.read(sessionRepositoryProvider);
    await repo.addNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    final repo = _ref.read(sessionRepositoryProvider);
    await repo.deleteNote(id);
    await loadNotes();
  }
}

final notesProvider = StateNotifierProvider<NotesNotifier, List<BookNote>>((ref) {
  return NotesNotifier(ref);
});

final noteFilterTypeProvider = StateProvider<NoteType?>((ref) => null);
final noteSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredNotesProvider = Provider<List<BookNote>>((ref) {
  final notes = ref.watch(notesProvider);
  final typeFilter = ref.watch(noteFilterTypeProvider);
  final query = ref.watch(noteSearchQueryProvider).trim().toLowerCase();

  return notes.where((n) {
    if (typeFilter != null && n.type != typeFilter) return false;
    if (query.isNotEmpty) {
      final contentMatch = n.content.toLowerCase().contains(query);
      final tagMatch = n.tags.any((t) => t.toLowerCase().contains(query));
      return contentMatch || tagMatch;
    }
    return true;
  }).toList();
});
