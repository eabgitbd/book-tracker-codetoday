import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/book.dart';
import '../../../domain/models/book_note.dart';
import '../../providers/book_provider.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/reading_card_dialog.dart';

class JournalScreen extends ConsumerWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final notes = ref.watch(filteredNotesProvider);
    final allBooks = ref.watch(booksProvider);
    final currentTypeFilter = ref.watch(noteFilterTypeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Journal', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search quotes and reflections...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: ref.watch(noteSearchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref.read(noteSearchQueryProvider.notifier).state = '',
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (val) => ref.read(noteSearchQueryProvider.notifier).state = val,
            ),
          ),

          // Filter Chips
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text('All (${ref.watch(notesProvider).length})'),
                    selected: currentTypeFilter == null,
                    onSelected: (_) => ref.read(noteFilterTypeProvider.notifier).state = null,
                  ),
                ),
                ...NoteType.values.map((type) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(type.displayName),
                      selected: currentTypeFilter == type,
                      onSelected: (_) => ref.read(noteFilterTypeProvider.notifier).state = type,
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Timeline List
          Expanded(
            child: notes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.edit_note, size: 56, color: theme.colorScheme.primary.withOpacity(0.4)),
                          const SizedBox(height: 16),
                          Text(
                            'Your Journal is quiet',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Capture memorable book quotes, reflections, and insights while reading.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final book = allBooks.cast<Book?>().firstWhere(
                            (b) => b?.id == note.bookId,
                            orElse: () => null,
                          );

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      note.type.displayName,
                                      style: TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (note.pageNumber != null)
                                    Text('Page ${note.pageNumber}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  const Spacer(),
                                  Text(
                                    DateFormatter.formatRelative(note.createdAt),
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                note.content,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontStyle: note.type == NoteType.quote ? FontStyle.italic : FontStyle.normal,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Divider(height: 1),
                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(Icons.book_outlined, size: 14, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      book != null ? '${book.title} — ${book.author}' : 'Unlinked Book',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  if (book != null && note.type == NoteType.quote)
                                    IconButton(
                                      icon: const Icon(Icons.share, size: 18),
                                      tooltip: 'Share Card',
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ReadingCardDialog(book: book, quote: note),
                                        );
                                      },
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    onPressed: () => ref.read(notesProvider.notifier).deleteNote(note.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
