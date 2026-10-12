import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/id_generator.dart';
import '../../../domain/models/book.dart';
import '../../providers/book_provider.dart';

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
  late final TextEditingController _subtitleController;
  late final TextEditingController _publisherController;
  late final TextEditingController _isbnController;
  late final TextEditingController _descriptionController;

  late BookFormat _format;
  late ReadingStatus _status;
  double? _rating;
  int? _selectedColorValue;
  bool _showAdvanced = false;

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
    _subtitleController = TextEditingController(text: b?.subtitle ?? '');
    _publisherController = TextEditingController(text: b?.publisher ?? '');
    _isbnController = TextEditingController(text: b?.isbn ?? '');
    _descriptionController = TextEditingController(text: b?.description ?? '');

    _format = b?.format ?? BookFormat.physical;
    _status = b?.status ?? ReadingStatus.wantToRead;
    _rating = b?.rating;
    _selectedColorValue = b?.coverColorValue;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _pagesController.dispose();
    _currentPageController.dispose();
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
            // Title (Required)
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Book Title *',
                prefixIcon: Icon(Icons.book_outlined),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Author
            TextFormField(
              controller: _authorController,
              decoration: const InputDecoration(
                labelText: 'Author',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),

            // Page Count & Current Page
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
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Selector
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

            // Cover Color Picker
            Text('Cover & Spine Palette', style: theme.textTheme.labelMedium),
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

            // Expandable Advanced Details
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
      coverColorValue: _selectedColorValue,
      format: _format,
      status: _status,
      rating: _rating,
      startedAt: _status == ReadingStatus.reading ? (widget.bookToEdit?.startedAt ?? now) : widget.bookToEdit?.startedAt,
      completedAt: _status == ReadingStatus.read ? (widget.bookToEdit?.completedAt ?? now) : null,
      lastReadAt: now,
      createdAt: widget.bookToEdit?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(booksProvider.notifier).saveBook(book);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Saved "${book.title}"')),
      );
    }
  }
}
