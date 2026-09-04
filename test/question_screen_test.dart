import 'package:coldmind/core/theme/cold_theme.dart';
import 'package:coldmind/data/l10n/case_strings.dart';
import 'package:coldmind/data/models/case_file.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/data/providers/case_providers.dart';
import 'package:coldmind/data/providers/settings_providers.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/hints/hint_store.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:coldmind/features/quiz/question_screen.dart';
import 'package:coldmind/features/quiz/widgets/reveal_pair.dart';
import 'package:coldmind/features/case_flow/client_chat_screen.dart';
import 'package:coldmind/features/case_flow/client_portrait.dart';
import 'package:coldmind/features/phone/app_registry.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'phone_surface.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Whether the question screen draws every kind of question the game ships.
///
/// The five interactions are a union, so a kind with no renderer is a compile
/// error rather than a runtime one — but a renderer that overflows, or throws
/// on a payload only one case authors, is neither. Questions unlock in order,
/// so a single question that cannot be drawn ends the case at that point with
/// no way past it.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  const phone = phoneSize;

  /// Every case. It was s01 and s10 alone — one that reaches every question
  /// kind, and the two reveal shapes. That proved each *kind* draws, which is
  /// not the same as proving each *question* draws: the eight cases in between
  /// carry a hundred and twenty questions nothing had ever laid out.
  final caseIds = <String>[];

  final loaded =
      <String, ({CaseFile file, ContactBook contacts, CaseStrings strings})>{};
  late CaseStrings s01Strings;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Loaded here, never inside a testWidgets body: a bundle read never
    // completes inside the fake-async zone a widget test runs in.
    s01Strings = await repo.loadStrings('s01', 'en');
    caseIds.addAll([for (final s in await repo.loadIndex()) s.id]);
    for (final id in caseIds) {
      final file = await repo.loadCase(id);
      final strings = await repo.loadStrings(id, 'en');
      loaded[id] = (
        file: file,
        strings: strings,
        contacts: ContactBook(
          file: file,
          people: await repo.loadPeople(id),
          strings: strings,
        ),
      );
    }
  });

  /// Drives the screen to the question at [solved], which is the position the
  /// progress cursor puts it at.
  Future<void> pumpAt(WidgetTester tester, String caseId, int solved) async {
    final entry = loaded[caseId]!;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progress.solved.$caseId', solved);

    await tester.pumpWidget(
      ProviderScope(
        // A fresh container per pump. Without a distinguishing key Flutter
        // reuses the ProviderScope element, the container survives, and the
        // keepAlive progress provider keeps its first value — so a sweep meant
        // to draw every question silently redraws the first one fifteen times.
        key: ValueKey('$caseId-$solved'),
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          // The screen reads its strings from an async provider that loads
          // from the asset bundle, and a bundle read never resolves inside the
          // fake-async zone a widget test runs in — leaving the screen with no
          // accepted answers and grading every correct answer wrong.
          // Every case, not just the one being pumped: the sweep reuses one
          // scope across cases, and Riverpod refuses an override set that
          // changes shape between builds of the same scope.
          for (final id in caseIds)
            caseStringsProvider(
              id,
            ).overrideWith((ref) async => loaded[id]!.strings),
        ],
        child: MaterialApp(
          theme: buildColdTheme(),
          home: QuestionScreen(
            caseId: caseId,
            file: entry.file,
            contacts: entry.contacts,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
  }

  testWidgets('every question in every case draws without fault', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final caught = <FlutterErrorDetails>[];
    final previous = FlutterError.onError;
    FlutterError.onError = caught.add;

    final failures = <String>[];
    final kindsSeen = <String>{};

    for (final caseId in caseIds) {
      final questions = loaded[caseId]!.file.questions;
      for (var i = 0; i < questions.length; i++) {
        kindsSeen.add(questions[i].runtimeType.toString());
        caught.clear();
        try {
          await pumpAt(tester, caseId, i);
        } catch (error) {
          failures.add('$caseId q${i + 1} — $error');
          continue;
        }
        for (final details in caught) {
          failures.add('$caseId q${i + 1} — ${details.exception}');
        }

        // Every question names the app its answer is in, and every one of
        // those names has to reach the screen. A question pointing at a key
        // the registry does not know draws nothing, and the player is left
        // hunting a twenty-app phone for the surface it meant.
        final app = coldAppFor(questions[i].app);
        if (app == null) {
          failures.add(
            '$caseId q${i + 1} — points at "${questions[i].app}", '
            'which the registry cannot draw',
          );
        } else if (find
            .text(loaded[caseId]!.strings.c(app.nameKey))
            .evaluate()
            .isEmpty) {
          failures.add('$caseId q${i + 1} — never named its app on screen');
        }
      }
    }

    FlutterError.onError = previous;

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
    // Guards the guard: if these two cases stopped covering every interaction,
    // the sweep above would quietly stop proving what it claims to.
    expect(
      kindsSeen,
      containsAll(<String>[
        'FreeTextQuestion',
        'TimelineQuestion',
        'ContradictionQuestion',
        'SuspectQuestion',
        'MultiSelectQuestion',
      ]),
    );
  });

  testWidgets('a correct answer advances the case', (tester) async {
    usePhoneSurface(tester);

    // s01 q1 is free text; its first accepted group is a single stem.
    final strings = s01Strings;
    final first = loaded['s01']!.file.questions.first as FreeTextQuestion;
    final accepted = strings.answers(first.answersKey).first.join(' ');

    await pumpAt(tester, 's01', 0);

    await tester.enterText(find.byType(TextField), accepted);
    await tester.tap(find.text(strings.c('q.submit')));
    await tester.pump(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getInt('progress.solved.s01'),
      isNot(1),
      reason:
          'the answer is held on screen for a second before the case moves '
          'on — advancing inside that second is what made a right answer '
          'indistinguishable from a wrong one',
    );

    // Past the hold.
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    expect(
      prefs.getInt('progress.solved.s01'),
      1,
      reason: 'a correct answer must move the cursor to the next question',
    );
    expect(
      prefs.getStringList('progress.answers.s01'),
      contains(startsWith('1 ')),
      reason: 'what the player typed is kept, so it can be read back later',
    );
  });

  testWidgets('a wrong answer leaves the case where it was', (tester) async {
    usePhoneSurface(tester);

    final strings = s01Strings;
    await pumpAt(tester, 's01', 0);

    await tester.enterText(find.byType(TextField), 'definitely not the answer');
    await tester.tap(find.text(strings.c('q.submit')));
    await tester.pump(const Duration(milliseconds: 400));

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('progress.solved.s01'), 0);
    // s01 q1 is free text, whose wrong-answer copy is now kind-specific
    // rather than the one generic message every question kind used to share.
    expect(find.text(strings.c('eval.wrong')), findsOneWidget);
  });

  testWidgets('a hint can be used any time, no wrong tries required', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final strings = s01Strings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progress.solved.s01', 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          caseStringsProvider('s01').overrideWith((ref) async => strings),
          hintStoreProvider.overrideWithValue(const _AlwaysSpendableHintStore()),
        ],
        child: MaterialApp(
          theme: buildColdTheme(),
          home: QuestionScreen(
            caseId: 's01',
            file: loaded['s01']!.file,
            contacts: loaded['s01']!.contacts,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    // No wrong answer was ever submitted — the hint is there from the start.
    expect(find.byType(RevealPair), findsNothing);
    expect(find.text(strings.c('q.use_hint')), findsOneWidget);

    await tester.tap(find.text(strings.c('q.use_hint')));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(RevealPair), findsOneWidget);
    expect(
      find.text(strings.c('q.use_hint')),
      findsNothing,
      reason: 'the ask disappears once it has already been granted',
    );
  });

  testWidgets('an empty hint balance sends the player to the shop, not a free reveal', (
    tester,
  ) async {
    usePhoneSurface(tester);

    final strings = s01Strings;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progress.solved.s01', 0);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          caseStringsProvider('s01').overrideWith((ref) async => strings),
          // HintStoreScreen, the fallback this test tap lands on, reads its
          // own strings from this rather than the case-scoped provider above.
          commonStringsProvider.overrideWith((ref) async => strings),
          // Left at its default — UnconfiguredHintStore, whose spend()
          // reports "not enough" rather than granting a reveal for free.
        ],
        child: MaterialApp(
          theme: buildColdTheme(),
          home: QuestionScreen(
            caseId: 's01',
            file: loaded['s01']!.file,
            contacts: loaded['s01']!.contacts,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    await tester.tap(find.text(strings.c('q.use_hint')));
    // A route push, not just a setState — the transition needs settling,
    // not a fixed pump, before the shop's own content can be found.
    await tester.pumpAndSettle();

    expect(
      find.byType(RevealPair),
      findsNothing,
      reason: 'a player with no tokens must not get the reveal for free',
    );
    expect(
      find.text(strings.c('hints.title')),
      findsOneWidget,
      reason: 'an unaffordable hint should offer the shop, not silence',
    );
  });

  testWidgets('the client fills a quarter of both screens they are on', (
    tester,
  ) async {
    usePhoneSurface(tester);

    // On the client conversation and on the question card the portrait is the
    // same person making the same ask, so it is the same size on both. Seeing
    // them small in one place and large in the other reads as two characters.
    for (final screen in <Widget>[
      ClientChatScreen(
        caseId: 's01',
        chat: loaded['s01']!.file.chats.intro,
        clientName: loaded['s01']!.file.meta.client.name,
        clientPhoto: loaded['s01']!.file.meta.client.photo,
        onAccepted: () {},
      ),
      QuestionScreen(
        caseId: 's01',
        file: loaded['s01']!.file,
        contacts: loaded['s01']!.contacts,
      ),
    ]) {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(
              await SharedPreferences.getInstance(),
            ),
            caseStringsProvider(
              's01',
            ).overrideWith((ref) async => loaded['s01']!.strings),
          ],
          child: MaterialApp(theme: buildColdTheme(), home: screen),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));

      final portrait = find.byType(ClientPortrait);
      expect(
        portrait,
        findsOneWidget,
        reason: '${screen.runtimeType} drew no client',
      );
      expect(
        tester.getSize(portrait).height,
        closeTo(phone.height * 0.25, 1),
        reason: '${screen.runtimeType} sized the client differently',
      );
    }

    // Leaves nothing ticking behind.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

/// A [HintStore] that always has a token to spend — the fake behind the
/// "hint granted" branch of `_useHint`, the same way `UnconfiguredHintStore`
/// (spend() always false) is the fake behind the "no tokens" branch.
class _AlwaysSpendableHintStore implements HintStore {
  const _AlwaysSpendableHintStore();

  @override
  Future<int> balance() async => 1;

  @override
  Future<List<HintPackage>> packages() async => const [];

  @override
  Future<bool> purchase(String packageId) async => false;

  @override
  Future<bool> spend() async => true;
}
