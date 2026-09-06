// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_file.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseCity _$CaseCityFromJson(Map<String, dynamic> json) => _CaseCity(
  name: json['name'] as String,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
);

Map<String, dynamic> _$CaseCityToJson(_CaseCity instance) => <String, dynamic>{
  'name': instance.name,
  'lat': instance.lat,
  'lng': instance.lng,
};

_CaseClient _$CaseClientFromJson(Map<String, dynamic> json) => _CaseClient(
  personId: json['person_id'] as String,
  name: json['name'] as String,
  photo: json['photo'] as String?,
);

Map<String, dynamic> _$CaseClientToJson(_CaseClient instance) =>
    <String, dynamic>{
      'person_id': instance.personId,
      'name': instance.name,
      'photo': instance.photo,
    };

_CaseMeta _$CaseMetaFromJson(Map<String, dynamic> json) => _CaseMeta(
  titleKey: json['title_key'] as String,
  difficulty: json['difficulty'] as String,
  city: CaseCity.fromJson(json['city'] as Map<String, dynamic>),
  client: CaseClient.fromJson(json['client'] as Map<String, dynamic>),
  thumbnail: json['thumbnail'] as String?,
  revealTotal: json['reveal_total'] as bool? ?? true,
);

Map<String, dynamic> _$CaseMetaToJson(_CaseMeta instance) => <String, dynamic>{
  'title_key': instance.titleKey,
  'difficulty': instance.difficulty,
  'city': instance.city.toJson(),
  'client': instance.client.toJson(),
  'thumbnail': instance.thumbnail,
  'reveal_total': instance.revealTotal,
};

_DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) => _DeviceInfo(
  ownerName: json['owner_name'] as String,
  model: json['model'] as String,
  iosVersion: json['ios_version'] as String?,
  storageTotalGb: (json['storage_total_gb'] as num?)?.toInt() ?? 0,
  storageUsedGb: (json['storage_used_gb'] as num?)?.toInt() ?? 0,
  lastBackup: json['last_backup'] == null
      ? null
      : DateTime.parse(json['last_backup'] as String),
  lockPin: json['lock_pin'] as String?,
  wallpaperAsset: json['wallpaper_asset'] as String?,
);

Map<String, dynamic> _$DeviceInfoToJson(_DeviceInfo instance) =>
    <String, dynamic>{
      'owner_name': instance.ownerName,
      'model': instance.model,
      'ios_version': instance.iosVersion,
      'storage_total_gb': instance.storageTotalGb,
      'storage_used_gb': instance.storageUsedGb,
      'last_backup': instance.lastBackup?.toIso8601String(),
      'lock_pin': instance.lockPin,
      'wallpaper_asset': instance.wallpaperAsset,
    };

_CastMember _$CastMemberFromJson(Map<String, dynamic> json) => _CastMember(
  personId: json['person_id'] as String,
  role: json['role'] as String,
  nickname: json['nickname'] as String?,
  contactSaved: json['contact_saved'] as bool? ?? true,
  relationshipNoteKey: json['relationship_note_key'] as String?,
  phoneNumberOverride: json['phone_number_override'] as String?,
);

Map<String, dynamic> _$CastMemberToJson(_CastMember instance) =>
    <String, dynamic>{
      'person_id': instance.personId,
      'role': instance.role,
      'nickname': instance.nickname,
      'contact_saved': instance.contactSaved,
      'relationship_note_key': instance.relationshipNoteKey,
      'phone_number_override': instance.phoneNumberOverride,
    };

_CaseContact _$CaseContactFromJson(Map<String, dynamic> json) => _CaseContact(
  personId: json['person_id'] as String,
  isSaved: json['is_saved'] as bool? ?? true,
  phoneNumberOverride: json['phone_number_override'] as String?,
  customLabelKey: json['custom_label_key'] as String?,
);

Map<String, dynamic> _$CaseContactToJson(_CaseContact instance) =>
    <String, dynamic>{
      'person_id': instance.personId,
      'is_saved': instance.isSaved,
      'phone_number_override': instance.phoneNumberOverride,
      'custom_label_key': instance.customLabelKey,
    };

_HomeLayout _$HomeLayoutFromJson(Map<String, dynamic> json) => _HomeLayout(
  grid:
      (json['grid'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  dock:
      (json['dock'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  widgetPages:
      (json['widget_pages'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((e) => e as String).toList())
          .toList() ??
      const <List<String>>[],
);

Map<String, dynamic> _$HomeLayoutToJson(_HomeLayout instance) =>
    <String, dynamic>{
      'grid': instance.grid,
      'dock': instance.dock,
      'widget_pages': instance.widgetPages,
    };

_CaseFile _$CaseFileFromJson(Map<String, dynamic> json) => _CaseFile(
  schema: (json['schema'] as num).toInt(),
  id: json['id'] as String,
  meta: CaseMeta.fromJson(json['meta'] as Map<String, dynamic>),
  device: DeviceInfo.fromJson(json['device'] as Map<String, dynamic>),
  chats: CaseChats.fromJson(json['chats'] as Map<String, dynamic>),
  cast:
      (json['cast'] as List<dynamic>?)
          ?.map((e) => CastMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CastMember>[],
  contacts:
      (json['contacts'] as List<dynamic>?)
          ?.map((e) => CaseContact.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CaseContact>[],
  home: json['home'] == null
      ? const HomeLayout()
      : HomeLayout.fromJson(json['home'] as Map<String, dynamic>),
  board: json['board'] == null
      ? null
      : Board.fromJson(json['board'] as Map<String, dynamic>),
  locks:
      (json['locks'] as List<dynamic>?)
          ?.map((e) => LockStep.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LockStep>[],
  questions:
      (json['questions'] as List<dynamic>?)
          ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Question>[],
  apps: json['apps'] as Map<String, dynamic>? ?? const <String, dynamic>{},
);

Map<String, dynamic> _$CaseFileToJson(_CaseFile instance) => <String, dynamic>{
  'schema': instance.schema,
  'id': instance.id,
  'meta': instance.meta.toJson(),
  'device': instance.device.toJson(),
  'chats': instance.chats.toJson(),
  'cast': instance.cast.map((e) => e.toJson()).toList(),
  'contacts': instance.contacts.map((e) => e.toJson()).toList(),
  'home': instance.home.toJson(),
  'board': instance.board?.toJson(),
  'locks': instance.locks.map((e) => e.toJson()).toList(),
  'questions': instance.questions.map((e) => e.toJson()).toList(),
  'apps': instance.apps,
};
