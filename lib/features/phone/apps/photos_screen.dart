import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';
import '../widgets/document_body.dart';
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

    // Recents is its own authored list, not "every photo on the phone".
    //
    // This tab used to draw `items`, which is the pool every album is built
    // out of — so every locked album's contents sat in Recents in plain view.
    // The passcode still worked, the album still said it was locked, and the
    // photographs behind it had already been seen. In all ten cases. On s07
    // that was the four hundred and sixteen counts, which two questions are
    // answered by.
    //
    // The cases author `recents` correctly and always did; nothing read it.
    // Where a case has none, everything inside a locked album is held back
    // rather than shown, so a new case cannot leak by omission.
    final lockedIds = {
      for (final album in albums)
        if (!album.isOpen(_unlocked))
          for (final photo in album.photos) photo.id,
    };
    final recentIds = _ids(data['recents']);
    final recents = recentIds.isEmpty
        ? [
            for (final item in items)
              if (!lockedIds.contains(item.id)) item,
          ]
        : [
            for (final id in recentIds)
              if (byId[id] case final photo? when !lockedIds.contains(id))
                photo,
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
            _Grid(photos: recents, strings: strings),
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

  /// The zoom on the photo being looked at.
  ///
  /// Pinching inside a [PageView] is a fight between two gestures: the second
  /// finger reaches the zoom, but the moment either finger moves sideways the
  /// pager takes the drag and turns the page. So the pager is switched off
  /// while a photo is zoomed in, and back on when it returns to fit — which is
  /// what [_zoomed] is watching for.
  final TransformationController _zoom = TransformationController();
  bool _zoomed = false;

  /// Where a double-tap landed, so the zoom goes to the thing that was tapped
  /// rather than to the middle. On these photographs the thing worth looking
  /// at is almost never in the middle: it is a note on a desk, a face at the
  /// end of a room, a number on a screen in the corner.
  TapDownDetails? _lastTap;

  @override
  void initState() {
    super.initState();
    _zoom.addListener(_onZoom);
  }

  void _onZoom() {
    final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
  }

  /// Double-tap in, double-tap out. Pinching on a 6-inch phone with one hand
  /// is the kind of thing that works in a demo.
  void _toggleZoom() {
    if (_zoomed) {
      _zoom.value = Matrix4.identity();
      return;
    }
    final at = _lastTap?.localPosition;
    if (at == null) return;
    const scale = 3.0;
    _zoom.value = Matrix4.identity()
      ..translateByDouble(-at.dx * (scale - 1), -at.dy * (scale - 1), 0, 1)
      ..scaleByDouble(scale, scale, scale, 1);
  }

  @override
  void dispose() {
    _zoom.removeListener(_onZoom);
    _zoom.dispose();
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
      // The caption sits at the very bottom of the screen and the transcript
      // opens underneath it, so without this the panel grows straight into the
      // system navigation bar. On s04 that put the last third of a torn
      // notepad page — the third with the password on it — behind the gesture
      // bar, on the one photograph the lock chain depends on being read.
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                // Locked while a photo is zoomed in, or panning across a
                // document turns the page instead.
                physics: _zoomed
                    ? const NeverScrollableScrollPhysics()
                    : const PageScrollPhysics(),
                onPageChanged: (i) => setState(() {
                  _current = i;
                  _showDocument = false;
                  _zoom.value = Matrix4.identity();
                }),
                itemCount: widget.photos.length,
                itemBuilder: (context, i) {
                  final image = Center(
                    child: Image.asset(
                      widget.photos[i].asset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          ColoredBox(color: device.surfaceRaised),
                    ),
                  );
                  // Only the page being looked at gets the controller; the
                  // neighbours PageView keeps built would otherwise share one
                  // transform and zoom in unison.
                  if (i != _current) return image;

                  return GestureDetector(
                    onDoubleTapDown: (d) => _lastTap = d,
                    onDoubleTap: _toggleZoom,
                    child: InteractiveViewer(
                      transformationController: _zoom,
                      maxScale: 6,
                      // Room to pull a corner into the middle of the screen.
                      // Without it the edges of a document stay unreachable
                      // at exactly the zoom you needed them at.
                      boundaryMargin: const EdgeInsets.all(80),
                      child: image,
                    ),
                  );
                },
              ),
            ),
            // Under the picture, not behind an info button: a photograph without
            // its timestamp is decoration, and with it, it is evidence.
            //
            // The picture itself sits on black, the way a lightbox should.
            // Everything under it is the app again and takes the app's skin —
            // Photos is a light one, and a strip of hardcoded black under a
            // white app was only ever half the problem the white-on-white
            // transcript was.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ColdSpace.lg),
              color: device.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    format.dateTime(photo.takenAt),
                    style: ColdType.subtitle.copyWith(
                      color: device.textPrimary,
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
                      onTap: () =>
                          setState(() => _showDocument = !_showDocument),
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
                                : (widget.strings?.c('ui.photo_read') ??
                                      'Read'),
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
                        // Two fifths of the screen rather than a fixed 220.
                        // These transcripts are the reading of a photograph
                        // that cannot be read, so the panel is the evidence;
                        // a fixed cap put s04's notepad page — four lines of
                        // prose and then the password — into a window that
                        // showed two thirds of it and made the rest a scroll
                        // inside a scroll.
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                        ),
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
                              DocumentBody(
                                text:
                                    widget.strings?.t(photo.documentKey!) ??
                                    '',
                                // From the skin, not hardcoded. Photos runs
                                // the light skin, where `surfaceRaised` is
                                // white — so white text meant the transcript
                                // was drawn, laid out and completely
                                // invisible. On s04 the invisible thing was
                                // the notepad page with the password on it.
                                color: device.textPrimary,
                                proseStyle: ColdType.bodySmall.copyWith(
                                  height: 1.45,
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
