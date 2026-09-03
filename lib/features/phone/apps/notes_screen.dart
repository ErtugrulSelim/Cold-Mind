import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';
import '../widgets/password_dialog.dart';

/// Notes.
///
/// Notes are where people write things they are not telling anyone, which makes
/// this one of the few apps where the **edit history matters more than the
/// text**. A note created in September and last touched four days before it
/// happened has been coming back to; the dates are given equal billing with the
/// title for that reason.
///
/// Locked notes stay locked and say so. Opening one needs a password found
/// elsewhere on the phone — that chain is the game's exploration mechanic, and
/// a note that opened on tap would collapse it.
class NotesScreen extends StatefulWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const NotesScreen({super.key, required this.file, required this.strings});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final Set<String> _unlocked = {};

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(widget.strings);
    final folders = _readFolders(widget.file);

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(widget.strings?.c('ui.app.notes') ?? 'Pages')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: ColdSpace.xl),
        children: [
          for (final folder in folders) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ColdSpace.lg,
                ColdSpace.lg,
                ColdSpace.lg,
                ColdSpace.sm,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder_outlined,
                    size: 15,
                    color: device.textTertiary,
                  ),
                  const SizedBox(width: ColdSpace.sm),
                  Text(
                    widget.strings?.t(folder.nameKey) ?? '',
                    style: ColdType.label.copyWith(color: device.textSecondary),
                  ),
                  const Spacer(),
                  Text(
                    '${folder.notes.length}',
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
                ],
              ),
            ),
            for (final note in folder.notes)
              _NoteRow(
                // Across every folder, not just this one: a phone whose notes
                // run from 2015 has to say so on all of them.
                spansYears: PhoneFormat.spanYears([
                  for (final f in folders)
                    for (final n in f.notes) n.createdAt,
                ]),
                note: note,
                strings: widget.strings,
                format: format,
                isOpen: !note.isLocked || _unlocked.contains(note.id),
                onOpen: () => _open(note),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _open(_Note note) async {
    if (note.isLocked && !_unlocked.contains(note.id)) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => PasswordDialog(
          expected: note.lockPassword,
          titleKey: 'ui.lock.note',
          strings: widget.strings,
        ),
      );
      if (ok != true || !mounted) return;
      setState(() => _unlocked.add(note.id));
    }
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _NoteScreen(note: note, strings: widget.strings),
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  final _Note note;
  final CaseStrings? strings;
  final PhoneFormat format;
  final bool isOpen;
  final VoidCallback onOpen;

  /// Whether the list this row is in runs across more than one year.
  final bool spansYears;

  const _NoteRow({
    required this.spansYears,
    required this.note,
    required this.strings,
    required this.format,
    required this.isOpen,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return InkWell(
      onTap: onOpen,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          ColdSpace.lg,
          0,
          ColdSpace.lg,
          ColdSpace.sm,
        ),
        padding: const EdgeInsets.all(ColdSpace.md),
        decoration: BoxDecoration(
          color: device.surfaceRaised,
          borderRadius: ColdRadius.card,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings?.t(note.titleKey) ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ColdType.subtitle.copyWith(
                      color: device.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Both dates, always. When a note was written and when it was
                  // last touched are different facts and either can be the one
                  // that matters.
                  Text(
                    'written ${format.listDate(note.createdAt, spansYears: spansYears)}'
                    '   ·   edited ${format.dateTime(note.updatedAt)}',
                    style: ColdType.micro.copyWith(color: device.textTertiary),
                  ),
                ],
              ),
            ),
            if (!isOpen) ...[
              const SizedBox(width: ColdSpace.sm),
              Icon(Icons.lock, size: 16, color: device.warning),
            ],
          ],
        ),
      ),
    );
  }
}

class _NoteScreen extends StatelessWidget {
  final _Note note;
  final CaseStrings? strings;

  const _NoteScreen({required this.note, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.t(note.titleKey) ?? '')),
      body: ListView(
        padding: const EdgeInsets.all(ColdSpace.lg),
        children: [
          Text(
            format.dateTime(note.updatedAt),
            style: ColdType.meta.copyWith(color: device.textTertiary),
          ),
          const SizedBox(height: ColdSpace.lg),
          for (final block in note.blocks) ...[
            if (block.isCheckbox)
              // A checklist is only worth reading for which lines got ticked
              // off — the same three words read as a plan when unchecked and
              // as done when struck through.
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    block.isChecked
                        ? Icons.check_box_rounded
                        : Icons.check_box_outline_blank_rounded,
                    size: 20,
                    color: block.isChecked
                        ? device.accent
                        : device.textTertiary,
                  ),
                  const SizedBox(width: ColdSpace.sm),
                  Expanded(
                    child: Text(
                      strings?.t(block.textKey) ?? '',
                      style: ColdType.body.copyWith(
                        color: block.isChecked
                            ? device.textTertiary
                            : device.textPrimary,
                        decoration: block.isChecked
                            ? TextDecoration.lineThrough
                            : null,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                strings?.t(block.textKey) ?? '',
                style: ColdType.body.copyWith(
                  color: device.textPrimary,
                  height: 1.55,
                ),
              ),
            const SizedBox(height: ColdSpace.md),
          ],
        ],
      ),
    );
  }
}

class _Folder {
  final String nameKey;
  final List<_Note> notes;

  const _Folder({required this.nameKey, required this.notes});
}

class _Note {
  final String id;
  final String titleKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isLocked;
  final String? lockPassword;
  final List<_Block> blocks;

  const _Note({
    required this.id,
    required this.titleKey,
    required this.createdAt,
    required this.updatedAt,
    required this.isLocked,
    required this.lockPassword,
    required this.blocks,
  });
}

/// One line of a note — plain text, or a checklist item with its own
/// checked state.
class _Block {
  final bool isCheckbox;
  final String textKey;
  final bool isChecked;

  const _Block({
    required this.isCheckbox,
    required this.textKey,
    required this.isChecked,
  });
}

List<_Folder> _readFolders(CaseFile file) {
  final raw = file.appData('notes')?['folders'];
  if (raw is! List) return const [];

  return [
    for (final entry in raw)
      if (entry is Map<String, dynamic>)
        _Folder(
          nameKey: '${entry['name_key']}',
          notes: [
            for (final rawNote in (entry['notes'] as List? ?? const []))
              if (rawNote is Map<String, dynamic>) ?_readNote(rawNote),
          ],
        ),
  ];
}

_Note? _readNote(Map<String, dynamic> json) {
  final created = DateTime.tryParse('${json['created_at']}');
  final updated = DateTime.tryParse('${json['updated_at']}');
  if (created == null || updated == null) return null;

  final rawBlocks = (json['content'] as Map<String, dynamic>?)?['blocks'];
  return _Note(
    id: '${json['id']}',
    titleKey: '${json['title_key']}',
    createdAt: created,
    updatedAt: updated,
    isLocked: json['is_locked'] == true,
    lockPassword: json['lock_password'] as String?,
    blocks: [
      for (final block in (rawBlocks as List? ?? const []))
        if (block is Map && block['text_key'] != null)
          _Block(
            isCheckbox: block['type'] == 'checkbox',
            textKey: '${block['text_key']}',
            isChecked: block['is_checked'] == true,
          ),
    ],
  );
}
