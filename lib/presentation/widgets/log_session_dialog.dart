import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/id_generator.dart';
import '../../domain/models/book.dart';
import '../../domain/models/reading_session.dart';
import '../providers/book_provider.dart';
import '../providers/session_provider.dart';

class LogSessionDialog extends ConsumerStatefulWidget {
  final Book book;

  const LogSessionDialog({super.key, required this.book});

  @override
  ConsumerState<LogSessionDialog> createState() => _LogSessionDialogState();
}

class _LogSessionDialogState extends ConsumerState<LogSessionDialog> {
  late final TextEditingController _startPageController;
  late final TextEditingController _endPageController;
  final TextEditingController _durationController = TextEditingController(text: '25');
  final TextEditingController _noteController = TextEditingController();
  String _selectedFocusTag = 'Focused';

  final List<String> _tags = ['Focused', 'Deep Read', 'Commute', 'Bedtime', 'Casual'];

  @override
  void initState() {
    super.initState();
    _startPageController = TextEditingController(text: widget.book.currentPage.toString());
    _endPageController = TextEditingController(
      text: widget.book.currentPage.toString(),
    );
  }

  @override
  void dispose() {
    _startPageController.dispose();
    _endPageController.dispose();
    _durationController.dispose();
    _noteController.dispose();
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
                    'Log Reading Session',
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

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startPageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Start Page',
                        prefixIcon: Icon(Icons.bookmark_border, size: 20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _endPageController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'End Page',
                        prefixIcon: Icon(Icons.bookmark, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duration (minutes)',
                  prefixIcon: Icon(Icons.timer_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),

              Text('Focus Mode / Tag', style: theme.textTheme.labelMedium),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: _tags.map((tag) {
                  final isSelected = _selectedFocusTag == tag;
                  return ChoiceChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFocusTag = tag);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Session Reflections (Optional)',
                  prefixIcon: Icon(Icons.edit_note, size: 20),
                ),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveSession,
                child: const Text('Save Session'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveSession() async {
    final startPage = int.tryParse(_startPageController.text.trim()) ?? widget.book.currentPage;
    final endPage = int.tryParse(_endPageController.text.trim()) ?? startPage;
    final durationMinutes = int.tryParse(_durationController.text.trim()) ?? 0;

    if (endPage < startPage) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End page cannot be less than start page.')),
      );
      return;
    }

    final pagesRead = endPage - startPage;
    final session = ReadingSession(
      id: IdGenerator.generate(),
      bookId: widget.book.id,
      startedAt: DateTime.now().subtract(Duration(minutes: durationMinutes)),
      endedAt: DateTime.now(),
      durationSeconds: durationMinutes * 60,
      startPage: startPage,
      endPage: endPage,
      pagesRead: pagesRead,
      sessionNote: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
      focusTag: _selectedFocusTag,
      createdAt: DateTime.now(),
    );

    await ref.read(sessionsProvider.notifier).logSession(session);
    if (endPage > widget.book.currentPage) {
      await ref.read(booksProvider.notifier).updateProgress(widget.book.id, endPage);
    }

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged $pagesRead pages read in $durationMinutes mins!')),
      );
    }
  }
}
