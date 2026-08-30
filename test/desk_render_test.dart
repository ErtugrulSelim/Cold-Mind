import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/models/case_summary.dart';
import 'package:coldmind/data/providers/case_providers.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/case_flow/client_chat_screen.dart';
import 'package:coldmind/features/case_flow/connecting_screen.dart';
import 'package:coldmind/features/cases/case_list_screen.dart';
import 'package:coldmind/features/paywall/paywall_screen.dart';
import 'package:coldmind/features/paywall/store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every screen that is not on the phone: the case index, the paywall, and the
/// handover between the two registers.
///
/// `app_render_test` sweeps the phone. None of these is on it, so until now
/// the surfaces the player meets before any case — and the one that takes
/// money — had nothing checking they draw at all.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  late List<CaseSummary> index;
  late CaseStrings common;
  late CaseFile sample;
  late CaseStrings sampleStrings;
  late SharedPreferences prefs;

  setUpAll(() async {
    // Loaded here, not in the test body: a bundle read inside a widget test
    // runs in a fake-async zone where it never completes.
    index = await repo.loadIndex();
    common = await repo.loadCommonStrings('en');
    sample = await repo.loadCase(index.first.id);
    sampleStrings = await repo.loadStrings(index.first.id, 'en');

    SharedPreferences.setMockInitialValues({
      // One case part way through and one finished, so the index has to draw
      // all three of its states rather than ten identical rows.
      'progress.solved.${index.first.id}': 4,
      if (index.length > 1)
        'progress.solved.${index[1].id}': index[1].questionCount,
    });
    prefs = await SharedPreferences.getInstance();
  });

  Widget host(Widget child) => ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      caseIndexProvider.overrideWith((ref) async => index),
      commonStringsProvider.overrideWith((ref) async => common),
      caseStringsProvider(sample.id).overrideWith((ref) async => sampleStrings),
    ],
    child: MaterialApp(theme: buildColdTheme(), home: child),
  );

  testWidgets('the case index draws every state it has', (tester) async {
    usePhoneSurface(tester);

    final caught = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = caught.add;

    await tester.pumpWidget(host(const CaseListScreen()));
    await tester.pump(const Duration(milliseconds: 400));

    // Through the whole deck. A page view builds one card at a time, so the
    // cases behind the first are never laid out until they are paged to — and
    // an overflow on case seven would otherwise sit there unseen.
    final seen = <String>{};
    for (var page = 0; page < index.length; page++) {
      for (final summary in index) {
        if (find.text(common.t(summary.titleKey)).evaluate().isNotEmpty) {
          seen.add(summary.id);
        }
      }
      await tester.fling(find.byType(PageView), const Offset(0, -400), 1200);
      await tester.pumpAndSettle();
    }

    FlutterError.onError = previous;

    expect(
      find.text(common.c('ui.cases.connect')),
      findsOneWidget,
      reason: 'the deck never got past its loading state',
    );
    expect(
      seen,
      hasLength(index.length),
      reason: 'not every case could be reached by scrolling the deck',
    );
    // All three states, because a deck where every card says NEW would pass a
    // sweep that only checked the cards drew.
    expect(find.text(common.c('ui.cases.new')), findsOneWidget);

    // The player's own controls. The deck is the first screen of the game, and
    // for a while these lived only on the phone — so a player who had not
    // opened a case yet could reach neither their settings nor the
    // subscription, and nothing in the suite noticed.
    expect(
      find.byIcon(Icons.settings_outlined),
      findsOneWidget,
      reason: 'no way into settings from the deck',
    );
    expect(
      find.text(common.c('ui.cases.pro')),
      findsOneWidget,
      reason: 'no way into the subscription from the deck',
    );

    expect([for (final d in caught) '${d.exception}'].where(_isReal), isEmpty);
  });

  testWidgets('the paywall draws its plans and the price of each', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final caught = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = caught.add;

    await tester.pumpWidget(host(const PaywallScreen()));
    await tester.pump(const Duration(milliseconds: 400));

    FlutterError.onError = previous;

    for (final plan in await const UnconfiguredStore().plans()) {
      expect(
        find.text(common.c(plan.titleKey)),
        findsOneWidget,
        reason: '${plan.id} is on offer but never drawn',
      );
    }
    expect(find.text(common.c('paywall.continue')), findsOneWidget);
    expect([for (final d in caught) '${d.exception}'].where(_isReal), isEmpty);
  });

  testWidgets('the connecting screen runs its log and hands over', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final file = sample;
    var handedOver = false;

    final caught = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = caught.add;

    await tester.pumpWidget(
      host(
        ConnectingScreen(
          caseId: file.id,
          file: file,
          onConnected: () => handedOver = true,
        ),
      ),
    );

    // Through the whole handshake a frame at a time. The screen animates
    // continuously, so it can never be settled — it has to be driven.
    for (var step = 0; step < 60; step++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    FlutterError.onError = previous;

    expect(
      handedOver,
      isTrue,
      reason: 'the connection never completed, so the case can never open',
    );
    expect(
      find.text(common.c('ui.connecting.step4')),
      findsOneWidget,
      reason: 'the last log line was dropped',
    );
    expect(find.text(file.device.ownerName), findsOneWidget);
    expect([for (final d in caught) '${d.exception}'].where(_isReal), isEmpty);

    // Tears the ticker down, so the binding does not report it as leaked.
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets("the connecting screen bypasses the phone's own lock PIN", (
    tester,
  ) async {
    // `device.lock_pin` is authored on every case; this is the one place it
    // is read at all, and it used to be nowhere — the field sat in every
    // case.json with nothing on the other end.
    usePhoneSurface(tester);

    final file = sample;
    final pin = file.device.lockPin;
    expect(
      pin,
      isNotNull,
      reason:
          'the sample case has to author a PIN for this test to prove '
          'anything',
    );

    await tester.pumpWidget(
      host(ConnectingScreen(caseId: file.id, file: file, onConnected: () {})),
    );

    // Watched frame by frame rather than sampled at one moment. The bypass
    // line only holds for a few hundred milliseconds, so a test that pumped
    // straight to a fixed offset was really asserting the step timings — it
    // broke the first time they were retuned, while the behaviour it exists
    // to protect was still fine.
    var seen = false;
    for (var step = 0; step < 30 && !seen; step++) {
      await tester.pump(const Duration(milliseconds: 100));
      seen = find.textContaining(pin!).evaluate().isNotEmpty;
    }

    expect(
      seen,
      isTrue,
      reason:
          "the phone's own lock PIN never appears on screen — the "
          'bypass beat this connection is supposed to show is missing',
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('the client conversation runs oldest at the top, newest at the '
      'bottom', (tester) async {
    // The thread is drawn reversed so it sits on the bottom edge and grows
    // upward the way a real conversation does. Reversing a list means the
    // builder has to count backwards too, and getting that wrong silently
    // plays the conversation in the wrong order — which reads as sensible
    // dialogue right up until the client answers a question they have not
    // been asked yet. Nothing about the layout looks wrong when it happens.
    usePhoneSurface(tester);

    await tester.pumpWidget(
      host(
        ClientChatScreen(
          caseId: sample.id,
          chat: sample.chats.intro,
          clientName: sample.meta.client.name,
          clientPhoto: sample.meta.client.photo,
          onFinished: (_) {},
        ),
      ),
    );

    // The thread reveals itself on a timer, so it has to be played out.
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }

    // The first two authored messages that actually reached the screen.
    final onScreen = <String>[];
    for (final message in sample.chats.intro.messages) {
      final text = sampleStrings.t(message.textKey ?? '');
      if (text.isEmpty || find.text(text).evaluate().isEmpty) continue;
      onScreen.add(text);
      if (onScreen.length == 2) break;
    }

    expect(
      onScreen.length,
      2,
      reason: 'the intro never played far enough to compare two lines',
    );
    expect(
      tester.getTopLeft(find.text(onScreen[0])).dy,
      lessThan(tester.getTopLeft(find.text(onScreen[1])).dy),
      reason: 'the earlier line must sit above the later one',
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('a store with no billing wired in never grants access', () async {
    // The failure that would ship silently: a paywall that returns true when
    // nothing is connected hands every case away for free, and looks correct
    // in every screenshot.
    const store = UnconfiguredStore();

    await expectLater(
      store.purchase('coldmind_yearly'),
      throwsA(isA<StoreException>()),
    );
    await expectLater(store.restore(), throwsA(isA<StoreException>()));
  });
}

/// Assets never resolve under `flutter_test`; every call site here carries its
/// own `errorBuilder`, which is the behaviour that matters on a device.
bool _isReal(String error) =>
    !error.contains('Unable to load asset') &&
    !error.contains('Invalid image data') &&
    !error.contains('Unable to read Codec');
