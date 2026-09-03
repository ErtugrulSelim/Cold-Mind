import '../../data/l10n/case_strings.dart';
import '../../data/models/case_file.dart';
import '../../data/models/person.dart';

/// Who a person is *on this phone*.
///
/// The same person is not the same thing on every device. Three sources decide
/// what a name looks like here, in order:
///
///  1. the case's `cast` — what the owner called them ("Ema", not "Ema Rand");
///  2. the phone's own address book — whether they are saved at all, and under
///     what label;
///  3. the cast file — their real name, which is what a stranger's phone would
///     never show.
///
/// **An unsaved number is evidence.** A phone that has messaged someone forty
/// times without saving their name says something, and every surface has to
/// render that the same way — which is why this lives in one place rather than
/// being re-derived by each app.
class ContactBook {
  final PeoplePool people;
  final CaseStrings? strings;

  final String _ownerName;
  final Map<String, CastMember> _cast;
  final Map<String, CaseContact> _contacts;

  ContactBook({
    required CaseFile file,
    required this.people,
    required this.strings,
  }) : _ownerName = file.device.ownerName,
       _cast = {for (final m in file.cast) m.personId: m},
       _contacts = {for (final c in file.contacts) c.personId: c};

  Person? person(String personId) => people.byId(personId);

  /// True when this person is in the phone's address book at all.
  bool isSaved(String personId) => _contacts[personId]?.isSaved ?? false;

  /// What this phone shows for someone: their saved name, or — when they were
  /// never saved — the bare number, the way a real phone would.
  String displayName(String personId) {
    final contact = _contacts[personId];
    final label = contact?.customLabelKey;
    final pack = strings;
    if (label != null && pack != null) return pack.t(label);

    // Not in the address book is not saved.
    //
    // This used to read `contact != null && !contact.isSaved`, which only
    // honoured the flag for somebody who was **in** the list — so a person
    // left out of it entirely, which is the strongest form of not being
    // saved, was drawn by their full name anyway. Seven of the ten cases have
    // such a person.
    //
    // s05's fourteenth question is the one it cost. It asks who sent a message
    // "from a number that is not in the contacts", and the phone put the name
    // at the top of the thread: the question's own premise was false on
    // screen, and its answer was free.
    if (!isSaved(personId)) return phoneNumber(personId);

    final nickname = _cast[personId]?.nickname;
    if (nickname != null && nickname.isNotEmpty) return nickname;

    final full = people.byId(personId)?.contact.fullName;
    if (full != null && full.isNotEmpty) return full;

    return phoneNumber(personId);
  }

  /// The full name from the cast file, regardless of how the phone saved them.
  /// Used where the player is being told who someone *is* rather than what the
  /// owner called them.
  String realName(String personId) =>
      people.byId(personId)?.contact.fullName ?? displayName(personId);

  String phoneNumber(String personId) =>
      _cast[personId]?.phoneNumberOverride ??
      _contacts[personId]?.phoneNumberOverride ??
      people.byId(personId)?.contact.phoneNumber ??
      personId;

  String? photo(String personId) => people.byId(personId)?.photoAsset;

  /// The avatar colour the cast file assigned, for people with no photograph.
  String avatarColor(String personId) =>
      people.byId(personId)?.contact.avatarColor ?? '#94A3B8';

  /// What the case says this person is to the owner. Not shown as a label —
  /// it is authoring metadata, and putting "suspect" on screen would hand the
  /// player the answer.
  String? role(String personId) => _cast[personId]?.role;

  /// The owner of the phone.
  String get ownerName => _ownerName;
}
