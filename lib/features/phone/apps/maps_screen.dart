import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';
import 'map_ground.dart';

/// Location history.
///
/// Two tabs, because the screen answers two different questions and one layout
/// could not do both. **Map** is where; **History** is when, and for how long
/// — and what breaks a case is almost never where. Four hours at an address at
/// midnight and thirty-eight minutes at the same address at seven are
/// different events, and a pin cannot show that.
///
/// It used to be one screen: a 220pt map with a strip of entries under it and
/// a small pill switching between the recorded history and the owner's saved
/// pins. The map was too small to read, the list was too short to scan, and
/// the switch was drawn **only when a case had both** — so on a case that had
/// saved a place and recorded nothing, or the other way round, there was no
/// switch and no way to the other half. A player who had been told a place by
/// name had nowhere to go and look it up.
///
/// The History tab now lists everything the case authored, saved pins
/// included, with the address, the day, the time, how long, and the note.
class MapsScreen extends StatefulWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const MapsScreen({super.key, required this.file, required this.strings});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen>
    with SingleTickerProviderStateMixin {
  final MapController _map = MapController();
  late final TabController _tabs = TabController(length: 2, vsync: this);

  /// The pin whose card is open over the map, or null for none.
  _Visit? _open;

  @override
  void dispose() {
    _tabs.dispose();
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final history = _read();
    final saved = _readSaved();
    final everywhere = [...history, ...saved];

    if (everywhere.isEmpty) {
      return Scaffold(
        backgroundColor: device.background,
        appBar: AppBar(
          title: Text(widget.strings?.c('ui.app.maps') ?? 'Atlas'),
        ),
        body: Center(
          child: Text(
            widget.strings?.c('ui.no_results') ?? 'No results',
            style: ColdType.body.copyWith(color: device.textTertiary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        title: Text(widget.strings?.c('ui.app.maps') ?? 'Atlas'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: device.accent,
          labelColor: device.accent,
          unselectedLabelColor: device.textTertiary,
          labelStyle: ColdType.label,
          tabs: [
            Tab(text: widget.strings?.c('ui.maps.map_view') ?? 'Map View'),
            Tab(text: widget.strings?.c('ui.maps.history') ?? 'History'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _mapTab(context, history, everywhere),
          _historyTab(context, history, saved),
        ],
      ),
    );
  }

  Widget _mapTab(
    BuildContext context,
    List<_Visit> history,
    List<_Visit> everywhere,
  ) {
    final device = context.device;
    final centre = everywhere.first;

    return Stack(
      children: [
        FlutterMap(
          mapController: _map,
          options: MapOptions(
            initialCenter: LatLng(centre.lat, centre.lng),
            initialZoom: 13,
            // Tapping bare ground puts the card away, the way closing it does.
            onTap: (_, _) => setState(() => _open = null),
          ),
          children: [
            // The ground is painted first and always: a graticule with real
            // latitude and longitude on it, no network, no blank.
            const MapGround(),
            // The map itself, over the top. This is what v1 drew and what
            // this screen is supposed to be — the graticule alone is a
            // coordinate grid, not a city, and reading a route across it
            // tells the player nothing about where anybody was.
            //
            // It is layered rather than swapped in because a tile that does
            // not arrive paints nothing, and nothing over the ground is the
            // ground. v1 put tiles on bare grey and a lost connection left a
            // blank screen; here a lost connection leaves the graticule.
            //
            // **`INTERNET` was in the debug manifest only** — the one Flutter
            // writes for hot reload — so tiles loaded while developing and a
            // release build would never have fetched one. That is the whole
            // of "the map sometimes doesn't show".
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.coldmind',
              // Keep the device register: the tiles are a warm daylight map
              // and every other pixel on this phone is not.
              tileBuilder: (context, tile, image) => ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  // Desaturate, then pull the whole thing dark.
                  0.2126, 0.7152, 0.0722, 0, -16,
                  0.2126, 0.7152, 0.0722, 0, -12,
                  0.2126, 0.7152, 0.0722, 0, -4,
                  0, 0, 0, 1, 0,
                ]),
                child: tile,
              ),
            ),
            // The route between consecutive points, oldest to newest. On a
            // plain ground this is most of what the map has to say: not where
            // the phone was, but that it kept going back to the same three
            // places.
            if (history.length > 1)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [
                      for (final visit in history.reversed)
                        LatLng(visit.lat, visit.lng),
                    ],
                    strokeWidth: 1.4,
                    color: device.accent.withValues(alpha: 0.35),
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                for (final visit in everywhere)
                  Marker(
                    point: LatLng(visit.lat, visit.lng),
                    width: 34,
                    height: 34,
                    child: GestureDetector(
                      onTap: () => setState(() => _open = visit),
                      child: _Pin(
                        visit: visit,
                        strings: widget.strings,
                        selected: identical(visit, _open),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        if (_open case final visit?)
          Positioned(
            left: ColdSpace.lg,
            right: ColdSpace.lg,
            bottom: ColdSpace.lg,
            child: _Card(
              visit: visit,
              strings: widget.strings,
              onClose: () => setState(() => _open = null),
            ),
          ),
      ],
    );
  }

  Widget _historyTab(
    BuildContext context,
    List<_Visit> history,
    List<_Visit> saved,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      children: [
        // Saved first. A visit is something the phone recorded; a saved place
        // is something the owner **chose** to keep, which is a different kind
        // of fact and occasionally the louder one.
        if (saved.isNotEmpty) ...[
          _Heading(
            label: widget.strings?.c('ui.saved_places') ?? 'Saved Places',
            count: saved.length,
          ),
          for (final visit in saved)
            _Row(
              visit: visit,
              strings: widget.strings,
              onTap: () => _show(visit),
            ),
        ],
        if (history.isNotEmpty) ...[
          _Heading(
            label: widget.strings?.c('ui.maps.history') ?? 'History',
            count: history.length,
          ),
          for (final visit in history)
            _Row(
              visit: visit,
              strings: widget.strings,
              onTap: () => _show(visit),
            ),
        ],
      ],
    );
  }

  /// Sends the map to a place picked out of the list, and opens its card.
  void _show(_Visit visit) {
    setState(() => _open = visit);
    _tabs.animateTo(0);
    _map.move(LatLng(visit.lat, visit.lng), 15);
  }

  /// Where the phone went, newest first.
  List<_Visit> _read() {
    final raw = widget.file.appData('maps')?['location_history'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Visit.fromJson(entry),
    ]..sort((a, b) => b.at!.compareTo(a.at!));
  }

  /// Where the owner chose to keep a pin. Left in authored order: a saved list
  /// has no chronology to sort by, and the order somebody saved things in is
  /// the only order there is.
  List<_Visit> _readSaved() {
    final raw = widget.file.appData('maps')?['saved_places'];
    if (raw is! List) return const [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>) ?_Visit.savedFromJson(entry),
    ];
  }
}

/// A pin on the map, drawn for what kind of place it is.
///
/// `category` is authored on every location in every case and nothing read it.
/// A row of identical markers says only "the phone was in a city"; the same
/// row with a restaurant, an airport and eleven plain pins says where
/// somebody's week went.
class _Pin extends StatelessWidget {
  final _Visit visit;
  final CaseStrings? strings;
  final bool selected;

  const _Pin({
    required this.visit,
    required this.strings,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Semantics(
      // The marker is a painted shape with an icon in it and no text of its
      // own, which is silent to a screen reader.
      label: strings?.t(visit.nameKey) ?? '',
      button: true,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? device.danger : colourFor(visit.category, device),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Icon(iconFor(visit.category), color: Colors.white, size: 17),
      ),
    );
  }

  static IconData iconFor(String? category) => switch (category) {
    'hotel' => Icons.hotel,
    'restaurant' => Icons.restaurant,
    'bar' => Icons.local_bar,
    'airport' => Icons.flight,
    'shopping' => Icons.shopping_bag,
    _ => Icons.place,
  };

  /// Muted rather than saturated: this is the device register, and a row of
  /// bright pins would be the loudest thing on a phone that has none.
  static Color colourFor(String? category, DeviceColors device) =>
      switch (category) {
        'hotel' => const Color(0xFFB4762C),
        'restaurant' => const Color(0xFFA8433C),
        'bar' => const Color(0xFF7A4E8C),
        'airport' => const Color(0xFF3A6EA5),
        'shopping' => const Color(0xFFA8477A),
        _ => device.accent,
      };
}

/// The card that opens over the map when a pin is tapped.
class _Card extends StatelessWidget {
  final _Visit visit;
  final CaseStrings? strings;
  final VoidCallback onClose;

  const _Card({
    required this.visit,
    required this.strings,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    return Container(
      padding: const EdgeInsets.all(ColdSpace.lg),
      decoration: BoxDecoration(
        color: device.surfaceRaised,
        borderRadius: ColdRadius.card,
        border: Border.all(color: device.hairline),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  strings?.t(visit.nameKey) ?? '',
                  style: ColdType.subtitle.copyWith(color: device.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Icon(Icons.close, size: 18, color: device.textTertiary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            strings?.t(visit.addressKey) ?? '',
            style: ColdType.bodySmall.copyWith(color: device.textSecondary),
          ),
          if (visit.at case final at?) ...[
            const SizedBox(height: ColdSpace.sm),
            Text(
              _when(format, at, visit.minutes),
              style: ColdType.micro.copyWith(color: device.textTertiary),
            ),
          ],
          if (visit.noteKey case final note?) ...[
            const SizedBox(height: ColdSpace.sm),
            Text(
              strings?.t(note) ?? '',
              style: ColdType.bodySmall.copyWith(color: device.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

/// A section head in the History tab.
class _Heading extends StatelessWidget {
  final String label;
  final int count;

  const _Heading({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.lg,
        ColdSpace.lg,
        ColdSpace.sm,
      ),
      child: Text(
        '$label  $count',
        style: ColdType.label.copyWith(color: device.textTertiary),
      ),
    );
  }
}

/// One place in the History tab.
class _Row extends StatelessWidget {
  final _Visit visit;
  final CaseStrings? strings;
  final VoidCallback onTap;

  const _Row({
    required this.visit,
    required this.strings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.lg,
          vertical: ColdSpace.md,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: device.hairline)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2, right: ColdSpace.md),
              child: Icon(
                _Pin.iconFor(visit.category),
                size: 18,
                color: _Pin.colourFor(visit.category, device),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings?.t(visit.nameKey) ?? '',
                    style: ColdType.body.copyWith(color: device.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    strings?.t(visit.addressKey) ?? '',
                    style: ColdType.micro.copyWith(color: device.textTertiary),
                  ),
                  // A saved place has no timestamp; it is a pin somebody kept,
                  // not a moment the phone recorded.
                  if (visit.at case final at?) ...[
                    const SizedBox(height: 4),
                    Text(
                      _when(format, at, visit.minutes),
                      style: ColdType.micro.copyWith(
                        color: device.textSecondary,
                      ),
                    ),
                  ],
                  if (visit.noteKey case final note?) ...[
                    const SizedBox(height: 4),
                    Text(
                      strings?.t(note) ?? '',
                      style: ColdType.bodySmall.copyWith(
                        color: device.textPrimary,
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

/// "Tue 4 Mar 2025 · 21:47 · 2h 15m".
///
/// How long somebody stayed is the difference between passing through and
/// being there, so it is on the same line as the clock rather than off in a
/// column of its own.
String _when(PhoneFormat format, DateTime at, int? minutes) {
  final stamp = '${format.dayAndDate(at)}  ·  ${format.time(at)}';
  return minutes == null ? stamp : '$stamp  ·  ${_span(minutes)}';
}

/// "38m", "2h", "2h 15m".
String _span(int minutes) {
  if (minutes < 60) return '${minutes}m';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
}

/// A pin on the map: somewhere the phone went, or somewhere the owner saved.
///
/// The two are the same shape minus a clock. A visit is something the phone
/// recorded; a saved place is something the owner **chose** to keep, which is
/// a different kind of fact and occasionally the louder one.
class _Visit {
  final String nameKey;
  final String addressKey;
  final String? noteKey;
  final String? category;
  final double lat;
  final double lng;
  final int? minutes;

  /// Null for a saved place, which has no time attached to it.
  final DateTime? at;

  const _Visit({
    required this.nameKey,
    required this.addressKey,
    required this.noteKey,
    required this.category,
    required this.lat,
    required this.lng,
    required this.minutes,
    required this.at,
  });

  static _Visit? fromJson(Map<String, dynamic> json) {
    final at = DateTime.tryParse('${json['visited_at']}');
    if (at == null) return null;
    return _at(json, at);
  }

  static _Visit? savedFromJson(Map<String, dynamic> json) => _at(json, null);

  static _Visit? _at(Map<String, dynamic> json, DateTime? at) {
    final lat = (json['lat'] as num?)?.toDouble();
    final lng = (json['lng'] as num?)?.toDouble();
    if (lat == null || lng == null) return null;
    return _Visit(
      nameKey: '${json['name_key']}',
      addressKey: '${json['address_key']}',
      noteKey: json['note_key'] as String?,
      category: json['category'] as String?,
      lat: lat,
      lng: lng,
      minutes: (json['duration_minutes'] as num?)?.toInt(),
      at: at,
    );
  }
}
