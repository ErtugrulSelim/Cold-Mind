import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// Location history.
///
/// The map is the smaller half of this screen on purpose. What breaks a case is
/// almost never *where* — it is **when, and for how long**. Four hours at an
/// address at midnight and thirty-eight minutes at the same address at seven
/// are different events, and a pin cannot show that.
///
/// So the history is a timeline with durations, and the map follows the
/// selection. Tapping an entry moves the map; the map does not drive the list.
class MapsScreen extends StatefulWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const MapsScreen({super.key, required this.file, required this.strings});

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  final MapController _map = MapController();
  int _selected = 0;

  /// False shows where the phone went; true shows what the owner kept.
  bool _showSaved = false;

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(widget.strings);
    final history = _read();
    final saved = _readSaved();
    // A case with saved pins and no recorded history opens on the pins rather
    // than on an empty list — the switch is only drawn when both sides exist,
    // so otherwise there would be no way to reach them.
    final visits = _showSaved || history.isEmpty ? saved : history;

    if (visits.isEmpty) {
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

    final current = visits[_selected.clamp(0, visits.length - 1)];

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(widget.strings?.c('ui.app.maps') ?? 'Atlas')),
      body: Column(
        children: [
          SizedBox(
            height: 220,
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: LatLng(current.lat, current.lng),
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.coldmind',
                ),
                MarkerLayer(
                  markers: [
                    for (var i = 0; i < visits.length; i++)
                      Marker(
                        point: LatLng(visits[i].lat, visits[i].lng),
                        width: 26,
                        height: 26,
                        child: Icon(
                          Icons.location_on,
                          size: 26,
                          color: i == _selected
                              ? device.danger
                              : device.accent.withValues(alpha: 0.75),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          // Only offered when the case saved anything. A switch with one side
          // permanently empty is a promise the phone cannot keep.
          if (saved.isNotEmpty && history.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ColdSpace.lg,
                ColdSpace.md,
                ColdSpace.lg,
                ColdSpace.sm,
              ),
              // Wrapped rather than a Row: "Location History" and "Saved
              // Places" carry their counts, and in a language with longer
              // words for either the pair is wider than the phone.
              child: Wrap(
                spacing: ColdSpace.sm,
                runSpacing: ColdSpace.xs,
                children: [
                  _Mode(
                    label: widget.strings?.c('ui.maps.history') ?? 'History',
                    count: history.length,
                    selected: !_showSaved,
                    onTap: () => setState(() {
                      _showSaved = false;
                      _selected = 0;
                    }),
                  ),
                  _Mode(
                    label: widget.strings?.c('ui.saved_places') ?? 'Saved',
                    count: saved.length,
                    selected: _showSaved,
                    onTap: () => setState(() {
                      _showSaved = true;
                      _selected = 0;
                    }),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: ColdSpace.xl),
              itemCount: visits.length,
              separatorBuilder: (_, _) =>
                  Divider(height: 1, color: device.hairline),
              itemBuilder: (context, i) {
                final visit = visits[i];
                final selected = i == _selected;

                return InkWell(
                  onTap: () {
                    setState(() => _selected = i);
                    _map.move(LatLng(visit.lat, visit.lng), 15);
                  },
                  child: Container(
                    color: selected
                        ? device.accent.withValues(alpha: 0.08)
                        : null,
                    padding: const EdgeInsets.symmetric(
                      horizontal: ColdSpace.lg,
                      vertical: ColdSpace.md,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.strings?.t(visit.nameKey) ?? '',
                                style: ColdType.subtitle.copyWith(
                                  color: device.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                widget.strings?.t(visit.addressKey) ?? '',
                                style: ColdType.bodySmall.copyWith(
                                  color: device.textSecondary,
                                ),
                              ),
                              // A saved place has no timestamp; it is a pin
                              // somebody kept, not a moment the phone recorded.
                              if (visit.at != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  format.dateTime(visit.at!),
                                  style: ColdType.meta.copyWith(
                                    color: device.textTertiary,
                                  ),
                                ),
                              ],
                              if (visit.noteKey != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  widget.strings?.t(visit.noteKey!) ?? '',
                                  style: ColdType.micro.copyWith(
                                    color: device.textTertiary,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: ColdSpace.md),
                        // The column that matters. How long somebody stayed is
                        // the difference between passing through and being
                        // there.
                        if (visit.minutes != null)
                          Text(
                            _stay(visit.minutes!),
                            style: ColdType.meta.copyWith(
                              color: device.textPrimary,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _stay(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final rest = minutes % 60;
    return rest == 0 ? '${hours}h' : '${hours}h ${rest}m';
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

/// A pin on the map: somewhere the phone went, or somewhere the owner saved.
///
/// The two are the same shape minus a clock. A visit is something the phone
/// recorded; a saved place is something the owner **chose** to keep, which is
/// a different kind of fact and occasionally the louder one.
class _Visit {
  final String nameKey;
  final String addressKey;
  final String? noteKey;
  final double lat;
  final double lng;
  final int? minutes;

  /// Null for a saved place, which has no time attached to it.
  final DateTime? at;

  const _Visit({
    required this.nameKey,
    required this.addressKey,
    required this.noteKey,
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
      lat: lat,
      lng: lng,
      minutes: (json['duration_minutes'] as num?)?.toInt(),
      at: at,
    );
  }
}

/// Which list the map is showing.
class _Mode extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _Mode({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(999)),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected ? device.accentDim : device.surfaceRaised,
          borderRadius: const BorderRadius.all(Radius.circular(999)),
        ),
        child: Text(
          '$label  $count',
          style: ColdType.label.copyWith(
            color: selected ? Colors.white : device.textSecondary,
          ),
        ),
      ),
    );
  }
}
