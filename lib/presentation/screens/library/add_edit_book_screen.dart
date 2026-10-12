import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/book_cover_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/book.dart';
import '../../providers/book_provider.dart';
import '../../widgets/book_cover_widget.dart';

class AddEditBookScreen extends ConsumerStatefulWidget {
  final Book? bookToEdit;

  const AddEditBookScreen({super.key, this.bookToEdit});

  @override
  ConsumerState<AddEditBookScreen> createState() => _AddEditBookScreenState();
}

class _AddEditBookScreenState extends ConsumerState<AddEditBookScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _authorController;
  late final TextEditingController _pagesController;
  late final TextEditingController _currentPageController;
  late final TextEditingController _genreController;
  late final TextEditingController _borrowedFromController;
  late final TextEditingController _subtitleController;
  late final TextEditingController _publisherController;
  late final TextEditingController _isbnController;
  late final TextEditingController _descriptionController;

  late BookFormat _format;
  late ReadingStatus _status;
  double? _rating;
  int? _selectedColorValue;
  bool _showAdvanced = false;

  String? _coverLocalPath;
  String? _coverUrl;
  bool _isLoadingCover = false;

  bool _isOwned = true;
  DateTime? _returnDueDate;

  static const List<String> _popularGenres = [
    'Fiction',
    'Non-Fiction',
    'Sci-Fi',
    'Fantasy',
    'Mystery',
    'Thriller',
    'Biography',
    'History',
    'Self-Help',
    'Science',
    'Tech',
    'Romance',
    'Philosophy',
  ];

  final List<Color> _palette = const [
    Color(0xFF2C4A3E), // Deep Sage
    Color(0xFF6E472A), // Leather Brown
    Color(0xFF2B4C6F), // Classic Navy
    Color(0xFF7A3E48), // Burgundy
    Color(0xFF3E3D53), // Slate Indigo
    Color(0xFF8A5D2E), // Amber Ochre
  ];

  @override
  void initState() {
    super.initState();
    final b = widget.bookToEdit;
    _titleController = TextEditingController(text: b?.title ?? '');
    _authorController = TextEditingController(text: b?.author ?? '');
    _pagesController = TextEditingController(text: b?.pageCount?.toString() ?? '');
    _currentPageController = TextEditingController(text: b?.currentPage.toString() ?? '0');
    _genreController = TextEditingController(text: b?.genre ?? '');
    _borrowedFromController = TextEditingController(text: b?.borrowedFrom ?? '');
    _subtitleController = TextEditingController(text: b?.subtitle ?? '');
    _publisherController = TextEditingController(text: b?.publisher ?? '');
    _isbnController = TextEditingController(text: b?.isbn ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');

    _format = b?.format ?? BookFormat.physical;
    _status = b?.status ?? ReadingStatus.wantToRead;
    _rating = b?.rating;
    _selectedColorValue = b?.coverColorValue;

    _coverLocalPath = b?.coverLocalPath;
    _coverUrl = b?.coverUrl;

    _isOwned = b?.isOwned ?? true;
    _returnDueDate = b?.returnDueDate;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _currentPageController.dispose();
    _genreController.dispose();
    _borrowedFromController.dispose();
    _subtitleController.dispose();
    _publisherController.dispose();
    _isbnController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.bookToEdit != null;

    // Temporary book for live cover preview
    final previewBook = Book(
      id: widget.bookToEdit?.id ?? 'preview',
      title: _titleController.text.trim().isEmpty ? 'Book Title' : _titleController.text.trim(),
      author: _authorController.text.trim().isEmpty ? 'Author Name' : _authorController.text.trim(),
      coverLocalPath: _coverLocalPath,
      coverUrl: _coverUrl,
      coverColorValue: _selectedColorValue,
      pageCount: int.tryParse(_pagesController.text.trim()),
      currentPage: int.tryParse(_currentPageController.text.trim()) ?? 0,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastReadAt: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Book' : 'Add New Book'),
        actions: [
          TextButton(
            onPressed: _saveBook,
            child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // --- BOOK COVER SECTION ---
            Card(
              elevation: 0,
              color: theme.colorScheme.surfaceVariant.withOpacity(0.35),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.photo_library_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Book Cover',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (_isLoadingCover) ...[
                          const SizedBox(width: 12),
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live realistic cover preview
                        Hero(
                          tag: 'cover_preview_${widget.bookToEdit?.id ?? "new"}',
                          child: BookCoverWidget(
                            book: previewBook,
                            width: 90,
                            height: 135,
                            borderRadius: 8,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Cover action buttons
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              OutlinedButton.icon(
                                icon: const Icon(Icons.camera_alt_outlined, size: 18),
                                label: const Text('Capture Photo'),
                                onPressed: _isLoadingCover ? null : _pickFromCamera,
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.photo_outlined, size: 18),
                                label: const Text('Upload Local File'),
                                onPressed: _isLoadingCover ? null : _pickFromGallery,
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                icon: const Icon(Icons.link_outlined, size: 18),
                                label: const Text('Download Link'),
                                onPressed: _isLoadingCover ? null : _showDownloadUrlDialog,
                              ),
                              if (_coverLocalPath != null || _coverUrl != null) ...[
                                const SizedBox(height: 4),
                                TextButton.icon(
                                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                  label: const Text('Remove Cover', style: TextStyle(color: Colors.red, fontSize: 12)),
                                  onPressed: () {
                                    setState(() {
                                      _coverLocalPath = null;
                                      _coverUrl = null;
                                    });
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- TITLE & AUTHOR ---
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Book Title *',
                prefixIcon: Icon(Icons.book_outlined),
              ),
              onChanged: (_) => setState(() {}),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                prefixIcon: Icon(Icons.person_outline),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // --- GENRE SECTION ---
            TextFormField(
              controller: _genreController,
              decoration: InputDecoration(
                labelText: 'Genre',
                hintText: 'e.g., Sci-Fi, History, Fiction',
                prefixIcon: const Icon(Icons.bookmarks_outlined),
                suffixIcon: _genreController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _genreController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _popularGenres.map((g) {
                  final isSelected = _genreController.text.trim().toLowerCase() == g.toLowerCase();
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(g, style: const TextStyle(fontSize: 12)),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _genreController.text = selected ? g : '';
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),

            // --- OWNERSHIP & BORROWING SECTION ---
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: theme.dividerColor.withOpacity(0.3)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ownership Status',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<bool>(
                      segments: const [
                        ButtonSegment<bool>(
                          value: true,
                          label: Text('Owned by Me'),
                          icon: Icon(Icons.check_circle_outline, size: 18),
                        ),
                        ButtonSegment<bool>(
                          value: false,
                          label: Text('Borrowed'),
                          icon: Icon(Icons.assignment_ind_outlined, size: 18),
                        ),
                      ],
                      selected: {_isOwned},
                      onSelectionChanged: (Set<bool> newSelection) {
                        setState(() {
                          _isOwned = newSelection.first;
                        });
                      },
                    ),

                    if (!_isOwned) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _borrowedFromController,
                        decoration: const InputDecoration(
                          labelText: 'Borrowed From (Library / Person) *',
                          hintText: 'e.g. City Public Library or Alice',
                          prefixIcon: Icon(Icons.account_balance_outlined),
                        ),
                        validator: (val) {
                          if (!_isOwned && (val == null || val.trim().isEmpty)) {
                            return 'Please enter who you borrowed this book from';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            size: 20,
                            color: _returnDueDate != null ? theme.colorScheme.primary : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _returnDueDate != null
                                  ? 'Return Due: ${DateFormatter.formatDate(_returnDueDate!)}'
                                  : 'No return due date set',
                              style: TextStyle(
                                fontWeight: _returnDueDate != null ? FontWeight.bold : FontWeight.normal,
                                color: _returnDueDate != null ? theme.colorScheme.primary : null,
                              ),
                            ),
                          ),
                          if (_returnDueDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              tooltip: 'Clear due date',
                              onPressed: () => setState(() => _returnDueDate = null),
                            ),
                          OutlinedButton(
                            onPressed: _pickReturnDueDate,
                            child: Text(_returnDueDate == null ? 'Set Due Date' : 'Change'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Quick due date presets
                      Wrap(
                        spacing: 8,
                        children: [
                          ActionChip(
                            label: const Text('+1 Week', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              setState(() {
                                _returnDueDate = DateTime.now().add(const Duration(days: 7));
                              });
                            },
                          ),
                          ActionChip(
                            label: const Text('+2 Weeks', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              setState(() {
                                _returnDueDate = DateTime.now().add(const Duration(days: 14));
                              });
                            },
                          ),
                          ActionChip(
                            label: const Text('+1 Month', style: TextStyle(fontSize: 11)),
                            onPressed: () {
                              setState(() {
                                _returnDueDate = DateTime.now().add(const Duration(days: 30));
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // --- PAGE COUNT & CURRENT PAGE ---
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _pagesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Total Pages',
                      prefixIcon: Icon(Icons.format_list_numbered),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _currentPageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Current Page',
                      prefixIcon: Icon(Icons.bookmark_border),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // --- STATUS SELECTOR ---
            DropdownButtonFormField<ReadingStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Reading Status',
                prefixIcon: Icon(Icons.flag_outlined),
              ),
              items: ReadingStatus.values.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(s.displayName),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _status = val);
              },
            ),
            const SizedBox(height: 16),

            // --- COVER PALETTE / ACCENT COLOR ---
            Text('Cover Theme & Spine Palette', style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: _palette.map((color) {
                final isSelected = _selectedColorValue == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColorValue = color.value),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: theme.colorScheme.primary, width: 3)
                          : null,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 20, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // --- ADVANCED DETAILS EXPANDER ---
            InkWell(
              onTap: () => setState(() => _showAdvanced = !_showAdvanced),
              child: Row(
                children: [
                  Icon(_showAdvanced ? Icons.expand_less : Icons.expand_more),
                  const SizedBox(width: 8),
                  Text(
                    _showAdvanced ? 'Hide Additional Details' : 'More Details (ISBN, Format, etc.)',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            if (_showAdvanced) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<BookFormat>(
                value: _format,
                decoration: const InputDecoration(
                  labelText: 'Format',
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: BookFormat.values.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f.displayName),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _format = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _isbnController,
                decoration: const InputDecoration(
                  labelText: 'ISBN',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _publisherController,
                decoration: const InputDecoration(
                  labelText: 'Publisher',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Subtitle',
                  prefixIcon: Icon(Icons.subtitles_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Book Description / Synopsis',
                  alignLabelWithHint: true,
                ),
              ),
            ],

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveBook,
              child: Text(isEditing ? 'Save Changes' : 'Add Book to Library'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickReturnDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _returnDueDate ?? now.add(const Duration(days: 14)),
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _returnDueDate = picked);
    }
  }

  Future<void> _pickFromCamera() async {
    setState(() => _isLoadingCover = true);
    try {
      final result = await BookCoverService.captureFromCamera();
      if (result.success && result.filePath != null && mounted) {
        setState(() {
          _coverLocalPath = result.filePath;
        });
      } else if (result.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage!)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing photo: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCover = false);
    }
  }

  Future<void> _pickFromGallery() async {
    setState(() => _isLoadingCover = true);
    try {
      final result = await BookCoverService.pickFromGallery();
      if (result.success && result.filePath != null && mounted) {
        setState(() {
          _coverLocalPath = result.filePath;
        });
      } else if (result.errorMessage != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.errorMessage!)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting image: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingCover = false);
    }
  }

  Future<void> _showDownloadUrlDialog() async {
    final urlController = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download Cover from Link'),
        content: TextField(
          controller: urlController,
          autofocus: true,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(
            labelText: 'Image Web URL',
            hintText: 'https://example.com/cover.jpg',
            prefixIcon: Icon(Icons.link),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = urlController.text.trim();
              if (text.isNotEmpty) {
                Navigator.of(ctx).pop(text);
              }
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );

    if (url != null && url.isNotEmpty && mounted) {
      setState(() => _isLoadingCover = true);
      try {
        final result = await BookCoverService.downloadFromUrl(url);
        if (result.success && result.filePath != null && mounted) {
          setState(() {
            _coverLocalPath = result.filePath;
            _coverUrl = url;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cover image downloaded successfully')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.errorMessage ?? 'Failed to download image from the provided URL')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error downloading cover: $e')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoadingCover = false);
      }
    }
  }

  void _saveBook() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final author = _authorController.text.trim().isNotEmpty
        ? _authorController.text.trim()
        : 'Unknown Author';
    final pageCount = int.tryParse(_pagesController.text.trim());
    final currentPage = int.tryParse(_currentPageController.text.trim()) ?? 0;
    final isbn = _isbnController.text.trim().isNotEmpty ? _isbnController.text.trim() : null;

    // Check duplicate if creating new
    if (widget.bookToEdit == null) {
      final repo = ref.read(bookRepositoryProvider);
      final duplicate = await repo.findDuplicate(isbn: isbn, title: title, author: author);
      if (duplicate != null && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Possible Duplicate'),
            content: Text('A book titled "${duplicate.title}" by ${duplicate.author} already exists in your library. Add anyway?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Add Duplicate')),
            ],
          ),
        );
        if (proceed != true) return;
      }
    }

    final now = DateTime.now();
    final isEditing = widget.bookToEdit != null;

    final book = Book(
      id: widget.bookToEdit?.id ?? IdGenerator.generate(),
      title: title,
      author: author,
      subtitle: _subtitleController.text.trim().isNotEmpty ? _subtitleController.text.trim() : null,
      description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
      publisher: _publisherController.text.trim().isNotEmpty ? _publisherController.text.trim() : null,
      isbn: isbn,
      pageCount: pageCount,
      currentPage: currentPage,
      coverUrl: _coverUrl,
      coverLocalPath: _coverLocalPath,
      coverColorValue: _selectedColorValue,
      format: _format,
      status: _status,
      genre: _genreController.text.trim().isNotEmpty ? _genreController.text.trim() : null,
      isOwned: _isOwned,
      borrowedFrom: !_isOwned && _borrowedFromController.text.trim().isNotEmpty
          ? _borrowedFromController.text.trim()
          : null,
      borrowedAt: !_isOwned ? (widget.bookToEdit?.borrowedAt ?? now) : null,
      returnDueDate: !_isOwned ? _returnDueDate : null,
      rating: _rating,
      startedAt: _status == ReadingStatus.reading ? (widget.bookToEdit?.startedAt ?? now) : widget.bookToEdit?.startedAt,
      completedAt: _status == ReadingStatus.read ? (widget.bookToEdit?.completedAt ?? now) : null,
      lastReadAt: now,
      createdAt: widget.bookToEdit?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(booksProvider.notifier).saveBook(book);

    if (mounted) {
      Navigator.of(context).pop(book);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Saved changes to "${book.title}"' : 'Added "${book.title}" to library'),
          action: SnackBarAction(
            label: 'Edit Details',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddEditBookScreen(bookToEdit: book),
                ),
              );
            },
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}
