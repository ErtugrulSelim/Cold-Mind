import 'package:freezed_annotation/freezed_annotation.dart';

part 'question.freezed.dart';
part 'question.g.dart';

/// An optional recording attached to a question — a call, a voice note, a memo
/// the player is asked to listen to rather than read.
///
/// [asset] may carry a `{lang}` placeholder; [langs] lists the languages that
/// actually ship a file. English must always be one of them: it is what every
/// other locale falls back to.
@freezed
abstract class QuestionAudio with _$QuestionAudio {
  const factory QuestionAudio({
    required String asset,
    @Default(<String>[]) List<String> langs,
    String? transcriptKey,
  }) = _QuestionAudio;

  const QuestionAudio._();

  factory QuestionAudio.fromJson(Map<String, dynamic> json) =>
      _$QuestionAudioFromJson(json);

  /// The concrete path for [lang], falling back to English when this language
  /// has no dedicated recording.
  String resolve(String lang) => asset.contains('{lang}')
      ? asset.replaceAll('{lang}', langs.contains(lang) ? lang : 'en')
      : asset;
}

/// The pool a free-text question's 50/50 hint draws from: the answer as a
/// readable line, plus the wrong lines it can be shown against.
///
/// This is not how the answer is *graded* — grading runs on [Question.freeText]'s
/// `answersKey` groups. It only exists so a stuck player can be offered a choice
/// instead of a blank field.
@freezed
abstract class QuestionReveal with _$QuestionReveal {
  const factory QuestionReveal({
    required String answerKey,
    @Default(<String>[]) List<String> decoyKeys,
  }) = _QuestionReveal;

  factory QuestionReveal.fromJson(Map<String, dynamic> json) =>
      _$QuestionRevealFromJson(json);
}

/// One step of an investigation.
///
/// The variants are the interaction: a free-text answer typed into a field, a
/// set of events dragged into order, a line-up, and so on. Making them a union
/// rather than one class with a pile of nullable payloads means adding a kind
/// is a compile error everywhere it has to be handled, instead of a null that
/// only shows up when a player reaches that question.
///
/// [app] is the app key this question points the player at, and it must name an
/// app that is actually installed on the case's phone — otherwise the question
/// is unanswerable and the player is stranded. `case_integrity_test.dart`
/// enforces that.
@Freezed(unionKey: 'kind', unionValueCase: FreezedUnionCase.snake)
sealed class Question with _$Question {
  /// Type an answer. Graded against the accepted-answer groups at [answersKey]:
  /// the outer list is OR, each inner list is an AND of substrings.
  const factory Question.freeText({
    required int index,
    required String app,
    required String titleKey,
    required String promptKey,
    required String answersKey,
    QuestionReveal? reveal,
    QuestionAudio? audio,
    String? hintKey,
  }) = FreeTextQuestion;

  /// Drag dated events into chronological order. [order] holds indices into the
  /// authored (scrambled) [events] list, in true order.
  const factory Question.timeline({
    required int index,
    required String app,
    required String titleKey,
    required String promptKey,
    required List<String> events,
    required List<int> order,
    QuestionAudio? audio,
    String? hintKey,
  }) = TimelineQuestion;

  /// Tap the statement that doesn't hold up. Either one line is the lie
  /// ([lieIndex]) or two lines conflict with each other ([pair]).
  const factory Question.contradiction({
    required int index,
    required String app,
    required String titleKey,
    required String promptKey,
    required List<String> snippets,
    int? lieIndex,
    @Default(<int>[]) List<int> pair,
    QuestionAudio? audio,
    String? hintKey,
  }) = ContradictionQuestion;

  /// Accuse someone from a photo line-up of the cast.
  const factory Question.suspect({
    required int index,
    required String app,
    required String titleKey,
    required String promptKey,
    required List<String> personIds,
    required String correctPersonId,
    QuestionAudio? audio,
    String? hintKey,
  }) = SuspectQuestion;

  /// Toggle the exact set of evidence that proves one fact — no extras, no
  /// omissions.
  const factory Question.multiSelect({
    required int index,
    required String app,
    required String titleKey,
    required String promptKey,
    required List<String> options,
    required List<int> correctIndices,
    QuestionAudio? audio,
    String? hintKey,
  }) = MultiSelectQuestion;

  factory Question.fromJson(Map<String, dynamic> json) =>
      _$QuestionFromJson(json);
}
