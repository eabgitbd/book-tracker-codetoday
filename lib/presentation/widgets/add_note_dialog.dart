import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/models/book.dart';
import '../../domain/models/book_note.dart';
import '../providers/journal_provider.dart';

class AddNoteDialog extends ConsumerStatefulWidget {
  final Book book;
  final BookNote? initialNote;

  const AddNoteDialog({
    super.key,
    required this.book,
    this.initialNote,
  });

  @override
  ConsumerState<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends ConsumerState<AddNoteDialog> {
  late NoteType _selectedType;
  late final TextEditingController _contentController;
  late final TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialNote?.type ?? NoteType.quote;
    _contentController = TextEditingController(text: widget.initialNote?.content ?? '');
    _pageController = TextEditingController(
      text: widget.initialNote?.pageNumber?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _contentController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.initialNote == null ? 'Add to Journal' : 'Edit Entry',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                widget.book.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 16),

              SegmentedButton<NoteType>(
                segments: NoteType.values.map((t) {
                  return ButtonSegment(
                    value: t,
                    label: Text(t.displayName),
                  );
                }).toList(),
                selected: {_selectedType},
                onSelectionChanged: (set) {
                  setState(() => _selectedType = set.first);
                },
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: _selectedType == NoteType.quote ? 'Quote text...' : 'Note content...',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _pageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Page Number (Optional)',
                  prefixIcon: Icon(Icons.pin, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveNote,
                child: Text(widget.initialNote == null ? 'Save Entry' : 'Update Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter content for this entry.')),
      );
      return;
    }

    final pageNumber = int.tryParse(_pageController.text.trim());
    final now = DateTime.now();

    final note = BookNote(
      id: widget.initialNote?.id ?? IdGenerator.generate(),
      bookId: widget.book.id,
      type: _selectedType,
      content: content,
      pageNumber: pageNumber,
      sourceType: widget.initialNote?.sourceType ?? 'manual',
      createdAt: widget.initialNote?.createdAt ?? now,
      updatedAt: now,
    );

    await ref.read(notesProvider.notifier).addNote(note);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_selectedType.displayName} saved!')),
      );
    }
  }
}
