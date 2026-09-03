import 'package:freezed_annotation/freezed_annotation.dart';

part 'person.freezed.dart';
part 'person.g.dart';

@freezed
abstract class ContactInfo with _$ContactInfo {
  const factory ContactInfo({
    required String firstName,

    /// Null for someone saved under a first name alone — "Mamá", "Cypher".
    String? lastName,
    @Default('') String phoneNumber,
    @Default('#94A3B8') String avatarColor,
  }) = _ContactInfo;

  const ContactInfo._();

  factory ContactInfo.fromJson(Map<String, dynamic> json) =>
      _$ContactInfoFromJson(json);

  String get fullName => lastName == null ? firstName : '$firstName $lastName';
}

@freezed
abstract class InstagramProfile with _$InstagramProfile {
  const factory InstagramProfile({
    required String username,
    @Default('') String bio,
    @Default(0) int followerCount,
    @Default(0) int followingCount,
    @Default(false) bool isPrivate,
    @Default(<String>[]) List<String> postIds,
  }) = _InstagramProfile;

  factory InstagramProfile.fromJson(Map<String, dynamic> json) =>
      _$InstagramProfileFromJson(json);
}

@freezed
abstract class InstagramComment with _$InstagramComment {
  const factory InstagramComment({
    required String personId,
    required String text,
    DateTime? timestamp,
  }) = _InstagramComment;

  factory InstagramComment.fromJson(Map<String, dynamic> json) =>
      _$InstagramCommentFromJson(json);
}

/// A post by someone in the cast.
///
/// [caption] is a literal string rather than a key, so it always renders in
/// English. Nothing a player must *read to solve a case* should live here until
/// it is keyed.
///
/// [comments] is modelled and, across all ten seasons, never authored — every
/// array is empty. Kept because a comment thread is a real surface for a case
/// to use, not because anything reads it today.
@freezed
abstract class InstagramPost with _$InstagramPost {
  const factory InstagramPost({
    required String id,
    required String personId,
    @Default('') String caption,
    String? imageAsset,

    /// A clip instead of a still. Only the Reels tab plays it — everywhere
    /// else the post keeps drawing `imageAsset`, which is the frame the clip
    /// grew out of, so a grid tile never has to decode video to show a
    /// thumbnail and a post without a clip loses nothing.
    String? videoAsset,
    String? location,
    @Default(0) int likeCount,
    DateTime? timestamp,
    @Default(<String>[]) List<String> tags,

    /// Whether the phone's owner liked this post — a small, readable trace of
    /// who they were paying attention to.
    @Default(false) bool likedByOwner,
    @Default(<InstagramComment>[]) List<InstagramComment> comments,
  }) = _InstagramPost;

  factory InstagramPost.fromJson(Map<String, dynamic> json) =>
      _$InstagramPostFromJson(json);
}

/// Someone in a case's cast. Shared across every app surface that renders a
/// name, a face or a number.
@freezed
abstract class Person with _$Person {
  const factory Person({
    required String id,
    required ContactInfo contact,
    @Default(3) int tier,
    InstagramProfile? instagram,
    String? photoAsset,
    @Default(<String>[]) List<String> personalAssets,
    int? age,
    String? homeCity,
    String? occupation,
    @Default(<String>[]) List<String> personalityTags,
  }) = _Person;

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);
}

/// A case's cast file, indexed for lookup by id.
@freezed
abstract class PeoplePool with _$PeoplePool {
  const factory PeoplePool({
    @Default(<Person>[]) List<Person> people,
    @Default(<InstagramPost>[]) List<InstagramPost> instagramPosts,
  }) = _PeoplePool;

  const PeoplePool._();

  factory PeoplePool.fromJson(Map<String, dynamic> json) =>
      _$PeoplePoolFromJson(json);

  Person? byId(String personId) {
    for (final p in people) {
      if (p.id == personId) return p;
    }
    return null;
  }

  InstagramPost? postById(String postId) {
    for (final p in instagramPosts) {
      if (p.id == postId) return p;
    }
    return null;
  }
}
