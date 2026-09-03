import 'dart:convert';
import 'dart:io';

import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/models/person.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/features/phone/phone_home_screen.dart';
import 'package:coldmind/features/phone/widgets/app_pager.dart';
import 'package:coldmind/features/phone/widgets/home_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// The gate every case has to pass before it can ship.
///
/// v1 had this as a Node script that never ran, because Node was not installed
/// on the machine the game was actually written on. As a test it runs with
/// everything else, which is the only reason a check like this stays true.
///
/// The one that matters most is "every question points at an installed app":
/// getting it wrong strands the player on a question they cannot answer, with
/// no way back.
void main() {
  final caseIds =
      Directory('assets/cases')
          .listSync()
          .whereType<Directory>()
          .map((d) => d.path.split(Platform.pathSeparator).last)
          .where((id) => File('assets/cases/$id/case.json').existsSync())
          .toList()
        ..sort();

  test('there are cases to check', () {
    expect(caseIds, isNotEmpty);
  });

  for (final id in caseIds) {
    group(id, () {
      late Map<String, dynamic> raw;
      late CaseFile file;
      late PeoplePool people;
      late Map<String, dynamic> strings;

      setUpAll(() {
        raw = _readJson('assets/cases/$id/case.json');
        file = CaseFile.fromJson(raw);
        people = PeoplePool.fromJson(
          _readJson('assets/people/people_$id.json'),
        );
        strings = _readJson('assets/l10n/en/$id.json');
      });

      test('parses into the v2 model', () {
        expect(file.schema, 2);
        expect(file.id, id);
        expect(file.questions, isNotEmpty);
        expect(file.apps, isNotEmpty);
      });

      test('question indices run 1..n with no gaps', () {
        final indices = file.questions.map((q) => q.index).toList();
        expect(
          indices,
          List.generate(file.questions.length, (i) => i + 1),
          reason:
              'question order drives unlocking, so it cannot skip or repeat',
        );
      });

      test('every question points at an app that is on the phone', () {
        for (final q in file.questions) {
          expect(
            file.hasApp(q.app),
            isTrue,
            reason:
                'Q${q.index} sends the player to "${q.app}", which this '
                'phone does not have installed — the question is unanswerable',
          );
        }
      });

      test('every lock step targets an app that is on the phone', () {
        for (final step in file.orderedLocks) {
          expect(
            file.hasApp(step.targetApp),
            isTrue,
            reason:
                'lock step ${step.id} unlocks "${step.targetApp}", which '
                'is not installed',
          );
        }
      });

      test('nothing in a locked album is on show somewhere else', () {
        // The leak that makes a lock decorative. A photograph put behind a
        // passcode is behind it because seeing it is supposed to cost the
        // player a rung of the chain — and the same photo id listed in
        // Recents, or in an album with no password on it, hands it over for
        // free while the locked album still sits there asking for a code.
        //
        // Nothing about the screen looks wrong when this happens: the album
        // is locked, the passcode works, and the picture was already seen.
        final photos = raw['apps']?['photos'] as Map<String, dynamic>?;
        if (photos == null) return;

        final albums = (photos['albums'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()
            .toList();

        final locked = <String, String>{};
        for (final album in albums.where((a) => a['is_locked'] == true)) {
          for (final id in (album['photo_ids'] as List? ?? const [])) {
            locked['$id'] = '${album['id']}';
          }
        }
        if (locked.isEmpty) return;

        final leaks = <String>[];

        for (final id in (photos['recents'] as List? ?? const [])) {
          if (locked.containsKey('$id')) {
            leaks.add('$id is in ${locked['$id']} and also in Recents');
          }
        }

        for (final album in albums.where((a) => a['is_locked'] != true)) {
          for (final id in (album['photo_ids'] as List? ?? const [])) {
            if (locked.containsKey('$id')) {
              leaks.add(
                '$id is in ${locked['$id']} and also in the open album '
                '${album['id']}',
              );
            }
          }
        }

        expect(leaks, isEmpty, reason: '\n${leaks.join('\n')}');
      });

      test('a locked picture is nowhere else in the case at all', () {
        // The check above asks the question inside Photos. This one asks it of
        // the whole document, because a photograph is a file path and any
        // surface in the case can name one.
        //
        // s09 did. `diadem.jpg` sat in the locked album `album_003`, and the
        // corkboard pinned that same file as the node `b_diadem` — so the
        // picture behind the passcode was the second thing the player saw,
        // before question one, in the case's own opening picture. The album
        // still asked for `0403`.
        final photos = raw['apps']?['photos'] as Map<String, dynamic>?;
        if (photos == null) return;

        final lockedIds = <String>{
          for (final album in (photos['albums'] as List? ?? const [])
              .whereType<Map<String, dynamic>>())
            if (album['is_locked'] == true ||
                album['lock_password'] != null)
              for (final id in (album['photo_ids'] as List? ?? const []))
                '$id',
        };
        if (lockedIds.isEmpty) return;

        // What those ids actually look like on screen. Two ids pointing at
        // one file is the same leak wearing a different number.
        final hidden = <String, String>{
          for (final item in (photos['items'] as List? ?? const [])
              .whereType<Map<String, dynamic>>())
            if (lockedIds.contains('${item['id']}'))
              '${item['asset']}': '${item['id']}',
        };

        final leaks = <String>[];

        // Every surface except Photos itself, which is allowed to hold the
        // locked album — the board and the client chat included, since both
        // are shown before the chain has been climbed.
        final surfaces = <String, dynamic>{
          for (final app
              in (raw['apps'] as Map<String, dynamic>? ?? const {}).entries)
            if (app.key != 'photos') app.key: app.value,
          'board': raw['board'],
          'chats': raw['chats'],
        };

        for (final surface in surfaces.entries) {
          final text = jsonEncode(surface.value);
          for (final asset in hidden.entries) {
            if (text.contains(asset.key)) {
              leaks.add(
                '${asset.value} is behind a passcode and ${surface.key} draws '
                'the same picture (${asset.key})',
              );
            }
          }
        }

        // ...and a second, unlocked id for a locked file.
        for (final item in (photos['items'] as List? ?? const [])
            .whereType<Map<String, dynamic>>()) {
          if (lockedIds.contains('${item['id']}')) continue;
          final twin = hidden['${item['asset']}'];
          if (twin != null) {
            leaks.add(
              '${item['id']} is an unlocked second id for ${item['asset']}, '
              'which $twin puts behind a passcode',
            );
          }
        }

        expect(leaks, isEmpty, reason: '\n${leaks.join('\n')}');
      });

      test('every locked album actually holds something', () {
        // An empty locked album is a rung the player climbs to reach nothing.
        final albums =
            (raw['apps']?['photos']?['albums'] as List? ?? const [])
                .whereType<Map<String, dynamic>>();

        for (final album in albums.where((a) => a['is_locked'] == true)) {
          expect(
            (album['photo_ids'] as List? ?? const []),
            isNotEmpty,
            reason: 'album ${album['id']} is locked and empty',
          );
        }
      });

      test('every locked photo album carries the code that opens it', () {
        // The Photos surface asks for this password and shows the album only
        // when it matches. An album flagged locked with nothing to match
        // against is a door with no key anywhere in the case — the player
        // reaches it, cannot pass, and there is no way back.
        final albums = (raw['apps']?['photos']?['albums'] as List? ?? const []);
        for (final album in albums.whereType<Map<String, dynamic>>()) {
          if (album['is_locked'] != true) continue;
          final password = album['lock_password'];
          expect(
            password,
            isA<String>().having((p) => p.isNotEmpty, 'is not empty', isTrue),
            reason: 'album ${album['id']} is locked with no lock_password',
          );
        }
      });

      test('every lock step that opens an album points at a locked one', () {
        // The other half: a `find_code` step aimed at Photos sends the player
        // hunting for a passcode. If the album it names is not actually
        // locked, that hunt has no door at the end of it.
        final albums = {
          for (final album
              in (raw['apps']?['photos']?['albums'] as List? ?? const [])
                  .whereType<Map<String, dynamic>>())
            '${album['id']}': album,
        };

        for (final step in file.orderedLocks) {
          if (step.targetApp != 'photos') continue;
          final album = albums[step.targetItemId];
          expect(
            album,
            isNotNull,
            reason:
                'lock step ${step.id} targets album '
                '"${step.targetItemId}", which this case has no album for',
          );
          expect(
            album!['is_locked'],
            isTrue,
            reason:
                'lock step ${step.id} opens album ${step.targetItemId}, '
                'which is not locked',
          );
        }
      });

      test('lock steps are ordered 1..n with no gaps', () {
        final orders = file.orderedLocks.map((s) => s.order).toList();
        expect(orders, List.generate(orders.length, (i) => i + 1));
      });

      test('home layout only arranges apps that are installed', () {
        for (final key in [
          ...file.home.grid,
          ...file.home.dock,
          for (final page in file.home.widgetPages) ...page,
        ]) {
          expect(
            file.hasApp(key),
            isTrue,
            reason: '"$key" is placed on the home screen but not installed',
          );
        }
      });

      test('every widget a case declares has data to draw', () {
        // A widget key that builds nothing leaves half the row blank, which
        // looks like a bug rather than a phone. The data has to be there.
        for (final (page, wanted) in file.home.widgetPages.indexed) {
          final built = homeWidgetsFor(
            file,
            null,
            page: page,
            limit: wanted.length,
          ).map((w) => w.appKey);
          expect(
            built,
            orderedEquals(wanted),
            reason: 'a widget declared for page $page found nothing to show',
          );
        }
      });

      test('every page a case names widgets for is actually reachable', () {
        // How many app rows fit before a page turns over depends on whether
        // that page carries a widget — and a case with few apps installed and
        // a widget-bearing first page can fit its whole grid on page one,
        // never reaching a second page at all. A widget declared for a page
        // like that is authored, built, and never seen: `home.widget_pages`
        // has to match what `AppPager` will actually paginate to, not just
        // what the case wishes it had room for.
        final reachable = _reachablePages(file);
        expect(
          file.home.widgetPages.length,
          lessThanOrEqualTo(reachable),
          reason:
              'this case names widgets for ${file.home.widgetPages.length} '
              'pages, but with ${gridAppsFor(file).length} apps in the grid '
              'only $reachable page(s) are ever reached by a swipe',
        );
      });

      test('every case has at least two pages to swipe through', () {
        // Every case's home screen turns a page — a single-page phone reads
        // as an owner with almost nothing installed, not as a deliberate
        // choice, and it leaves the "second page" idea untestable for that
        // case entirely.
        expect(
          _reachablePages(file),
          greaterThanOrEqualTo(2),
          reason:
              'this case has only ${gridAppsFor(file).length} apps in the '
              'grid, which never turns a page',
        );
      });

      test('structured questions carry a payload that can be solved', () {
        for (final q in file.questions) {
          switch (q) {
            case FreeTextQuestion():
              expect(
                strings.containsKey(q.answersKey),
                isTrue,
                reason:
                    'Q${q.index} has no accepted answers at '
                    '"${q.answersKey}" — nothing the player types can pass',
              );
              final groups = strings[q.answersKey];
              expect(groups, isA<List<dynamic>>());
              expect((groups as List).isNotEmpty, isTrue);
            case TimelineQuestion():
              expect(
                [...q.order]..sort(),
                List.generate(q.events.length, (i) => i),
                reason:
                    'Q${q.index} chronological order must be a permutation '
                    'of the authored events',
              );
            case ContradictionQuestion():
              if (q.pair.isNotEmpty) {
                expect(q.pair.length, 2);
                for (final i in q.pair) {
                  expect(i, inInclusiveRange(0, q.snippets.length - 1));
                }
              } else {
                expect(
                  q.lieIndex,
                  isNotNull,
                  reason: 'Q${q.index} names neither a lie nor a pair',
                );
                expect(q.lieIndex!, inInclusiveRange(0, q.snippets.length - 1));
              }
            case SuspectQuestion():
              expect(
                q.personIds,
                contains(q.correctPersonId),
                reason: 'Q${q.index} accuses someone who is not in the line-up',
              );
              for (final personId in q.personIds) {
                expect(
                  people.byId(personId),
                  isNotNull,
                  reason:
                      'Q${q.index} lines up "$personId", who is not in the '
                      'cast file',
                );
              }
            case MultiSelectQuestion():
              expect(q.correctIndices, isNotEmpty);
              for (final i in q.correctIndices) {
                expect(i, inInclusiveRange(0, q.options.length - 1));
              }
          }
        }
      });

      test('every cast member exists in the cast file', () {
        for (final member in file.cast) {
          expect(
            people.byId(member.personId),
            isNotNull,
            reason:
                '${member.personId} is bound to this case but has no entry '
                'in people_$id.json',
          );
        }
      });

      test('every referenced string key is defined in the English pack', () {
        final common = _readJson('assets/l10n/en/common.json');
        final missing = _collectStrings(raw)
            .where((s) => s.startsWith('$id.'))
            .where((key) => !strings.containsKey(key))
            .where((key) => !common.containsKey(key))
            .toSet();
        expect(
          missing,
          isEmpty,
          reason: 'these keys are referenced but never defined',
        );
      });

      test('every referenced asset exists on disk', () {
        final missing = _collectStrings(raw)
            .where((s) => s.startsWith('assets/'))
            .map((path) => path.replaceAll('{lang}', 'en'))
            .where((path) => !File(path).existsSync())
            .toSet();
        expect(missing, isEmpty);
      });

      test('every asset the cast file points at exists on disk', () {
        final missing =
            _collectStrings(_readJson('assets/people/people_$id.json'))
                .where((s) => s.startsWith('assets/'))
                .where((path) => !File(path).existsSync())
                .toSet();
        expect(missing, isEmpty);
      });

      test(
        'every venmo transaction has someone to render as its counterparty',
        () {
          // The ledger shows a contact when a transaction carries `person_id`,
          // and a business name when it carries `recipient_name` instead. A
          // transaction with neither has nothing to draw a row for and used to
          // be dropped silently — the player would see fewer transactions than
          // were authored, with no error anywhere.
          final txs =
              (raw['apps']?['venmo']?['transactions'] as List? ?? const [])
                  .whereType<Map<String, dynamic>>();
          for (final tx in txs) {
            expect(
              tx['person_id'] != null || tx['recipient_name'] != null,
              isTrue,
              reason:
                  'transaction ${tx['id']} has neither person_id nor '
                  'recipient_name — it cannot be rendered',
            );
            expect(
              DateTime.tryParse('${tx['timestamp']}'),
              isNotNull,
              reason: 'transaction ${tx['id']} has an unparseable timestamp',
            );
          }
        },
      );

      test(
        'audio clues ship an English file, which every locale falls back to',
        () {
          for (final q in file.questions) {
            final audio = switch (q) {
              FreeTextQuestion(:final audio) => audio,
              TimelineQuestion(:final audio) => audio,
              ContradictionQuestion(:final audio) => audio,
              SuspectQuestion(:final audio) => audio,
              MultiSelectQuestion(:final audio) => audio,
            };
            if (audio == null) continue;
            expect(
              File(audio.resolve('en')).existsSync(),
              isTrue,
              reason:
                  'Q${q.index} plays ${audio.asset}, which has no English '
                  'recording — every other language resolves to it',
            );
          }
        },
      );
    });
  }
}

/// How many pages `AppPager` actually turns to for this case, given its real
/// grid app count and which of its pages carry a widget — the same page-by-
/// page arithmetic the pager itself runs, against its own public constants.
int _reachablePages(CaseFile file) {
  final total = gridAppsFor(file).length;
  var reachable = 1;
  var index = 0;
  var page = 0;
  do {
    final wanted = page < file.home.widgetPages.length
        ? file.home.widgetPages[page]
        : const <String>[];
    final hasHeader = homeWidgetsFor(
      file,
      null,
      page: page,
      limit: wanted.length,
    ).isNotEmpty;
    final capacity =
        (hasHeader ? kAppPagerRowsWithHeader : kAppPagerRowsPerPage) *
        kAppPagerColumns;
    index += capacity;
    page++;
    if (index < total) reachable++;
  } while (index < total);
  return reachable;
}

Map<String, dynamic> _readJson(String path) {
  final raw = File(path).readAsStringSync();
  // A byte-order mark ahead of `{` makes the decoder fail on a file that looks
  // perfectly fine in an editor.
  expect(raw.codeUnitAt(0), isNot(0xFEFF), reason: '$path starts with a BOM');
  return json.decode(raw) as Map<String, dynamic>;
}

/// Every string value anywhere in a JSON tree. Key references and asset paths
/// are just strings in the data, so collecting them all and filtering by shape
/// catches them wherever an author put them — including places a typed model
/// would not think to look.
Set<String> _collectStrings(Object? node) {
  final found = <String>{};
  void walk(Object? value) {
    if (value is String) {
      found.add(value);
    } else if (value is List) {
      value.forEach(walk);
    } else if (value is Map) {
      value.values.forEach(walk);
    }
  }

  walk(node);
  return found;
}
