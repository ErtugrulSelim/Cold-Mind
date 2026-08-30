import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';
import '../widgets/password_dialog.dart';

/// Photos.
///
/// A gallery is normally sorted by prettiness of layout. This one is sorted by
/// **when**, and every picture carries its date and place, because in a case a
/// photograph is only evidence once you know when it was taken. The viewer puts
/// that under the image rather than hiding it behind an info button.
///
/// Albums are the app's second job and the more important one. Every case ships
/// one album the owner put a passcode on, and that album is a rung of the lock
/// chain — the code for it is written down somewhere else on the phone. A
/// locked album therefore stays locked here and says so; opening on tap would
/// collapse the chain the case is built around.
///
/// Utilities — Hidden, Recently Deleted — are always shown, even when they are
/// empty. An empty bin is a fact about the owner too, and a section that
/// appears only when it has contents tells the player exactly when to care.
class PhotosScreen extends StatefulWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const PhotosScreen({super.key, required this.file, required this.strings});

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  /// Albums opened this session. Deliberately not persisted: re-entering the
  /// phone re-locks them, the way picking the device up again would.
  final Set<String> _unlocked = {};

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;
    final data = widget.file.appData('photos') ?? const {};
    final items = _readItems(data);
    final byId = {for (final item in items) item.id: item};

    final albums = [
      for (final raw in (data['albums'] as List? ?? const []))
        if (raw is Map<String, dynamic>) _Album.fromJson(raw, byId),
    ];

    final utilities = [
      _Album(
        id: '_hidden',
        nameKey: 'ui.hidden',
        common: true,
        photos: [for (final id in _ids(data['hidden'])) ?byId[id]],
      ),
      _Album(
        id: '_deleted',
        nameKey: 'ui.recently_deleted',
        common: true,
        photos: [for (final id in _ids(data['recently_deleted'])) ?byId[id]],
      ),
    ];

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: device.background,
        appBar: AppBar(
          title: Text(strings?.c('ui.app.photos') ?? 'Album'),
          bottom: TabBar(
            labelColor: device.accent,
            unselectedLabelColor: device.textSecondary,
            indicatorColor: device.accent,
            labelStyle: ColdType.label,
            tabs: [
              Tab(text: strings?.c('ui.recents') ?? 'Recents'),
              Tab(text: strings?.c('ui.albums') ?? 'Albums'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Grid(photos: items, strings: strings),
            ListView(
              padding: const EdgeInsets.fromLTRB(
                ColdSpace.lg,
                ColdSpace.lg,
                ColdSpace.lg,
                ColdSpace.xxl,
              ),
              children: [
                // Two across, cover-led. An album is recognised by its picture
                // long before its name is read.
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: ColdSpace.lg,
                  crossAxisSpacing: ColdSpace.md,
                  // The cover is square; the name and count sit under it.
                  childAspectRatio: 0.78,
                  children: [
                    for (final album in albums)
                      _AlbumTile(
                        album: album,
                        strings: strings,
                        isOpen: album.isOpen(_unlocked),
                        onTap: () => _open(album),
                      ),
                  ],
                ),
                const SizedBox(height: ColdSpace.lg),
                Text(
                  strings?.c('ui.photos.utilities') ?? 'Utilities',
                  style: ColdType.label.copyWith(color: device.textSecondary),
                ),
                const SizedBox(height: ColdSpace.sm),
                Container(
                  decoration: BoxDecoration(
                    color: device.surfaceRaised,
                    borderRadius: ColdRadius.card,
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < utilities.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            indent: ColdSpace.lg,
                            color: device.hairline,
                          ),
                        _UtilityRow(
                          album: utilities[i],
                          strings: strings,
                          onTap: () => _open(utilities[i]),
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
    );
  }

  /// Opens an album, asking for its passcode first when it has one.
  Future<void> _open(_Album album) async {
    if (!album.isOpen(_unlocked)) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => PasswordDialog(
          expected: album.lockPassword,
          titleKey: 'ui.lock.album',
          strings: widget.strings,
        ),
      );
      if (ok != true || !mounted) return;
      setState(() => _unlocked.add(album.id));
    }
    if (!mounted) return;

    final device = context.device;
    final name = album.name(widget.strings);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: device.background,
          appBar: AppBar(title: Text(name)),
          body: album.photos.isEmpty
              ? Center(
                  child: Text(
                    widget.strings?.c('ui.photos.no_photos') ?? 'No photos',
                    style: ColdType.body.copyWith(color: device.textTertiary),
                  ),
                )
              : _Grid(photos: album.photos, strings: widget.strings),
        ),
      ),
    );
  }

  static List<String> _ids(Object? raw) =>
      raw is List ? [for (final id in raw) '$id'] : const [];

  List<_Photo> _readItems(Map<String, dynamic> data) {
    final raw = data['items'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Photo.fromJson(entry),
    ]..sort((a, b) => b.takenAt.compareTo(a.takenAt));
  }
}

class _Grid extends StatelessWidget {
  final List<_Photo> photos;
  final CaseStrings? strings;

  const _Grid({required this.photos, required this.strings});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
      ),
      itemCount: photos.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _Viewer(photos: photos, index: i, strings: strings),
          ),
        ),
        child: Image.asset(
          photos[i].asset,
          fit: BoxFit.cover,
          cacheWidth: 300,
          errorBuilder: (_, _, _) =>
              ColoredBox(color: context.device.surfaceRaised),
        ),
      ),
    );
  }
}

/// An album as a cover, a name and a count.
class _AlbumTile extends StatelessWidget {
  final _Album album;
  final CaseStrings? strings;
  final bool isOpen;
  final VoidCallback onTap;

  const _AlbumTile({
    required this.album,
    required this.strings,
    required this.isOpen,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final cover = album.cover;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: ColdRadius.card,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (cover == null)
                    ColoredBox(color: device.surfaceRaised)
                  else
                    Image.asset(
                      cover.asset,
                      fit: BoxFit.cover,
                      cacheWidth: 400,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: device.surfaceRaised),
                    ),
                  // A locked album still shows its cover, blurred behind a
                  // scrim. Blanking it would hide that there is anything to
                  // want; the whole point is that the player can see the door.
                  if (!isOpen)
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.62),
                      child: Center(
                        child: Icon(
                          Icons.lock_rounded,
                          size: 28,
                          color: device.warning,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: ColdSpace.sm),
          Text(
            album.name(strings),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.subtitle.copyWith(color: device.textPrimary),
          ),
          Text(
            strings?.cp('ui.photos.photos_n', {'count': album.photos.length}) ??
                '${album.photos.length}',
            style: ColdType.meta.copyWith(color: device.textTertiary),
          ),
        ],
      ),
    );
  }
}

/// Hidden and Recently Deleted, which are rows rather than tiles because they
/// belong to the phone rather than to the owner.
class _UtilityRow extends StatelessWidget {
  final _Album album;
  final CaseStrings? strings;
  final VoidCallback onTap;

  const _UtilityRow({
    required this.album,
    required this.strings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.lg,
          vertical: ColdSpace.md,
        ),
        child: Row(
          children: [
            Icon(
              album.id == '_deleted'
                  ? Icons.delete_outline_rounded
                  : Icons.visibility_off_outlined,
              size: 19,
              color: device.textSecondary,
            ),
            const SizedBox(width: ColdSpace.md),
            Expanded(
              child: Text(
                album.name(strings),
                style: ColdType.subtitle.copyWith(color: device.textPrimary),
              ),
            ),
            Text(
              '${album.photos.length}',
              style: ColdType.meta.copyWith(color: device.textTertiary),
            ),
            const SizedBox(width: ColdSpace.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: device.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// One photograph, with when and where under it.
class _Viewer extends StatefulWidget {
  final List<_Photo> photos;
  final int index;
  final CaseStrings? strings;

  const _Viewer({
    required this.photos,
    required this.index,
    required this.strings,
  });

  @override
  State<_Viewer> createState() => _ViewerState();
}

class _ViewerState extends State<_Viewer> {
  late final PageController _controller = PageController(
    initialPage: widget.index,
  );
  late int _current = widget.index;

  /// Whether the current photo's transcript is expanded. Reset on every swipe
  /// — an open panel on the photo just left would look like it belonged to
  /// the one arrived at.
  bool _showDocument = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(widget.strings);
    final photo = widget.photos[_current];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, title: const Text('')),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() {
                _current = i;
                _showDocument = false;
              }),
              itemCount: widget.photos.length,
              itemBuilder: (context, i) => InteractiveViewer(
                maxScale: 5,
                child: Center(
                  child: Image.asset(
                    widget.photos[i].asset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: device.surfaceRaised),
                  ),
                ),
              ),
            ),
          ),
          // Under the picture, not behind an info button: a photograph without
          // its timestamp is decoration, and with it, it is evidence.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(ColdSpace.lg),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  format.dateTime(photo.takenAt),
                  style: ColdType.subtitle.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                if (photo.location != null)
                  Text(
                    photo.location!,
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
                if (photo.documentKey != null) ...[
                  const SizedBox(height: ColdSpace.sm),
                  InkWell(
                    onTap: () => setState(() => _showDocument = !_showDocument),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.description_outlined,
                          size: 14,
                          color: device.accent,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _showDocument
                              ? (widget.strings?.c('ui.photo_hide') ?? 'Hide')
                              : (widget.strings?.c('ui.photo_read') ?? 'Read'),
                          style: ColdType.micro.copyWith(
                            color: device.accent,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_showDocument)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: ColdSpace.sm),
                      padding: const EdgeInsets.all(ColdSpace.md),
                      constraints: const BoxConstraints(maxHeight: 220),
                      decoration: BoxDecoration(
                        color: device.surfaceRaised,
                        borderRadius: ColdRadius.card,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.strings?.c('ui.photo_document') ??
                                  'DOCUMENT',
                              style: ColdType.micro.copyWith(
                                color: device.textTertiary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.strings?.t(photo.documentKey!) ?? '',
                              style: ColdType.bodySmall.copyWith(
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Album {
  final String id;
  final String nameKey;
  final List<_Photo> photos;

  /// True when the name comes from the shared pack rather than the case's.
  final bool common;

  /// Whether the owner put a passcode on this album. Held separately from
  /// [lockPassword] so that an album marked locked with no password authored
  /// stays **shut** rather than falling open — a case with that mistake in it
  /// should strand the player on a locked door they can report, not quietly
  /// hand them the contents.
  final bool isLocked;

  /// The album's own passcode. A rung of the lock chain: the code is written
  /// down elsewhere on this phone.
  final String? lockPassword;

  /// The photo the owner chose as the face of the album, which is not
  /// necessarily the first one in it.
  final _Photo? cover;

  const _Album({
    required this.id,
    required this.nameKey,
    required this.photos,
    this.common = false,
    this.isLocked = false,
    this.lockPassword,
    this.cover,
  });

  factory _Album.fromJson(Map<String, dynamic> json, Map<String, _Photo> byId) {
    final photos = [
      for (final id in (json['photo_ids'] as List? ?? const [])) ?byId['$id'],
    ];
    return _Album(
      id: '${json['id']}',
      nameKey: '${json['name_key']}',
      photos: photos,
      isLocked: json['is_locked'] == true,
      lockPassword: json['lock_password'] as String?,
      // The face the owner chose, which is not necessarily the first photo in
      // the album — several cases pick a cover from the middle of the roll.
      cover:
          byId['${json['cover_photo_id']}'] ??
          (photos.isEmpty ? null : photos.first),
    );
  }

  /// An unlocked album is always open; a locked one opens only after its
  /// passcode has been entered this session.
  bool isOpen(Set<String> unlocked) => !isLocked || unlocked.contains(id);

  String name(CaseStrings? strings) =>
      common ? (strings?.c(nameKey) ?? '') : (strings?.t(nameKey) ?? '');
}

class _Photo {
  final String id;
  final String asset;
  final DateTime takenAt;
  final String? location;

  /// The transcript of what the photo shows written or displayed — a
  /// whiteboard, a screenshot, a scoresheet. A photograph on a 390pt phone is
  /// rarely legible at the resolution it was actually taken; the transcript is
  /// what lets the player read it instead of squinting at it.
  final String? documentKey;

  const _Photo({
    required this.id,
    required this.asset,
    required this.takenAt,
    required this.location,
    required this.documentKey,
  });

  static _Photo? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['taken_at']}');
    final asset = json['asset'] as String?;
    if (at == null || asset == null) return null;
    return _Photo(
      id: '${json['id']}',
      asset: asset,
      takenAt: at,
      location: json['location'] as String?,
      documentKey: json['document_key'] as String?,
    );
  }
}
