import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../contact_book.dart';
import '../phone_format.dart';
import '../widgets/avatar.dart';

/// The phone app: what was dialled, and who the phone knows.
///
/// Four tabs, because a real dialler has four and because each answers a
/// different question. Recents is the log — the one thing a call has that a
/// message does not is **duration**, and it is usually the evidence: a
/// four-minute call and a six-second call at the same minute are different
/// events, one a conversation and one somebody checking whether a phone still
/// rings.
///
/// Contacts is the address book, and it carries a fact the log cannot: **who
/// was never saved**. A phone that called a number forty times without giving
/// it a name has said something about that number, and the alphabetical list is
/// where that shows.
class CallsScreen extends StatefulWidget {
  final CaseFile file;
  final ContactBook contacts;
  final CaseStrings? strings;

  const CallsScreen({
    super.key,
    required this.file,
    required this.contacts,
    required this.strings,
  });

  @override
  State<CallsScreen> createState() => _CallsScreenState();
}

class _CallsScreenState extends State<CallsScreen> {
  int _tab = 0;

  /// What the player has typed on the keypad. Nothing dials — this is somebody
  /// else's phone and the player is reading it, not using it — but a keypad
  /// that does not respond to a tap reads as broken.
  String _dialled = '';

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;
    final calls = _readCalls();
    final book = _readContacts();
    final favourites = [
      for (final c in book)
        if (c.isFavourite) c,
    ];

    final tabs = <({IconData icon, String label, Widget view})>[
      (
        icon: Icons.access_time_rounded,
        label: strings?.c('ui.recents') ?? 'Recents',
        view: _Recents(
          calls: calls,
          contacts: widget.contacts,
          strings: strings,
        ),
      ),
      (
        icon: Icons.contacts_outlined,
        label: strings?.c('ui.phone.contacts') ?? 'Contacts',
        view: _Contacts(entries: book, contacts: widget.contacts),
      ),
      (
        icon: Icons.star_outline_rounded,
        label: strings?.c('ui.phone.favourites') ?? 'Favorites',
        view: _Favourites(entries: favourites, contacts: widget.contacts),
      ),
      (
        icon: Icons.dialpad_rounded,
        label: strings?.c('ui.phone.keypad') ?? 'Number Pad',
        view: _Keypad(
          dialled: _dialled,
          onKey: (key) => setState(() => _dialled += key),
          onBackspace: () => setState(() {
            if (_dialled.isNotEmpty) {
              _dialled = _dialled.substring(0, _dialled.length - 1);
            }
          }),
        ),
      ),
    ];

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(tabs[_tab].label)),
      body: IndexedStack(
        index: _tab,
        children: [for (final tab in tabs) tab.view],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: device.surface,
        indicatorColor: device.accentDim,
        height: 66,
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon, color: device.textSecondary),
              selectedIcon: Icon(tab.icon, color: device.accent),
              label: tab.label,
            ),
        ],
      ),
    );
  }

  List<_Call> _readCalls() {
    final raw = widget.file.appData('calls')?['recent_calls'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Call.fromJson(entry),
    ]..sort((a, b) => b.at.compareTo(a.at));
  }

  /// The phone's own address book, alphabetical.
  ///
  /// Everyone the case put in `contacts`, plus anyone the call log rang who was
  /// never saved — because an unsaved number that appears in the log is exactly
  /// the entry worth noticing, and leaving it out of the list would hide it.
  List<_Entry> _readContacts() {
    final book = <String, _Entry>{};

    for (final contact in widget.file.contacts) {
      book[contact.personId] = _Entry(
        personId: contact.personId,
        name: widget.contacts.displayName(contact.personId),
        subtitle: widget.contacts.isSaved(contact.personId)
            ? (widget.contacts.person(contact.personId)?.occupation ??
                  widget.contacts.phoneNumber(contact.personId))
            : widget.contacts.phoneNumber(contact.personId),
        isSaved: widget.contacts.isSaved(contact.personId),
        // Favourites are the people the owner rang most. Nothing in the schema
        // marks them, and a star the case never set would be invention.
        isFavourite: false,
      );
    }

    final rung = <String, int>{};
    for (final call in _readCalls()) {
      rung[call.personId] = (rung[call.personId] ?? 0) + 1;
      book.putIfAbsent(
        call.personId,
        () => _Entry(
          personId: call.personId,
          name: widget.contacts.displayName(call.personId),
          subtitle: widget.contacts.phoneNumber(call.personId),
          isSaved: false,
          isFavourite: false,
        ),
      );
    }

    // Derived, not authored: the three the phone rang most often.
    final ranked = rung.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = {for (final e in ranked.take(3)) e.key};

    final entries = [
      for (final entry in book.values)
        top.contains(entry.personId) ? entry.copyWithFavourite() : entry,
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    return entries;
  }
}

/// The call log.
class _Recents extends StatelessWidget {
  final List<_Call> calls;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _Recents({
    required this.calls,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    if (calls.isEmpty) {
      return Center(
        child: Text(
          strings?.c('ui.calls.no_calls') ?? 'No calls',
          style: ColdType.body.copyWith(color: device.textTertiary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      itemCount: calls.length,
      separatorBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(left: 74),
        child: Divider(height: 1, color: device.hairline),
      ),
      itemBuilder: (context, i) {
        final call = calls[i];
        final name = contacts.displayName(call.personId);
        final missed = call.type == 'missed';

        return ListTile(
          leading: Avatar(
            photoAsset: contacts.photo(call.personId),
            name: name,
            colorHex: contacts.avatarColor(call.personId),
            size: 42,
          ),
          title: Text(
            name,
            style: ColdType.subtitle.copyWith(
              // A missed call is the only kind the owner did not choose to
              // have, so it is the only one marked.
              color: missed ? device.danger : device.textPrimary,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(_icon(call.type), size: 13, color: device.textTertiary),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  format.dateTime(call.at),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ColdType.meta.copyWith(color: device.textTertiary),
                ),
              ),
            ],
          ),
          trailing: Text(
            call.durationSeconds == null
                ? '—'
                : format.duration(call.durationSeconds!),
            style: ColdType.meta.copyWith(
              color: missed ? device.danger : device.textSecondary,
              fontSize: 13,
            ),
          ),
        );
      },
    );
  }

  static IconData _icon(String type) => switch (type) {
    'incoming' => Icons.call_received,
    'outgoing' => Icons.call_made,
    _ => Icons.call_missed,
  };
}

/// The address book, sectioned by first letter.
class _Contacts extends StatelessWidget {
  final List<_Entry> entries;
  final ContactBook contacts;

  const _Contacts({required this.entries, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No contacts',
          style: ColdType.body.copyWith(color: device.textTertiary),
        ),
      );
    }

    // Letter headings, the way an address book reads. A number that was never
    // saved has no letter, so it files under #.
    final rows = <Widget>[];
    String? letter;
    for (final entry in entries) {
      final initial = entry.sortLetter;
      if (initial != letter) {
        letter = initial;
        rows.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ColdSpace.lg,
              ColdSpace.lg,
              ColdSpace.lg,
              ColdSpace.xs,
            ),
            child: Text(
              initial,
              style: ColdType.title.copyWith(color: device.textPrimary),
            ),
          ),
        );
      }
      rows.add(_ContactRow(entry: entry, contacts: contacts));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      children: rows,
    );
  }
}

class _ContactRow extends StatelessWidget {
  final _Entry entry;
  final ContactBook contacts;

  const _ContactRow({required this.entry, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return ListTile(
      leading: Avatar(
        photoAsset: contacts.photo(entry.personId),
        name: entry.name,
        colorHex: contacts.avatarColor(entry.personId),
        size: 44,
      ),
      title: Text(
        entry.name,
        style: ColdType.subtitle.copyWith(color: device.textPrimary),
      ),
      subtitle: Text(
        entry.subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: ColdType.bodySmall.copyWith(color: device.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (entry.isFavourite)
            Icon(Icons.favorite_rounded, size: 16, color: device.danger),
          const SizedBox(width: ColdSpace.sm),
          Icon(Icons.call_rounded, size: 20, color: device.accent),
        ],
      ),
    );
  }
}

/// The people the phone rang most, as faces.
class _Favourites extends StatelessWidget {
  final List<_Entry> entries;
  final ContactBook contacts;

  const _Favourites({required this.entries, required this.contacts});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    if (entries.isEmpty) {
      return Center(
        child: Text(
          'No favourites',
          style: ColdType.body.copyWith(color: device.textTertiary),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 3,
      padding: const EdgeInsets.all(ColdSpace.lg),
      mainAxisSpacing: ColdSpace.xl,
      crossAxisSpacing: ColdSpace.md,
      childAspectRatio: 0.82,
      children: [
        for (final entry in entries)
          Column(
            children: [
              Avatar(
                photoAsset: contacts.photo(entry.personId),
                name: entry.name,
                colorHex: contacts.avatarColor(entry.personId),
                size: 84,
              ),
              const SizedBox(height: ColdSpace.sm),
              Text(
                entry.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ColdType.bodySmall.copyWith(color: device.textPrimary),
              ),
            ],
          ),
      ],
    );
  }
}

/// The keypad.
class _Keypad extends StatelessWidget {
  final String dialled;
  final ValueChanged<String> onKey;
  final VoidCallback onBackspace;

  const _Keypad({
    required this.dialled,
    required this.onKey,
    required this.onBackspace,
  });

  static const List<({String digit, String letters})> _keys = [
    (digit: '1', letters: ''),
    (digit: '2', letters: 'ABC'),
    (digit: '3', letters: 'DEF'),
    (digit: '4', letters: 'GHI'),
    (digit: '5', letters: 'JKL'),
    (digit: '6', letters: 'MNO'),
    (digit: '7', letters: 'PQRS'),
    (digit: '8', letters: 'TUV'),
    (digit: '9', letters: 'WXYZ'),
    (digit: '*', letters: ''),
    (digit: '0', letters: '+'),
    (digit: '#', letters: ''),
  ];

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Text(
              dialled,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ColdType.display.copyWith(
                color: device.textPrimary,
                fontSize: 34,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: ColdSpace.xxl),
          childAspectRatio: 1.5,
          children: [
            for (final key in _keys)
              InkWell(
                onTap: () => onKey(key.digit),
                customBorder: const CircleBorder(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      key.digit,
                      style: ColdType.display.copyWith(
                        color: device.textPrimary,
                        fontSize: 30,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    if (key.letters.isNotEmpty)
                      Text(
                        key.letters,
                        style: ColdType.micro.copyWith(
                          color: device.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: ColdSpace.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 72),
              // Read-only, and it looks it: the call button is the app's own
              // colour but this phone is somebody else's and nothing here
              // places a call.
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: device.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.call_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              SizedBox(
                width: 72,
                child: dialled.isEmpty
                    ? null
                    : IconButton(
                        onPressed: onBackspace,
                        icon: Icon(
                          Icons.backspace_outlined,
                          color: device.textSecondary,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One line in the address book.
class _Entry {
  final String personId;
  final String name;
  final String subtitle;
  final bool isSaved;
  final bool isFavourite;

  const _Entry({
    required this.personId,
    required this.name,
    required this.subtitle,
    required this.isSaved,
    required this.isFavourite,
  });

  _Entry copyWithFavourite() => _Entry(
    personId: personId,
    name: name,
    subtitle: subtitle,
    isSaved: isSaved,
    isFavourite: true,
  );

  /// The heading this entry files under. A bare number has no letter.
  String get sortLetter {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '#';
    final first = trimmed.characters.first.toUpperCase();
    return RegExp(r'^\p{L}', unicode: true).hasMatch(first) ? first : '#';
  }
}

class _Call {
  final String personId;
  final String type;
  final int? durationSeconds;
  final DateTime at;

  const _Call({
    required this.personId,
    required this.type,
    required this.durationSeconds,
    required this.at,
  });

  static _Call? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['timestamp']}');
    final personId = json['person_id'] as String?;
    if (at == null || personId == null) return null;
    return _Call(
      personId: personId,
      type: '${json['type']}',
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      at: at,
    );
  }
}
