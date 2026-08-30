import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../phone_format.dart';

/// Music.
///
/// The listening history is the evidence and the rest is context, so History is
/// the tab that opens. What somebody was playing at 21:05 is a timestamp nobody
/// curates and nobody thinks to clear — it places a person at a minute more
/// quietly than a message does, because it was never addressed to anyone.
///
/// Playlists earn their tab for a different reason: a playlist has a **made-on
/// date** and a name somebody chose, and across these cases that pairing has
/// been the tell more than once.
class MusicScreen extends StatelessWidget {
  final CaseFile file;
  final CaseStrings? strings;

  const MusicScreen({super.key, required this.file, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final data = file.appData('spotify') ?? const {};

    final played = _tracks(data['recently_played'])
      ..sort((a, b) {
        final x = a.playedAt, y = b.playedAt;
        if (x == null || y == null) return 0;
        return y.compareTo(x);
      });
    final liked = _tracks(data['liked_songs']);
    final playlists = _playlists(
      data,
      _tracks(data['recently_played']) + liked,
    );

    final tabs = <({String labelKey, String fallback, Widget view})>[
      (
        labelKey: 'ui.spotify.recent',
        fallback: 'History',
        view: _TrackList(tracks: played, strings: strings, showTime: true),
      ),
      if (playlists.isNotEmpty)
        (
          labelKey: 'ui.playlists',
          fallback: 'Playlists',
          view: _Playlists(playlists: playlists, strings: strings),
        ),
      if (liked.isNotEmpty)
        (
          labelKey: 'ui.spotify.liked',
          fallback: 'Liked',
          view: _TrackList(tracks: liked, strings: strings, showTime: false),
        ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: device.background,
        appBar: AppBar(
          title: Text(strings?.c('ui.app.spotify') ?? 'Airwave'),
          bottom: tabs.length == 1
              ? null
              : TabBar(
                  labelColor: device.accent,
                  unselectedLabelColor: device.textSecondary,
                  indicatorColor: device.accent,
                  labelStyle: ColdType.label,
                  tabs: [
                    for (final tab in tabs)
                      Tab(text: strings?.c(tab.labelKey) ?? tab.fallback),
                  ],
                ),
        ),
        body: TabBarView(children: [for (final tab in tabs) tab.view]),
      ),
    );
  }

  static List<_Track> _tracks(Object? raw) {
    if (raw is! List) return [];
    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          _Track(
            id: '${entry['id']}',
            // Titles and artists are proper nouns and stay untranslated.
            title: '${entry['title'] ?? ''}',
            artist: '${entry['artist'] ?? ''}',
            playedAt: DateTime.tryParse('${entry['played_at']}'),
          ),
    ];
  }

  /// Playlists, with their tracks resolved from wherever the case listed them.
  ///
  /// A track id can appear in `recently_played`, in `liked_songs`, or in
  /// neither. An id with no track behind it is dropped rather than drawn as a
  /// blank row — the count under the name stays honest that way.
  static List<_Playlist> _playlists(
    Map<String, dynamic> data,
    List<_Track> known,
  ) {
    final raw = data['playlists'];
    if (raw is! List) return const [];
    final byId = {for (final track in known) track.id: track};

    return [
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          _Playlist(
            nameKey: '${entry['name_key']}',
            createdAt: DateTime.tryParse('${entry['created_at']}'),
            trackCount: (entry['track_ids'] as List? ?? const []).length,
            tracks: [
              for (final id in (entry['track_ids'] as List? ?? const []))
                ?byId['$id'],
            ],
          ),
    ];
  }
}

class _TrackList extends StatelessWidget {
  final List<_Track> tracks;
  final CaseStrings? strings;

  /// History shows when; a liked list has no when to show.
  final bool showTime;

  const _TrackList({
    required this.tracks,
    required this.strings,
    required this.showTime,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    if (tracks.isEmpty) {
      return Center(
        child: Text(
          strings?.c('ui.spotify.no_liked') ?? 'Nothing here',
          style: ColdType.body.copyWith(color: device.textTertiary),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      itemCount: tracks.length,
      separatorBuilder: (_, _) => Padding(
        padding: const EdgeInsets.only(left: 56),
        child: Divider(height: 1, color: device.hairline),
      ),
      itemBuilder: (context, i) {
        final track = tracks[i];
        return ListTile(
          leading: Icon(Icons.music_note, color: device.textTertiary, size: 20),
          title: Text(
            track.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.subtitle.copyWith(color: device.textPrimary),
          ),
          subtitle: Text(
            track.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: ColdType.bodySmall.copyWith(color: device.textSecondary),
          ),
          trailing: showTime && track.playedAt != null
              ? Text(
                  format.dateTime(track.playedAt!),
                  style: ColdType.micro.copyWith(color: device.textTertiary),
                )
              : null,
        );
      },
    );
  }
}

class _Playlists extends StatelessWidget {
  final List<_Playlist> playlists;
  final CaseStrings? strings;

  const _Playlists({required this.playlists, required this.strings});

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    return ListView(
      padding: const EdgeInsets.all(ColdSpace.lg),
      children: [
        for (final playlist in playlists)
          Container(
            margin: const EdgeInsets.only(bottom: ColdSpace.sm),
            decoration: BoxDecoration(
              color: device.surfaceRaised,
              borderRadius: ColdRadius.card,
            ),
            child: ExpansionTile(
              shape: const Border(),
              collapsedShape: const Border(),
              iconColor: device.textSecondary,
              collapsedIconColor: device.textTertiary,
              title: Text(
                strings?.t(playlist.nameKey) ?? '',
                style: ColdType.subtitle.copyWith(color: device.textPrimary),
              ),
              subtitle: Text(
                [
                  strings?.cp('ui.spotify.songs_n', {
                        'count': playlist.trackCount,
                      }) ??
                      '${playlist.trackCount}',
                  // When a playlist was made is as much a fact as what is on
                  // it — somebody sat down on a particular evening and built
                  // this.
                  if (playlist.createdAt != null)
                    format.dateWithYear(playlist.createdAt!),
                ].join('  ·  '),
                style: ColdType.meta.copyWith(color: device.textTertiary),
              ),
              children: [
                for (final track in playlist.tracks)
                  ListTile(
                    dense: true,
                    title: Text(
                      track.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ColdType.bodySmall.copyWith(
                        color: device.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      track.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ColdType.micro.copyWith(
                        color: device.textTertiary,
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

class _Track {
  final String id;
  final String title;
  final String artist;
  final DateTime? playedAt;

  const _Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.playedAt,
  });
}

class _Playlist {
  final String nameKey;
  final DateTime? createdAt;

  /// What the case says is on it, which can exceed the tracks we can resolve.
  final int trackCount;

  final List<_Track> tracks;

  const _Playlist({
    required this.nameKey,
    required this.createdAt,
    required this.trackCount,
    required this.tracks,
  });
}
