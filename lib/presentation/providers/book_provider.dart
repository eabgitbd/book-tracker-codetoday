import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/book_repository.dart';
import '../../domain/models/book.dart';
import 'settings_provider.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final storage = ref.watch(localStorageSourceProvider);
  return BookRepository(storage);
});

enum BookSortOption {
  recentlyRead,
  recentlyAdded,
  titleAsc,
  authorAsc,
  ratingDesc,
  progressDesc,
}

extension BookSortOptionExtension on BookSortOption {
  String get displayName {
    switch (this) {
      case BookSortOption.recentlyRead:
        return 'Recently Read';
      case BookSortOption.recentlyAdded:
        return 'Recently Added';
      case BookSortOption.titleAsc:
        return 'Title (A-Z)';
      case BookSortOption.authorAsc:
        return 'Author (A-Z)';
      case BookSortOption.ratingDesc:
        return 'Highest Rating';
      case BookSortOption.progressDesc:
        return 'Highest Progress';
    }
  }
}

class BooksNotifier extends StateNotifier<List<Book>> {
  final BookRepository _repo;

  BooksNotifier(this._repo) : super([]) {
    loadBooks();
  }

  Future<void> loadBooks() async {
    final list = await _repo.getBooks();
    state = list;
  }

  Future<void> saveBook(Book book) async {
    await _repo.saveBook(book);
    await loadBooks();
  }

  Future<void> updateProgress(String id, int newPage) async {
    await _repo.updateProgress(id, newPage);
    await loadBooks();
  }

  Future<void> deleteBook(String id) async {
    await _repo.deleteBook(id);
    await loadBooks();
  }
}

final booksProvider = StateNotifierProvider<BooksNotifier, List<Book>>((ref) {
  final repo = ref.watch(bookRepositoryProvider);
  return BooksNotifier(repo);
});

final bookSearchQueryProvider = StateProvider<String>((ref) => '');
final bookFilterStatusProvider = StateProvider<ReadingStatus?>((ref) => null);
final bookSortOptionProvider = StateProvider<BookSortOption>((ref) => BookSortOption.recentlyRead);

final filteredBooksProvider = Provider<List<Book>>((ref) {
  final books = ref.watch(booksProvider);
  final query = ref.watch(bookSearchQueryProvider).trim().toLowerCase();
  final statusFilter = ref.watch(bookFilterStatusProvider);
  final sortOption = ref.watch(bookSortOptionProvider);

  var list = books;

  if (statusFilter != null) {
    list = list.where((b) => b.status == statusFilter).toList();
  }

  if (query.isNotEmpty) {
    list = list.where((b) {
      final titleMatch = b.title.toLowerCase().contains(query);
      final authorMatch = b.author.toLowerCase().contains(query);
      final isbnMatch = b.isbn?.toLowerCase().contains(query) ?? false;
      return titleMatch || authorMatch || isbnMatch;
    }).toList();
  }

  final sorted = List<Book>.from(list);
  switch (sortOption) {
    case BookSortOption.recentlyRead:
      sorted.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
      break;
    case BookSortOption.recentlyAdded:
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      break;
    case BookSortOption.titleAsc:
      sorted.sort((a, b) => (a.sortTitle ?? a.title).toLowerCase().compareTo((b.sortTitle ?? b.title).toLowerCase()));
      break;
    case BookSortOption.authorAsc:
      sorted.sort((a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
      break;
    case BookSortOption.ratingDesc:
      sorted.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));
      break;
    case BookSortOption.progressDesc:
      sorted.sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
      break;
  }

  return sorted;
});
