import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/answers/answer_evaluator.dart';
import '../l10n/case_strings.dart';
import '../models/case_file.dart';
import '../models/case_summary.dart';
import '../models/person.dart';
import '../repository/case_repository.dart';
import 'settings_providers.dart';

part 'case_providers.g.dart';

/// The one case a player can open without a subscription, and the one every
/// onboarding prompt (the hint offer, the rating popup) is scoped to as "the
/// first case" — see `case_list_screen.dart`'s lock and `question_screen.dart`'s
/// triggers, which both read this rather than each hard-coding their own copy
/// of the id.
const String freeCaseId = 's01';

/// Asset access. Overridden in tests with a repository over a fake bundle.
@Riverpod(keepAlive: true)
CaseRepository caseRepository(Ref ref) => CaseRepository();

/// The case list, read from the generated index rather than from ten 200 KB
/// case files.
@Riverpod(keepAlive: true)
Future<List<CaseSummary>> caseIndex(Ref ref) =>
    ref.watch(caseRepositoryProvider).loadIndex();

/// The case the player currently has open, remembered across launches so the
/// game reopens where they left off.
///
/// Everything below is keyed by case id rather than reading a global "current
/// scenario" singleton, so opening a different case builds fresh data instead
/// of mutating shared state underneath whatever is already on screen.
@Riverpod(keepAlive: true)
class OpenCase extends _$OpenCase {
  static const String _key = 'open_case_id';

  @override
  String? build() => ref.watch(sharedPreferencesProvider).getString(_key);

  Future<void> open(String caseId) async {
    await ref.read(sharedPreferencesProvider).setString(_key, caseId);
    state = caseId;
  }

  Future<void> close() async {
    await ref.read(sharedPreferencesProvider).remove(_key);
    state = null;
  }
}

@Riverpod(keepAlive: true)
Future<CaseFile> caseFile(Ref ref, String caseId) =>
    ref.watch(caseRepositoryProvider).loadCase(caseId);

@Riverpod(keepAlive: true)
Future<PeoplePool> people(Ref ref, String caseId) =>
    ref.watch(caseRepositoryProvider).loadPeople(caseId);

/// Strings for a case in the selected language. Watching the language means a
/// switch in Settings re-resolves every string in place, with no reload.
@Riverpod(keepAlive: true)
Future<CaseStrings> caseStrings(Ref ref, String caseId) => ref
    .watch(caseRepositoryProvider)
    .loadStrings(caseId, ref.watch(languageProvider));

/// Shared strings alone — enough for the case list and settings, before any
/// case is open.
@Riverpod(keepAlive: true)
Future<CaseStrings> commonStrings(Ref ref) => ref
    .watch(caseRepositoryProvider)
    .loadCommonStrings(ref.watch(languageProvider));

/// The grader for one case, bound to that case's strings because the accepted
/// answers are localized alongside everything else.
@Riverpod(keepAlive: true)
AnswerEvaluator answerEvaluator(Ref ref, String caseId) {
  final strings = ref.watch(caseStringsProvider(caseId)).value;
  return AnswerEvaluator(
    acceptedAnswers: (strings ?? CaseStrings.empty).answers,
  );
}
