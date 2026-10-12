import '../sources/local_storage_source.dart';
import '../../domain/models/book.dart';

class BookRepository {
  final LocalStorageSource _storage;

  BookRepository(this._storage);

  Future<List<Book>> getBooks() async {
    final books = await _storage.loadBooks();
    // Default sort by lastReadAt descending
    books.sort((a, b) => b.lastReadAt.compareTo(a.lastReadAt));
    return books;
  }

  Future<Book?> getBookById(String id) async {
    final books = await _storage.loadBooks();
    try {
      return books.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveBook(Book book) async {
    final books = await _storage.loadBooks();
    final index = books.indexWhere((b) => b.id == book.id);
    if (index >= 0) {
      books[index] = book.copyWith(updatedAt: DateTime.now());
    } else {
      books.add(book);
    }
    await _storage.saveBooks(books);
  }

  Future<void> updateProgress(String id, int newPage) async {
    final books = await _storage.loadBooks();
    final index = books.indexWhere((b) => b.id == id);
    if (index >= 0) {
      final current = books[index];
      final maxPages = current.pageCount ?? newPage;
      final validatedPage = newPage.clamp(0, maxPages > 0 ? maxPages : newPage);

      final isFinished = current.pageCount != null && validatedPage >= current.pageCount!;
      final newStatus = isFinished ? ReadingStatus.read : (validatedPage > 0 ? ReadingStatus.reading : current.status);

      books[index] = current.copyWith(
        currentPage: validatedPage,
        status: newStatus,
        lastReadAt: DateTime.now(),
        completedAt: isFinished ? (current.completedAt ?? DateTime.now()) : null,
        updatedAt: DateTime.now(),
      );
      await _storage.saveBooks(books);
    }
  }

  Future<void> deleteBook(String id) async {
    final books = await _storage.loadBooks();
    books.removeWhere((b) => b.id == id);
    await _storage.saveBooks(books);
  }

  Future<Book?> findDuplicate({String? isbn, required String title, String? author}) async {
    final books = await _storage.loadBooks();
    if (isbn != null && isbn.trim().isNotEmpty) {
      for (final b in books) {
        if (b.isbn != null && b.isbn!.trim().toLowerCase() == isbn.trim().toLowerCase()) {
          return b;
        }
      }
    }
    // Soft match title & author
    for (final b in books) {
      if (b.title.trim().toLowerCase() == title.trim().toLowerCase()) {
        if (author == null || b.author.trim().toLowerCase() == author.trim().toLowerCase()) {
          return b;
        }
      }
    }
    return null;
  }
}
