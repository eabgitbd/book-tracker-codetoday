import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/models/book.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book_cover_widget.dart';
import '../../widgets/bookshelf_spine_view.dart';
import '../../widgets/reading_progress_bar.dart';
import 'add_edit_book_screen.dart';
import 'book_details_screen.dart';

enum LibraryViewMode {
  grid,
  spineShelf,
  list,
}

final libraryViewModeProvider = StateProvider<LibraryViewMode>((ref) => LibraryViewMode.grid);

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final books = ref.watch(filteredBooksProvider);
    final viewMode = ref.watch(libraryViewModeProvider);
    final currentStatusFilter = ref.watch(bookFilterStatusProvider);
    final currentSort = ref.watch(bookSortOptionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // View Mode Selector
          IconButton(
            icon: Icon(
              viewMode == LibraryViewMode.grid
                  ? Icons.grid_view
                  : (viewMode == LibraryViewMode.spineShelf ? Icons.shelves : Icons.view_list),
            ),
            tooltip: 'Switch View (Grid / Spine Shelf / List)',
            onPressed: () {
              final nextMode = viewMode == LibraryViewMode.grid
                  ? LibraryViewMode.spineShelf
                  : (viewMode == LibraryViewMode.spineShelf ? LibraryViewMode.list : LibraryViewMode.grid);
              ref.read(libraryViewModeProvider.notifier).state = nextMode;
            },
          ),
          // Sort Menu
          PopupMenuButton<BookSortOption>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort Books',
            onSelected: (val) {
              ref.read(bookSortOptionProvider.notifier).state = val;
            },
            itemBuilder: (ctx) => BookSortOption.values.map((s) {
              return PopupMenuItem(
                value: s,
                child: Row(
                  children: [
                    if (s == currentSort) ...[
                      const Icon(Icons.check, size: 18),
                      const SizedBox(width: 8),
                    ],
                    Text(s.displayName),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search title, author, genre, or borrower...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: ref.watch(bookSearchQueryProvider).isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () => ref.read(bookSearchQueryProvider.notifier).state = '',
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              onChanged: (val) => ref.read(bookSearchQueryProvider.notifier).state = val,
            ),
          ),

          // Filter Chips (Status & Ownership)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildFilterChip(
                  context,
                  ref,
                  label: 'All (${ref.watch(booksProvider).length})',
                  isSelected: currentStatusFilter == null && ref.watch(bookFilterOwnershipProvider) == null,
                  onSelected: () {
                    ref.read(bookFilterStatusProvider.notifier).state = null;
                    ref.read(bookFilterOwnershipProvider.notifier).state = null;
                  },
                ),
                _buildFilterChip(
                  context,
                  ref,
                  label: 'Borrowed (${ref.watch(booksProvider).where((b) => b.isBorrowed).length})',
                  isSelected: ref.watch(bookFilterOwnershipProvider) == false,
                  onSelected: () {
                    final curr = ref.read(bookFilterOwnershipProvider);
                    ref.read(bookFilterOwnershipProvider.notifier).state = curr == false ? null : false;
                  },
                ),
                ...ReadingStatus.values.map((s) {
                  return _buildFilterChip(
                    context,
                    ref,
                    label: s.displayName,
                    isSelected: currentStatusFilter == s,
                    onSelected: () => ref.read(bookFilterStatusProvider.notifier).state = s,
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Main Books Presentation View
          Expanded(
            child: books.isEmpty
                ? Center(
                    child: Text(
                      'No books matching your criteria.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : _buildContent(context, ref, books, viewMode),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Book',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditBookScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    WidgetRef ref, {
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    List<Book> books,
    LibraryViewMode viewMode,
  ) {
    switch (viewMode) {
      case LibraryViewMode.grid:
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.52,
            crossAxisSpacing: 14,
            mainAxisSpacing: 18,
          ),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final b = books[index];
            return _buildGridCard(context, b);
          },
        );

      case LibraryViewMode.spineShelf:
        return BookshelfSpineView(
          books: books,
          onBookTap: (b) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: b.id)),
            );
          },
        );

      case LibraryViewMode.list:
        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: books.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final b = books[index];
            return _buildListTile(context, b);
          },
        );
    }
  }

  Widget _buildGridCard(BuildContext context, Book book) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: BookCoverWidget(
                    book: book,
                    width: double.infinity,
                    height: double.infinity,
                    showProgressOverlay: true,
                  ),
                ),
                if (book.isBorrowed)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: book.isReturnOverdue ? Colors.red : const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1)),
                        ],
                      ),
                      child: Text(
                        book.isReturnOverdue ? 'OVERDUE' : 'BORROWED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          if (book.genre != null && book.genre!.isNotEmpty)
            Text(
              book.genre!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, Book book) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: BookCoverWidget(
        book: book,
        width: 44,
        height: 66,
      ),
      title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.author, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (book.genre != null && book.genre!.isNotEmpty)
            Text(
              book.genre!,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          if (book.isBorrowed)
            Text(
              book.isReturnOverdue
                  ? 'Overdue • Borrowed from ${book.borrowedFrom ?? "library"}'
                  : 'Borrowed from ${book.borrowedFrom ?? "library"}',
              style: TextStyle(
                fontSize: 11,
                color: book.isReturnOverdue ? Colors.red : const Color(0xFFD97706),
                fontWeight: FontWeight.w600,
              ),
            ),
          if (book.hasPageCount) ...[
            const SizedBox(height: 4),
            ReadingProgressBar(progress: book.progressPercentage, height: 4),
          ],
        ],
      ),
      trailing: Text(
        book.status.displayName,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => BookDetailsScreen(bookId: book.id)),
        );
      },
    );
  }
}
