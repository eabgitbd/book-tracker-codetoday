import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../domain/models/book.dart';
import '../../../domain/models/book_note.dart';
import '../../../domain/services/finish_prediction_service.dart';
import '../../providers/book_provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/journal_provider.dart';
import '../../widgets/book_cover_widget.dart';
import '../../widgets/reading_progress_bar.dart';
import '../../widgets/log_session_dialog.dart';
import '../../widgets/add_note_dialog.dart';
import '../../widgets/reading_card_dialog.dart';
import 'add_edit_book_screen.dart';

class BookDetailsScreen extends ConsumerWidget {
  final String bookId;

  const BookDetailsScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final books = ref.watch(booksProvider);
    final book = books.cast<Book?>().firstWhere(
          (b) => b?.id == bookId,
          orElse: () => null,
        );

    if (book == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Book not found.')),
      );
    }

    final allSessions = ref.watch(sessionsProvider);
    final bookSessions = allSessions.where((s) => s.bookId == book.id).toList();

    final allNotes = ref.watch(notesProvider);
    final bookNotes = allNotes.where((n) => n.bookId == book.id).toList();

    final prediction = FinishPredictionService.predictFinishDate(
      book: book,
      sessions: allSessions,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Reading Card',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => ReadingCardDialog(book: book),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Details',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditBookScreen(bookToEdit: book),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'delete') {
                _confirmDelete(context, ref, book);
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete Book', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header: Cover + Book Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookCoverWidget(
                book: book,
                width: 105,
                height: 160,
                borderRadius: 10,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Status and Format Badges
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.status.displayName,
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.dividerColor.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            book.format.displayName,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (book.hasPageCount)
                      Text(
                        'Page ${book.currentPage} of ${book.pageCount} (${(book.progressPercentage * 100).toInt()}%)',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress Bar and Quick Increment Buttons
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Reading Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        icon: const Icon(Icons.edit, size: 16),
                        label: const Text('Set Page'),
                        onPressed: () => _showPageInputDialog(context, ref, book),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ReadingProgressBar(
                    progress: book.progressPercentage,
                    height: 8,
                    showLabel: true,
                  ),
                  const SizedBox(height: 14),

                  // Quick Increment Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildQuickButton(context, ref, book, -1, '-1'),
                      _buildQuickButton(context, ref, book, 1, '+1'),
                      _buildQuickButton(context, ref, book, 5, '+5'),
                      _buildQuickButton(context, ref, book, 10, '+10'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Finish Prediction Card
          Card(
            color: theme.colorScheme.primary.withOpacity(0.06),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.insights, color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Finish Prediction', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text(
                          prediction.message,
                          style: theme.textTheme.bodyMedium?.copyWith(fontSize: 13),
                        ),
                        if (prediction.estimatedFinishDate != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Target Date: ${DateFormatter.formatDate(prediction.estimatedFinishDate!)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Action Buttons: Log Session & Add Note
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.timer_outlined),
                  label: const Text('Log Session'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => LogSessionDialog(book: book),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.format_quote),
                  label: const Text('Add Quote'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AddNoteDialog(book: book),
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quotes & Notes Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Notes & Quotes (${bookNotes.length})',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AddNoteDialog(book: book),
                  );
                },
                child: const Text('+ Add'),
              ),
            ],
          ),
          if (bookNotes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No notes or quotes recorded yet.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...bookNotes.map((note) => _buildNoteTile(context, ref, note, book)),

          const SizedBox(height: 20),

          // Reading Sessions Section
          Text(
            'Reading History (${bookSessions.length} sessions)',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (bookSessions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No reading sessions logged yet. Tap "Log Session" above.',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ...bookSessions.map((session) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.history_edu, color: Color(0xFF315B48)),
                    title: Text('${session.pagesRead} pages read (${session.startPage} → ${session.endPage})'),
                    subtitle: Text('${session.durationSeconds ~/ 60} mins • ${DateFormatter.formatDate(session.startedAt)}'),
                    trailing: session.focusTag != null
                        ? Chip(
                            label: Text(session.focusTag!, style: const TextStyle(fontSize: 10)),
                            padding: EdgeInsets.zero,
                          )
                        : null,
                  ),
                )),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildQuickButton(
    BuildContext context,
    WidgetRef ref,
    Book book,
    int delta,
    String label,
  ) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      ),
      onPressed: () {
        final target = (book.currentPage + delta).clamp(0, book.pageCount ?? 9999);
        ref.read(booksProvider.notifier).updateProgress(book.id, target);
      },
      child: Text(label),
    );
  }

  Widget _buildNoteTile(BuildContext context, WidgetRef ref, BookNote note, Book book) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    note.type.displayName,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (note.pageNumber != null) ...[
                  const SizedBox(width: 8),
                  Text('p. ${note.pageNumber}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
                const Spacer(),
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
            const SizedBox(height: 6),
            Text(
              note.content,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  void _showPageInputDialog(BuildContext context, WidgetRef ref, Book book) {
    final controller = TextEditingController(text: book.currentPage.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Update Current Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Page Number (Max ${book.pageCount ?? "∞"})',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(controller.text.trim());
              if (page != null) {
                ref.read(booksProvider.notifier).updateProgress(book.id, page);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Book book) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to remove "${book.title}" from your library?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              ref.read(booksProvider.notifier).deleteBook(book.id);
              Navigator.of(ctx).pop(); // dialog
              Navigator.of(context).pop(); // screen
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
