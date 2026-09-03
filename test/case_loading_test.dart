import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:flutter_test/flutter_test.dart';

/// Loads case data the way the running game does — through the asset bundle,
/// not off disk.
///
/// This is what catches a file that exists but was never declared in
/// pubspec.yaml: the integrity test reads the filesystem and would pass, while
/// the app would throw on launch.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  test('the case index loads and lists every case', () async {
    final index = await repo.loadIndex();
    expect(index, hasLength(10));
    expect(index.first.id, 's01');
    expect(index.map((c) => c.questionCount), everyElement(greaterThan(0)));
  });

  test('every case in the index can actually be opened', () async {
    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      expect(file.id, summary.id);
      expect(
        file.questions,
        hasLength(summary.questionCount),
        reason:
            'the index disagrees with ${summary.id}/case.json about how '
            'many questions the case has',
      );
      final people = await repo.loadPeople(summary.id);
      expect(people.people, isNotEmpty);
    }
  });

  test('s01 reads as the case it is', () async {
    final file = await repo.loadCase('s01');
    final strings = await repo.loadStrings('s01', 'en');

    expect(file.device.ownerName, 'Elias Rand');
    expect(file.meta.city.name, 'Tallinn');
    expect(strings.t(file.meta.titleKey), 'The Perfect Crime');
    expect(file.hasApp('whatsapp'), isTrue);
    expect(file.hasApp('dating'), isFalse);
  });

  test('accepted answers resolve as answer groups, not as raw text', () async {
    // The six seasons that shipped these as JSON strings graded nothing at all:
    // every free-text answer threw before it could be compared.
    for (final id in ['s01', 's05', 's10']) {
      final file = await repo.loadCase(id);
      final strings = await repo.loadStrings(id, 'en');
      final freeText = file.questions.whereType<FreeTextQuestion>();
      expect(freeText, isNotEmpty);
      for (final q in freeText) {
        final groups = strings.answers(q.answersKey);
        expect(
          groups,
          isNotEmpty,
          reason: '$id Q${q.index} has no gradable answers',
        );
        expect(groups.every((g) => g.isNotEmpty), isTrue);
      }
    }
  });

  test('an untranslated pack falls back to English key by key', () async {
    // German ships common.json only, so the case strings come back in English
    // while the shared UI strings come back translated. This used to be
    // Turkish, which was true of every language and is now true of most: tr
    // ships a case pack, and the merge is the mechanism that lets a language
    // land one at a time rather than all ten at once.
    final de = await repo.loadStrings('s01', 'de');
    final en = await repo.loadStrings('s01', 'en');
    expect(de.t('s01.meta.title'), en.t('s01.meta.title'));
    expect(de.c('ui.months_short'), isNot(en.c('ui.months_short')));
  });

  test('a translated pack overrides English key by key', () async {
    // The other half, and the half that matters once a language ships a case:
    // the overlay wins where it has a key and falls through where it does not.
    // s01's Turkish pack translates the title and deliberately leaves the
    // street addresses alone.
    final tr = await repo.loadStrings('s01', 'tr');
    final en = await repo.loadStrings('s01', 'en');
    expect(tr.t('s01.meta.title'), isNot(en.t('s01.meta.title')));
    expect(
      tr.t('s01.maps.loc_001.address'),
      en.t('s01.maps.loc_001.address'),
      reason: 'an address is not a thing to translate',
    );
  });

  test('a missing key is visible rather than silently empty', () async {
    final strings = await repo.loadStrings('s01', 'en');
    expect(strings.t('s01.nothing.here'), '[s01.nothing.here]');
  });
}
