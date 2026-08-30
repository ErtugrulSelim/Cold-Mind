import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// The e-reader.
///
/// What this surface gives that Notes cannot is **a timestamp attached to what
/// somebody was reading**. A passage marked at 03:14 the night before an event
/// puts the owner's attention on a date, in their own hand, without them ever
/// writing a word about it.
///
/// So the second tab is the one that matters: every highlight in the library,
/// newest first, across all books. The dates are what a player scans, and
/// keeping them locked inside their separate books would hide the sequence
/// entirely.
class ReaderScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const ReaderScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final books = _read();
    final highlights = [
      for (final book in books)
        for (final highlight in book.highlights) (book: book, mark: highlight),
    ]..sort((a, b) => b.mark.at.compareTo(a.mark.at));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: device.background,
        appBar: AppBar(
          title: Text(strings?.c('ui.app.ereader') ?? 'Margin'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Library'),
              Tab(text: 'Highlights'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ListView.separated(
              padding: const EdgeInsets.only(bottom: ColdSpace.xl),
              itemCount: books.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: device.hairline),
              itemBuilder: (context, i) {
                final book = books[i];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: ColdSpace.lg,
                    vertical: ColdSpace.sm,
                  ),
                  // Titles and authors are proper nouns; they stay as written.
                  title: Text(
                    book.title,
                    style: ColdType.subtitle.copyWith(
                      color: device.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.author,
                        style: ColdType.bodySmall.copyWith(
                          color: device.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${book.progress}%  ·  opened ${book.openCount}×'
                        '  ·  ${format.dateTime(book.lastOpened)}',
                        style: ColdType.micro.copyWith(
                          color: device.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '${book.highlights.length}',
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
                );
              },
            ),
            ListView.builder(
              padding: const EdgeInsets.all(ColdSpace.lg),
              itemCount: highlights.length,
              itemBuilder: (context, i) {
                final entry = highlights[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: ColdSpace.md),
                  padding: const EdgeInsets.all(ColdSpace.md),
                  decoration: BoxDecoration(
                    color: device.surfaceRaised,
                    borderRadius: ColdRadius.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              entry.book.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: ColdType.micro.copyWith(
                                color: device.textTertiary,
                              ),
                            ),
                          ),
                          Text(
                            entry.mark.location,
                            style: ColdType.micro.copyWith(
                              color: device.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: ColdSpace.sm),
                      // The passage, marked the way a reader marks one.
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: device.warning, width: 3),
                          ),
                        ),
                        child: Text(
                          strings?.t(entry.mark.textKey) ?? '',
                          style: ColdType.body.copyWith(
                            color: device.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                      if (entry.mark.noteKey != null) ...[
                        const SizedBox(height: ColdSpace.sm),
                        // Their own note in the margin — the closest thing on
                        // the phone to hearing them think.
                        Text(
                          strings?.t(entry.mark.noteKey!) ?? '',
                          style: ColdType.bodySmall.copyWith(
                            color: device.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const SizedBox(height: ColdSpace.sm),
                      Text(
                        format.dateTime(entry.mark.at),
                        style: ColdType.meta.copyWith(color: device.accent),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<_Book> _read() {
    final raw = file.appData('ereader')?['books'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Book.fromJson(entry),
    ]..sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
  }
}

class _Book {
  final String title;
  final String author;
  final int progress;
  final int openCount;
  final DateTime lastOpened;
  final List<_Highlight> highlights;

  const _Book({
    required this.title,
    required this.author,
    required this.progress,
    required this.openCount,
    required this.lastOpened,
    required this.highlights,
  });

  static _Book? fromJson(Map<String, dynamic> json) {
    final opened = DateTime.tryParse('${json['last_opened_at']}');
    if (opened == null) return null;
    return _Book(
      title: '${json['title'] ?? ''}',
      author: '${json['author'] ?? ''}',
      progress: (json['progress_percent'] as num?)?.toInt() ?? 0,
      openCount: (json['open_count'] as num?)?.toInt() ?? 0,
      lastOpened: opened,
      highlights: [
        for (final raw in (json['highlights'] as List? ?? const []))
          if (raw is Map<String, dynamic>) ?_Highlight.fromJson(raw),
      ],
    );
  }
}

class _Highlight {
  final String textKey;
  final String? noteKey;
  final String location;
  final DateTime at;

  const _Highlight({
    required this.textKey,
    required this.noteKey,
    required this.location,
    required this.at,
  });

  static _Highlight? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['highlighted_at']}');
    if (at == null) return null;
    return _Highlight(
      textKey: '${json['text_key']}',
      noteKey: json['note_key'] as String?,
      location: '${json['location'] ?? ''}',
      at: at,
    );
  }
}
