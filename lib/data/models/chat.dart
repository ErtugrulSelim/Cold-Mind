import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat.freezed.dart';
part 'chat.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum ChatSender { client, player }

@JsonEnum(fieldRename: FieldRename.snake)
enum ChatAction { acceptCase, declineCase, none }

/// One reply the player can pick.
///
/// [branch] is what makes a closing chat more than three ways to say goodbye:
/// picking a choice with a branch gates every later message to that branch, and
/// the pick is persisted so the epilogue can read it back.
@freezed
abstract class ChatChoice with _$ChatChoice {
  const factory ChatChoice({
    required String labelKey,
    @Default(ChatAction.none) ChatAction action,
    String? branch,
  }) = _ChatChoice;

  factory ChatChoice.fromJson(Map<String, dynamic> json) =>
      _$ChatChoiceFromJson(json);
}

@freezed
abstract class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required ChatSender sender,
    required DateTime timestamp,
    String? textKey,
    @Default(0) int delayMs,
    @Default(false) bool isChoice,
    @Default(<ChatChoice>[]) List<ChatChoice> choices,

    /// Only plays on this branch. Untagged messages always play.
    String? trigger,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}

@freezed
abstract class ClientChat with _$ClientChat {
  const factory ClientChat({
    required String clientPersonId,
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
  }) = _ClientChat;

  factory ClientChat.fromJson(Map<String, dynamic> json) =>
      _$ClientChatFromJson(json);
}

/// A short client conversation that fires mid-investigation, once the player
/// has solved [afterQuestion] questions.
@freezed
abstract class InterstitialChat with _$InterstitialChat {
  const factory InterstitialChat({
    required int afterQuestion,
    @Default('') String clientPersonId,
    @Default(<ChatMessage>[]) List<ChatMessage> messages,
  }) = _InterstitialChat;

  factory InterstitialChat.fromJson(Map<String, dynamic> json) =>
      _$InterstitialChatFromJson(json);
}

/// The three conversations that frame a case: the one that opens it, the ones
/// that interrupt it, and the one that closes it.
@freezed
abstract class CaseChats with _$CaseChats {
  const factory CaseChats({
    required ClientChat intro,
    @Default(<InterstitialChat>[]) List<InterstitialChat> interstitials,
    ClientChat? closing,
  }) = _CaseChats;

  const CaseChats._();

  factory CaseChats.fromJson(Map<String, dynamic> json) =>
      _$CaseChatsFromJson(json);

  /// The chat that should fire once [solvedCount] questions are solved, if any.
  InterstitialChat? interstitialAfter(int solvedCount) {
    for (final c in interstitials) {
      if (c.afterQuestion == solvedCount) return c;
    }
    return null;
  }
}
