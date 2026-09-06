// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ContactInfo _$ContactInfoFromJson(Map<String, dynamic> json) => _ContactInfo(
  firstName: json['first_name'] as String,
  lastName: json['last_name'] as String?,
  phoneNumber: json['phone_number'] as String? ?? '',
  avatarColor: json['avatar_color'] as String? ?? '#94A3B8',
);

Map<String, dynamic> _$ContactInfoToJson(_ContactInfo instance) =>
    <String, dynamic>{
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'phone_number': instance.phoneNumber,
      'avatar_color': instance.avatarColor,
    };

_InstagramProfile _$InstagramProfileFromJson(Map<String, dynamic> json) =>
    _InstagramProfile(
      username: json['username'] as String,
      bio: json['bio'] as String? ?? '',
      followerCount: (json['follower_count'] as num?)?.toInt() ?? 0,
      followingCount: (json['following_count'] as num?)?.toInt() ?? 0,
      isPrivate: json['is_private'] as bool? ?? false,
      postIds:
          (json['post_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const <String>[],
    );

Map<String, dynamic> _$InstagramProfileToJson(_InstagramProfile instance) =>
    <String, dynamic>{
      'username': instance.username,
      'bio': instance.bio,
      'follower_count': instance.followerCount,
      'following_count': instance.followingCount,
      'is_private': instance.isPrivate,
      'post_ids': instance.postIds,
    };

_InstagramComment _$InstagramCommentFromJson(Map<String, dynamic> json) =>
    _InstagramComment(
      personId: json['person_id'] as String,
      text: json['text'] as String,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$InstagramCommentToJson(_InstagramComment instance) =>
    <String, dynamic>{
      'person_id': instance.personId,
      'text': instance.text,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

_InstagramPost _$InstagramPostFromJson(Map<String, dynamic> json) =>
    _InstagramPost(
      id: json['id'] as String,
      personId: json['person_id'] as String,
      caption: json['caption'] as String? ?? '',
      imageAsset: json['image_asset'] as String?,
      videoAsset: json['video_asset'] as String?,
      location: json['location'] as String?,
      likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          const <String>[],
      likedByOwner: json['liked_by_owner'] as bool? ?? false,
      comments:
          (json['comments'] as List<dynamic>?)
              ?.map((e) => InstagramComment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <InstagramComment>[],
    );

Map<String, dynamic> _$InstagramPostToJson(_InstagramPost instance) =>
    <String, dynamic>{
      'id': instance.id,
      'person_id': instance.personId,
      'caption': instance.caption,
      'image_asset': instance.imageAsset,
      'video_asset': instance.videoAsset,
      'location': instance.location,
      'like_count': instance.likeCount,
      'timestamp': instance.timestamp?.toIso8601String(),
      'tags': instance.tags,
      'liked_by_owner': instance.likedByOwner,
      'comments': instance.comments.map((e) => e.toJson()).toList(),
    };

_Person _$PersonFromJson(Map<String, dynamic> json) => _Person(
  id: json['id'] as String,
  contact: ContactInfo.fromJson(json['contact'] as Map<String, dynamic>),
  tier: (json['tier'] as num?)?.toInt() ?? 3,
  instagram: json['instagram'] == null
      ? null
      : InstagramProfile.fromJson(json['instagram'] as Map<String, dynamic>),
  photoAsset: json['photo_asset'] as String?,
  personalAssets:
      (json['personal_assets'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
  age: (json['age'] as num?)?.toInt(),
  homeCity: json['home_city'] as String?,
  occupation: json['occupation'] as String?,
  personalityTags:
      (json['personality_tags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const <String>[],
);

Map<String, dynamic> _$PersonToJson(_Person instance) => <String, dynamic>{
  'id': instance.id,
  'contact': instance.contact.toJson(),
  'tier': instance.tier,
  'instagram': instance.instagram?.toJson(),
  'photo_asset': instance.photoAsset,
  'personal_assets': instance.personalAssets,
  'age': instance.age,
  'home_city': instance.homeCity,
  'occupation': instance.occupation,
  'personality_tags': instance.personalityTags,
};

_PeoplePool _$PeoplePoolFromJson(Map<String, dynamic> json) => _PeoplePool(
  people:
      (json['people'] as List<dynamic>?)
          ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Person>[],
  instagramPosts:
      (json['instagram_posts'] as List<dynamic>?)
          ?.map((e) => InstagramPost.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <InstagramPost>[],
);

Map<String, dynamic> _$PeoplePoolToJson(
  _PeoplePool instance,
) => <String, dynamic>{
  'people': instance.people.map((e) => e.toJson()).toList(),
  'instagram_posts': instance.instagramPosts.map((e) => e.toJson()).toList(),
};
