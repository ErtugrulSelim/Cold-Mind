import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/app_router.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'phone_surface.dart';

/// Whether an app actually shows the case's own data.
///
/// `app_render_test` sweeps the same surfaces and proves something different:
/// that they draw without throwing and without overflowing. **An app that
/// silently renders an empty list passes it.** Mail with no mail, a vault with
/// no entries, a feed with no posts — each of those is a working widget over a
/// parsing bug, and each looks exactly like a case that simply has nothing in
/// that app.
///
/// That is not a hypothetical failure here. Venmo shipped for months dropping
/// sixty per cent of its transactions, because `_Tx.fromJson` required a field
/// half the authored rows did not have; the rows were skipped one by one and
/// the screen drew the remainder perfectly.
///
/// So this asks the one question the render sweep cannot: for every installed
/// app on every case, does **any** of that app's own authored text reach the
/// screen? Any, not all — most apps put their detail behind a tap, and a list
/// only builds what it can see.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  final loaded =
      <
        ({String id, CaseFile file, ContactBook contacts, CaseStrings strings})
      >[];
  late SharedPreferences prefs;

  setUpAll(() async {
    // Loaded here, not in a test body: a bundle read inside `testWidgets` runs
    // in a fake-async zone where it never completes.
    final logins = <String, Object>{};

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final strings = await repo.loadStrings(summary.id, 'en');
      final people = await repo.loadPeople(summary.id);

      // Gated apps start signed in. This is about contents; a login box would
      // report every locked surface as empty. The gate has its own test.
      logins['progress.logins.${summary.id}'] = file.apps.keys.toList();

      loaded.add((
        id: summary.id,
        file: file,
        contacts: ContactBook(file: file, people: people, strings: strings),
        strings: strings,
      ));
    }

    SharedPreferences.setMockInitialValues(logins);
    prefs = await SharedPreferences.getInstance();
  });

  testWidgets('every installed app shows some of its own data', (tester) async {
    usePhoneSurface(tester);

    final failures = <String>[];

    for (final entry in loaded) {
      for (final key in entry.file.apps.keys) {
        final data = entry.file.appData(key);
        if (data == null || data.isEmpty) continue;

        final expected = _authoredText(data, entry.strings);
        // Nothing to look for. A few apps are pure numbers — the games keep
        // scores and session times and no prose at all — and those are covered
        // by their own screen tests.
        if (expected.isEmpty) continue;

        final screen = buildAppScreen(
          appKey: key,
          file: entry.file,
          contacts: entry.contacts,
          strings: entry.strings,
        );
        if (screen == null) continue;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
            child: MaterialApp(theme: buildColdTheme(), home: screen),
          ),
        );
        await tester.pump(const Duration(milliseconds: 400));

        // Behind the app's own tabs as well as down its list. Photos keeps
        // albums on a second tab, and one of those albums is a rung of the
        // lock chain — a sweep that only looked at the tab an app opens on
        // would report every album name in the game as missing.
        var shown = <String>{};
        final tabCount = find.byType(Tab).evaluate().length;

        if (tabCount == 0) {
          shown = await _sweep(tester, expected);
        } else {
          for (var i = 0; i < tabCount; i++) {
            await tester.tap(find.byType(Tab).at(i));
            // Successive frames, not one long one. A single `pump(400ms)`
            // builds a single frame, and the tab's animation needs to be
            // driven — with one pump the view never changes, and this walked
            // every tab of every app without ever leaving the first.
            for (var frame = 0; frame < 12; frame++) {
              await tester.pump(const Duration(milliseconds: 40));
            }
            shown = shown.union(await _sweep(tester, expected));
            if (shown.intersection(expected).isNotEmpty) break;
          }
        }

        if (shown.intersection(expected).isEmpty) {
          failures.add(
            '${entry.id}:$key — none of ${expected.length} authored strings '
            'reached the screen. Wanted one of: '
            '${expected.take(3).map(_short).join(" | ")}',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}

/// Every string an app's own data says should be readable.
///
/// Two kinds. Anything whose field name ends in `_key` is a language-pack
/// lookup and is resolved; anything that is already a plain string is taken as
/// written, which is what catches the surfaces that are deliberately not
/// localized — wifi network names, book titles, cloud file names.
Set<String> _authoredText(Map<String, dynamic> data, CaseStrings strings) {
  final out = <String>{};

  void walk(Object? node, String field) {
    if (node is Map) {
      for (final entry in node.entries) {
        walk(entry.value, '${entry.key}');
      }
      return;
    }
    if (node is List) {
      for (final item in node) {
        walk(item, field);
      }
      return;
    }
    if (node is! String || node.isEmpty) return;

    if (field.endsWith('_key')) {
      final resolved = strings.t(node);
      // `t` hands back `[the.key]` when a pack is missing the entry. Putting
      // that in the wanted set would make this test pass on a screen drawing
      // the placeholder, which is the opposite of what it is for.
      if (resolved.isNotEmpty && !resolved.startsWith('[')) {
        out.add(resolved.trim());
      }
      return;
    }

    // Plain values. Paths, ids, timestamps, flags and booleans are not
    // readable text and would never appear on screen; a short human word
    // might, so the bar is deliberately low and the assertion is "any of".
    if (_isProse(field, node)) out.add(node.trim());
  }

  walk(data, '');
  out.removeWhere((s) => s.length < 3);
  return out;
}

/// Whether a raw value is something a person would read.
bool _isProse(String field, String value) {
  const skip = {
    'id',
    'person_id',
    'type',
    'kind',
    'status',
    'asset',
    'audio_asset',
    'thumbnail',
    'photo',
    'icon',
    'password',
    'master',
    'master_hint_key',
    'timestamp',
    'recorded_at',
    'started_at',
    'date',
    'sent_at',
    'lang',
    'langs',
    'audio_langs',
  };
  if (skip.contains(field) ||
      field.endsWith('_id') ||
      // Lists of them: `photo_ids`, `explore_post_ids`, `person_ids`.
      field.endsWith('_ids') ||
      field.endsWith('_at')) {
    return false;
  }
  if (value.startsWith('assets/') || value.contains('://')) return false;
  // ISO-ish stamps and bare numbers.
  if (RegExp(r'^\d{4}-\d{2}-\d{2}').hasMatch(value)) return false;
  if (RegExp(r'^[\d\s:.,+-]+$').hasMatch(value)) return false;
  // An id by shape rather than by field name — `ph_022`, `vm_001`, `p003`.
  // These are cross-references the schema uses to join records, and they are
  // never meant to be seen. Left in, they are what the test would demand the
  // screen display.
  if (RegExp(r'^[a-z]{1,5}_?\d{1,4}$').hasMatch(value)) return false;
  return true;
}

/// Everything one view shows, top to bottom.
///
/// A list only builds the children it can see, so what is below the fold is
/// never laid out and never readable. Stops early once something wanted has
/// turned up — there is no reason to drag a mail list to its end to prove the
/// first subject rendered.
Future<Set<String>> _sweep(WidgetTester tester, Set<String> wanted) async {
  var shown = _onScreen(tester);
  if (shown.intersection(wanted).isNotEmpty) return shown;

  // The *vertical* one, specifically.
  //
  // `Scrollable.first` on a tabbed app is the TabBarView, which scrolls
  // sideways. Dragging it downwards moves nothing — and ten of those drags
  // leave it in a state where tapping a tab no longer switches, so the sweep
  // silently blinded itself to every tab after the first.
  final list = find.byWidgetPredicate(
    (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
  );
  if (list.evaluate().isEmpty) return shown;

  for (var step = 0; step < 10; step++) {
    await tester.drag(list.first, const Offset(0, -400));
    await tester.pump(const Duration(milliseconds: 60));
    shown = shown.union(_onScreen(tester));
    if (shown.intersection(wanted).isNotEmpty) break;
  }
  return shown;
}

/// Every piece of text currently painted.
///
/// Read off the widget tree rather than asked for one string at a time:
/// `find.text` needs to know what it is looking for, and the useful question
/// here is the reverse — what is on screen, so a failure can say what the app
/// drew instead of what it should have.
Set<String> _onScreen(WidgetTester tester) {
  final out = <String>{};

  for (final element in find.byType(Text).evaluate()) {
    final text = (element.widget as Text).data;
    if (text != null && text.trim().isNotEmpty) out.add(text.trim());
  }
  for (final element in find.byType(RichText).evaluate()) {
    final span = (element.widget as RichText).text;
    final text = span.toPlainText(
      includeSemanticsLabels: false,
      includePlaceholders: false,
    );
    if (text.trim().isNotEmpty) out.add(text.trim());
  }

  return out;
}

String _short(String s) => s.length <= 40 ? s : '${s.substring(0, 40)}…';
