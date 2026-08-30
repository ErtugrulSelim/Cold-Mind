import 'package:coldmind/data/models/person.dart';
import 'package:coldmind/data/models/question.dart';
import 'package:coldmind/data/repository/case_repository.dart';
import 'package:coldmind/features/phone/app_registry.dart';
import 'package:coldmind/features/phone/app_router.dart';
import 'package:coldmind/features/phone/contact_book.dart';
import 'package:flutter_test/flutter_test.dart';

/// Which apps actually open.
///
/// `case_integrity_test` already proves every question points at an *installed*
/// app. This proves the installed app has a **screen** — the other half of the
/// same promise. A question that sends the player to an app with no surface
/// strands them exactly as badly as one that names an app the phone does not
/// have, and neither failure is visible until somebody plays that far.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final repo = CaseRepository();

  test('every app in the registry has a unique key', () {
    final keys = coldApps.map((a) => a.key).toList();
    expect(keys.toSet().length, keys.length);
  });

  test('every app every case installs can be opened', () async {
    final missing = <String>{};

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final contacts = ContactBook(
        file: file,
        people: await repo.loadPeople(summary.id),
        strings: await repo.loadStrings(summary.id, 'en'),
      );

      for (final key in file.apps.keys) {
        final screen = buildAppScreen(
          appKey: key,
          file: file,
          contacts: contacts,
          strings: contacts.strings,
        );
        if (screen == null) missing.add('${summary.id}:$key');
      }
    }

    expect(
      missing,
      isEmpty,
      reason: 'installed but with nowhere to go: ${missing.join(', ')}',
    );
  });

  test('every question in every case points at an app that opens', () async {
    // The other half of the integrity test's promise. That one proves the app
    // is installed; this proves it has a screen. A question sending the player
    // to a surface that does not exist strands them just as completely.
    final broken = <String>{};

    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      final contacts = ContactBook(
        file: file,
        people: await repo.loadPeople(summary.id),
        strings: await repo.loadStrings(summary.id, 'en'),
      );

      for (final question in file.questions) {
        final app = switch (question) {
          FreeTextQuestion(:final app) => app,
          TimelineQuestion(:final app) => app,
          ContradictionQuestion(:final app) => app,
          SuspectQuestion(:final app) => app,
          MultiSelectQuestion(:final app) => app,
        };
        final screen = buildAppScreen(
          appKey: app,
          file: file,
          contacts: contacts,
          strings: contacts.strings,
        );
        if (screen == null) broken.add('${summary.id}:$app');
      }
    }

    expect(broken, isEmpty);
  });

  test('an app the phone does not have never opens', () async {
    final file = await repo.loadCase('s01');
    final contacts = ContactBook(
      file: file,
      people: const PeoplePool(),
      strings: null,
    );

    expect(file.hasApp('dating'), isFalse);
    expect(
      buildAppScreen(
        appKey: 'dating',
        file: file,
        contacts: contacts,
        strings: null,
      ),
      isNull,
      reason: 'a phone without an app must not be able to open it',
    );
  });

  test('the registry can draw every app any case installs', () async {
    final unknown = <String>{};
    for (final summary in await repo.loadIndex()) {
      final file = await repo.loadCase(summary.id);
      for (final key in file.apps.keys) {
        if (coldAppFor(key) == null) unknown.add('${summary.id}:$key');
      }
    }
    expect(
      unknown,
      isEmpty,
      reason:
          'installed but absent from the app registry, so the home screen '
          'would silently skip them',
    );
  });
}
