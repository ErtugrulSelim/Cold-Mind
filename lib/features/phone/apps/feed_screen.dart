import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/models/case_file.dart';
import '../../../data/models/person.dart';
import '../chats/chat_data.dart';
import '../chats/chat_list_screen.dart';
import '../contact_book.dart';
import '../phone_format.dart';
import '../widgets/avatar.dart';

/// The social feed.
///
/// **The profile is the tab that opens**, which inverts how the real thing
/// works, because on these phones the profile is usually the evidence and the
/// posts usually are not. Two hundred and fourteen followers, a hundred and
/// eighty following, and zero posts is a complete portrait of somebody, and an
/// app that opened on a grid would render that as an empty screen.
///
/// The feed is the other half. What the owner was *shown* — whose posts, in
/// what order, and which ones they reached over to like — is a record of who
/// they were paying attention to in the weeks that matter, and unlike a message
/// it was never written for anyone to read.
///
/// Direct messages get the full conversation reader. People say things in a DM
/// they would never put in a thread their employer can see.
class FeedScreen extends StatefulWidget {
  final CaseFile file;
  final ContactBook contacts;
  final CaseStrings? strings;

  const FeedScreen({
    super.key,
    required this.file,
    required this.contacts,
    required this.strings,
  });

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  /// Profile first — see the class comment. This is a deliberate default, not
  /// an oversight.
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final strings = widget.strings;
    final data = widget.file.appData('instagram') ?? const {};
    final profile = data['profile'] as Map<String, dynamic>? ?? const {};

    final ownPosts = _postsFor(profile['post_ids']);
    final feedPosts = _postsFor(data['feed_post_ids']);
    final likedAt = _likedAt(data['liked_posts']);
    final following = [
      for (final id in (profile['following_person_ids'] as List? ?? const []))
        '$id',
    ];
    final dms = _readDms(data);
    // Explore is what the app would surface from accounts the owner does not
    // follow: every post in the case that is not theirs and not already in
    // their feed. The cases ship `explore_post_ids` empty, so deriving it is
    // the only way the tab has anything in it.
    final seen = {
      for (final post in ownPosts) post.id,
      for (final post in feedPosts) post.id,
    };
    final discover = [
      for (final post in widget.contacts.people.instagramPosts)
        if (!seen.contains(post.id)) post,
    ]..sort((a, b) => b.likeCount.compareTo(a.likeCount));

    final tabs = <({IconData icon, Widget view})>[
      (
        icon: Icons.person_rounded,
        view: _ProfileTab(
          username: '${data['username'] ?? ''}',
          photoAsset: data['profile_photo_asset'] as String?,
          ownerName: widget.contacts.ownerName,
          profile: profile,
          posts: ownPosts,
          following: following,
          contacts: widget.contacts,
          strings: strings,
        ),
      ),
      (
        icon: Icons.home_rounded,
        view: _FeedTab(
          following: following,
          posts: feedPosts,
          likedAt: likedAt,
          contacts: widget.contacts,
          strings: strings,
        ),
      ),
      (
        icon: Icons.search_rounded,
        view: _ExploreTab(
          posts: discover,
          contacts: widget.contacts,
          strings: strings,
        ),
      ),
      (
        icon: Icons.slow_motion_video_rounded,
        view: _ReelsTab(
          posts: discover.isEmpty ? feedPosts : discover,
          contacts: widget.contacts,
          strings: strings,
        ),
      ),
      (
        icon: Icons.send_rounded,
        view: dms.isEmpty
            ? _Empty(text: strings?.c('ui.no_messages') ?? 'No messages')
            : ChatListScreen(
                threads: dms,
                contacts: widget.contacts,
                strings: strings,
                titleKey: 'ui.direct',
                embedded: true,
              ),
      ),
    ];

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        // The handle, not the app's name. This is whose account it is.
        title: Text('${data['username'] ?? ''}'),
      ),
      body: IndexedStack(
        index: _tab,
        children: [for (final tab in tabs) tab.view],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        backgroundColor: device.surface,
        indicatorColor: device.accentDim,
        height: 62,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        destinations: [
          for (final tab in tabs)
            NavigationDestination(
              icon: Icon(tab.icon, color: device.textSecondary),
              selectedIcon: Icon(tab.icon, color: Colors.white),
              label: '',
            ),
        ],
      ),
    );
  }

  /// Posts named by an id list, newest first.
  List<InstagramPost> _postsFor(Object? rawIds) {
    if (rawIds is! List) return const [];
    final ids = {for (final id in rawIds) '$id'};
    return [
      for (final post in widget.contacts.people.instagramPosts)
        if (ids.contains(post.id)) post,
    ]..sort(
      (a, b) =>
          (b.timestamp ?? DateTime(0)).compareTo(a.timestamp ?? DateTime(0)),
    );
  }

  /// When the owner liked a post, by post id. A like is a timestamped act of
  /// attention, and the minute of it is often the point.
  Map<String, DateTime> _likedAt(Object? raw) {
    if (raw is! List) return const {};
    return {
      for (final entry in raw)
        if (entry is Map<String, dynamic>)
          // An unparseable timestamp drops the entry rather than the post: a
          // like with no minute on it is not evidence of a minute.
          '${entry['post_id']}': ?DateTime.tryParse('${entry['liked_at']}'),
    };
  }

  List<ChatThread> _readDms(Map<String, dynamic> data) {
    final raw = data['dms'];
    if (raw is! List) return const [];

    final threads = <ChatThread>[];
    for (final entry in raw) {
      if (entry is! Map<String, dynamic>) continue;
      final personId = entry['contact_person_id'] as String?;
      if (personId == null) continue;

      final lines = <ChatLine>[];
      for (final rawLine in (entry['messages'] as List? ?? const [])) {
        if (rawLine is! Map<String, dynamic>) continue;
        final at = DateTime.tryParse('${rawLine['timestamp']}');
        if (at == null) continue;
        lines.add(
          ChatLine(
            id: '${rawLine['id']}',
            senderId: rawLine['sender'] == 'user' ? null : personId,
            kind: ChatMessageKind.text,
            textKey: rawLine['text_key'] as String?,
            timestamp: at,
            isDeleted: rawLine['is_deleted'] == true,
          ),
        );
      }
      lines.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      if (lines.isEmpty) continue;
      threads.add(ChatThread(personId: personId, lastSeen: null, lines: lines));
    }
    return threads;
  }
}

// ── Profile ─────────────────────────────────────────────────────────────────

/// Whose account this is, and the three numbers that describe it.
class _ProfileTab extends StatelessWidget {
  final String username;
  final String? photoAsset;
  final String ownerName;
  final Map<String, dynamic> profile;
  final List<InstagramPost> posts;
  final List<String> following;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _ProfileTab({
    required this.username,
    required this.photoAsset,
    required this.ownerName,
    required this.profile,
    required this.posts,
    required this.following,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final bioKey = profile['bio_key'] as String?;

    // Both lists are named people, cast members and background accounts alike.
    final followers = _roster(profile['followers'], contacts);
    final followingRoster = _roster(profile['following'], contacts).isEmpty
        ? [for (final id in following) ?RosterEntry.from(id, contacts)]
        : _roster(profile['following'], contacts);

    return ListView(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      children: [
        Padding(
          padding: const EdgeInsets.all(ColdSpace.lg),
          child: Row(
            children: [
              Avatar(
                photoAsset: photoAsset,
                name: ownerName,
                colorHex: '#334155',
                size: 78,
              ),
              const SizedBox(width: ColdSpace.lg),
              Expanded(
                child: Row(
                  children: [
                    _Count(
                      value: posts.length,
                      label: strings?.c('ui.posts') ?? 'Posts',
                    ),
                    _Count(
                      // The count *is* the roster length. An authored number
                      // that promised more people than the phone can name was
                      // the thing that read as fake: two hundred followers and
                      // a list five long.
                      value: followers.length,
                      label: strings?.c('ui.followers') ?? 'Followers',
                      onTap: followers.isEmpty
                          ? null
                          : () => _openRoster(
                              context,
                              followers,
                              strings?.c('ui.followers') ?? 'Followers',
                            ),
                    ),
                    _Count(
                      value: followingRoster.length,
                      label: strings?.c('ui.following') ?? 'Following',
                      onTap: followingRoster.isEmpty
                          ? null
                          : () => _openRoster(
                              context,
                              followingRoster,
                              strings?.c('ui.following') ?? 'Following',
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ColdSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ownerName,
                style: ColdType.subtitle.copyWith(color: device.textPrimary),
              ),
              if (bioKey != null) ...[
                const SizedBox(height: 2),
                Text(
                  strings?.t(bioKey) ?? '',
                  style: ColdType.body.copyWith(color: device.textSecondary),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: ColdSpace.lg),
        Divider(height: 1, color: device.hairline),
        if (posts.isEmpty)
          Padding(
            padding: const EdgeInsets.all(ColdSpace.xxl),
            child: Center(
              child: Text(
                strings?.c('ui.ig.no_posts') ?? 'No posts yet',
                style: ColdType.body.copyWith(color: device.textTertiary),
              ),
            ),
          )
        else
          _PostGrid(posts: posts, contacts: contacts, strings: strings),
      ],
    );
  }

  /// A roster list from the case data, cast ids and named accounts alike.
  static List<RosterEntry> _roster(Object? raw, ContactBook contacts) {
    if (raw is! List) return const [];
    return [for (final entry in raw) ?RosterEntry.from(entry, contacts)];
  }

  void _openRoster(
    BuildContext context,
    List<RosterEntry> entries,
    String title,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            RosterScreen(title: title, entries: entries, contacts: contacts),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback? onTap;

  const _Count({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    // Each of the three takes a third of what is left beside the avatar. A
    // four-figure follower count and a nine-letter "Following" do not fit
    // their natural widths side by side on a 390pt phone, and these numbers
    // are exactly the ones that must stay readable.
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.sm)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: ColdSpace.xs),
          child: Column(
            children: [
              Text(
                '$value',
                maxLines: 1,
                style: ColdType.display.copyWith(
                  color: device.textPrimary,
                  fontSize: 21,
                ),
              ),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: ColdType.micro.copyWith(color: device.textTertiary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The owner's own posts, three across.
class _PostGrid extends StatelessWidget {
  final List<InstagramPost> posts;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _PostGrid({
    required this.posts,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      padding: const EdgeInsets.all(2),
      children: [
        for (final post in posts)
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => _PostScreen(
                  post: post,
                  contacts: contacts,
                  strings: strings,
                ),
              ),
            ),
            child: post.imageAsset == null
                ? ColoredBox(color: device.surfaceRaised)
                : Image.asset(
                    post.imageAsset!,
                    fit: BoxFit.cover,
                    cacheWidth: 300,
                    errorBuilder: (_, _, _) =>
                        ColoredBox(color: device.surfaceRaised),
                  ),
          ),
      ],
    );
  }
}

// ── Feed ────────────────────────────────────────────────────────────────────

/// What the owner was shown, and what they reached over to like.
class _FeedTab extends StatelessWidget {
  final List<String> following;
  final List<InstagramPost> posts;
  final Map<String, DateTime> likedAt;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _FeedTab({
    required this.following,
    required this.posts,
    required this.likedAt,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    if (following.isEmpty && posts.isEmpty) {
      return _Empty(text: strings?.c('ui.ig.no_posts') ?? 'No posts yet');
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: ColdSpace.xl),
      children: [
        if (following.isNotEmpty)
          _StoryRail(
            personIds: following,
            contacts: contacts,
            strings: strings,
          ),
        for (final post in posts)
          _PostCard(
            post: post,
            likedAt: likedAt[post.id],
            contacts: contacts,
            strings: strings,
          ),
      ],
    );
  }
}

/// The people the owner follows, as a rail of faces.
///
/// A ring rather than a brand gradient: the point of the rail here is *who is
/// on it*, and a coloured halo per face would say nothing the names do not.
class _StoryRail extends StatelessWidget {
  final List<String> personIds;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _StoryRail({
    required this.personIds,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Container(
      height: 102,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: device.hairline)),
      ),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.lg,
          vertical: ColdSpace.md,
        ),
        itemCount: personIds.length,
        separatorBuilder: (_, _) => const SizedBox(width: ColdSpace.md),
        itemBuilder: (context, i) {
          final id = personIds[i];
          final name = contacts.displayName(id);

          return SizedBox(
            width: 62,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: device.accent, width: 1.5),
                  ),
                  child: Avatar(
                    photoAsset: contacts.photo(id),
                    name: name,
                    colorHex: contacts.avatarColor(id),
                    size: 48,
                  ),
                ),
                const SizedBox(height: ColdSpace.xs),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: ColdType.micro.copyWith(color: device.textSecondary),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// One post in the feed: who, where, the picture, and what the owner did.
class _PostCard extends StatelessWidget {
  final InstagramPost post;
  final DateTime? likedAt;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _PostCard({
    required this.post,
    required this.likedAt,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final name = contacts.displayName(post.personId);

    return Padding(
      padding: const EdgeInsets.only(bottom: ColdSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ColdSpace.lg,
              vertical: ColdSpace.sm,
            ),
            child: Row(
              children: [
                Avatar(
                  photoAsset: contacts.photo(post.personId),
                  name: name,
                  colorHex: contacts.avatarColor(post.personId),
                  size: 34,
                ),
                const SizedBox(width: ColdSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ColdType.subtitle.copyWith(
                          color: device.textPrimary,
                        ),
                      ),
                      if (post.location != null)
                        // Locations are proper nouns and stay untranslated.
                        Text(
                          post.location!,
                          style: ColdType.micro.copyWith(
                            color: device.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (post.timestamp != null)
                  Text(
                    format.shortDate(post.timestamp!),
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
              ],
            ),
          ),
          if (post.imageAsset != null)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => _PostScreen(
                    post: post,
                    contacts: contacts,
                    strings: strings,
                  ),
                ),
              ),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset(
                  post.imageAsset!,
                  fit: BoxFit.cover,
                  cacheWidth: 700,
                  errorBuilder: (_, _, _) =>
                      ColoredBox(color: device.surfaceRaised),
                ),
              ),
            ),
          _PostFooter(post: post, likedAt: likedAt, strings: strings),
        ],
      ),
    );
  }
}

/// Likes, caption, and — the part a real client does not show — *when* the
/// owner liked it.
class _PostFooter extends StatelessWidget {
  final InstagramPost post;
  final DateTime? likedAt;
  final CaseStrings? strings;

  const _PostFooter({
    required this.post,
    required this.likedAt,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);
    final liked = post.likedByOwner || likedAt != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.sm,
        ColdSpace.lg,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                size: 19,
                color: liked ? device.danger : device.textSecondary,
              ),
              const SizedBox(width: ColdSpace.md),
              Icon(
                Icons.mode_comment_outlined,
                size: 18,
                color: device.textSecondary,
              ),
              const Spacer(),
              Text(
                strings?.cp('ui.ig.likes_n', {'count': post.likeCount}) ??
                    '${post.likeCount}',
                style: ColdType.meta.copyWith(color: device.textSecondary),
              ),
            ],
          ),
          // The owner's own like, with the minute on it. A real client would
          // never surface this; it is one of the few timestamps on the phone
          // that records attention rather than action.
          if (likedAt != null) ...[
            const SizedBox(height: ColdSpace.xs),
            Row(
              children: [
                Icon(Icons.favorite_rounded, size: 11, color: device.danger),
                const SizedBox(width: ColdSpace.xs),
                Text(
                  format.dateTime(likedAt!),
                  style: ColdType.micro.copyWith(color: device.textTertiary),
                ),
              ],
            ),
          ],
          if (post.caption.isNotEmpty) ...[
            const SizedBox(height: ColdSpace.xs),
            // Captions are literal strings in the cast file and always render
            // in English.
            Text(
              post.caption,
              style: ColdType.body.copyWith(color: device.textPrimary),
            ),
          ],
          if (post.comments.isNotEmpty) ...[
            const SizedBox(height: ColdSpace.xs),
            Text(
              strings?.cp('ui.ig.view_all_n', {
                    'count': post.comments.length,
                  }) ??
                  '${post.comments.length}',
              style: ColdType.bodySmall.copyWith(color: device.textTertiary),
            ),
          ],
        ],
      ),
    );
  }
}

/// One post on its own, opened from a grid or a feed card.
class _PostScreen extends StatelessWidget {
  final InstagramPost post;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _PostScreen({
    required this.post,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    final format = PhoneFormat(strings);

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(strings?.c('ui.ig.post') ?? 'Post')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: ColdSpace.xl),
        children: [
          if (post.imageAsset != null)
            InteractiveViewer(
              maxScale: 5,
              child: Image.asset(
                post.imageAsset!,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) =>
                    ColoredBox(color: device.surfaceRaised),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(ColdSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contacts.displayName(post.personId),
                  style: ColdType.subtitle.copyWith(color: device.textPrimary),
                ),
                if (post.timestamp != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    format.dateTime(post.timestamp!),
                    style: ColdType.meta.copyWith(color: device.textSecondary),
                  ),
                ],
                if (post.location != null)
                  Text(
                    post.location!,
                    style: ColdType.meta.copyWith(color: device.textTertiary),
                  ),
                if (post.caption.isNotEmpty) ...[
                  const SizedBox(height: ColdSpace.md),
                  Text(
                    post.caption,
                    style: ColdType.body.copyWith(
                      color: device.textPrimary,
                      height: 1.5,
                    ),
                  ),
                ],
                const SizedBox(height: ColdSpace.md),
                Text(
                  strings?.cp('ui.ig.likes_n', {'count': post.likeCount}) ??
                      '${post.likeCount}',
                  style: ColdType.meta.copyWith(color: device.textSecondary),
                ),
                for (final comment in post.comments) ...[
                  const SizedBox(height: ColdSpace.sm),
                  Text(
                    '${contacts.displayName(comment.personId)}  ${comment.text}',
                    style: ColdType.bodySmall.copyWith(
                      color: device.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;

  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      text,
      style: ColdType.body.copyWith(color: context.device.textTertiary),
    ),
  );
}

/// The face of someone the owner follows, used where a profile is listed.
class FollowedFace extends StatelessWidget {
  final String personId;
  final ContactBook contacts;

  const FollowedFace({
    super.key,
    required this.personId,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) => Avatar(
    photoAsset: contacts.photo(personId),
    name: contacts.displayName(personId),
    colorHex: contacts.avatarColor(personId),
    size: 40,
  );
}

/// One account on a follower or following list.
///
/// Either somebody the case has a cast entry for — who gets their real face and
/// the name this phone saved them under — or a name and a handle and nothing
/// else, which is what most of anybody's list actually is.
class RosterEntry {
  final String? personId;
  final String username;
  final String name;

  const RosterEntry({
    required this.personId,
    required this.username,
    required this.name,
  });

  static RosterEntry? from(Object? raw, ContactBook contacts) {
    if (raw is String) {
      // A bare id is a cast member.
      final person = contacts.person(raw);
      if (person == null) return null;
      return RosterEntry(
        personId: raw,
        username: person.instagram?.username ?? '',
        name: contacts.realName(raw),
      );
    }
    if (raw is! Map<String, dynamic>) return null;

    final personId = raw['person_id'] as String?;
    if (personId != null) {
      final person = contacts.person(personId);
      return RosterEntry(
        personId: personId,
        username: person?.instagram?.username ?? '${raw['username'] ?? ''}',
        name: contacts.realName(personId),
      );
    }
    final username = '${raw['username'] ?? ''}';
    if (username.isEmpty) return null;
    return RosterEntry(
      personId: null,
      username: username,
      name: '${raw['name'] ?? ''}',
    );
  }
}

/// A follower or following list.
///
/// **Every account on it has a name.** A count that promised more people than
/// the phone could name was the thing that read as invented — two hundred
/// followers and a list five long. Cast members appear with their real face and
/// the handle they use; everyone else is a name and a handle, which is what
/// most of anybody's list actually is.
class RosterScreen extends StatelessWidget {
  final String title;
  final List<RosterEntry> entries;
  final ContactBook contacts;

  const RosterScreen({
    super.key,
    required this.title,
    required this.entries,
    required this.contacts,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: ColdSpace.xl),
        itemCount: entries.length,
        separatorBuilder: (_, _) => Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Divider(height: 1, color: device.hairline),
        ),
        itemBuilder: (context, i) {
          final entry = entries[i];
          final personId = entry.personId;
          final person = personId == null ? null : contacts.person(personId);

          return ListTile(
            leading: Avatar(
              photoAsset: personId == null ? null : contacts.photo(personId),
              name: entry.name,
              colorHex: personId == null
                  ? '#8E8E93'
                  : contacts.avatarColor(personId),
              size: 44,
            ),
            // The handle above the name, the way a follower list reads: the
            // handle is what the owner sees, the name is who it is.
            title: Text(
              entry.username.isEmpty ? entry.name : entry.username,
              style: ColdType.subtitle.copyWith(color: device.textPrimary),
            ),
            subtitle: Text(
              entry.name,
              style: ColdType.bodySmall.copyWith(color: device.textSecondary),
            ),
            trailing: person?.instagram?.isPrivate == true
                ? Icon(
                    Icons.lock_outline_rounded,
                    size: 15,
                    color: device.textTertiary,
                  )
                : null,
          );
        },
      ),
    );
  }
}

// ── Explore ─────────────────────────────────────────────────────────────────

/// What the app would put in front of somebody who follows none of these
/// accounts: a grid, sorted by how much attention each post got.
///
/// Every case ships `explore_post_ids` empty, so the pool is derived — the
/// posts the case wrote that are neither the owner's nor already in their feed.
/// That keeps the tab honest: nothing here is invented, it is the same cast
/// seen from outside.
class _ExploreTab extends StatelessWidget {
  final List<InstagramPost> posts;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _ExploreTab({
    required this.posts,
    required this.contacts,
    required this.strings,
  });

  @override
  Widget build(BuildContext context) {
    if (posts.isEmpty) {
      return _Empty(text: strings?.c('ui.ig.no_posts') ?? 'Nothing to explore');
    }

    return _PostGrid(posts: posts, contacts: contacts, strings: strings);
  }
}

// ── Reels ───────────────────────────────────────────────────────────────────

/// Full-height, one post at a time, swiped vertically.
///
/// The same posts as everywhere else, in the format that changes how they are
/// read: a picture that filled the screen and had to be swiped past is a
/// different piece of evidence from a thumbnail in a grid, and the caption sits
/// over it rather than under it.
class _ReelsTab extends StatefulWidget {
  final List<InstagramPost> posts;
  final ContactBook contacts;
  final CaseStrings? strings;

  const _ReelsTab({
    required this.posts,
    required this.contacts,
    required this.strings,
  });

  @override
  State<_ReelsTab> createState() => _ReelsTabState();
}

class _ReelsTabState extends State<_ReelsTab> {
  @override
  Widget build(BuildContext context) {
    final device = context.device;

    if (widget.posts.isEmpty) {
      return _Empty(
        text: widget.strings?.c('ui.ig.reel_unavailable') ?? 'No reels',
      );
    }

    return ColoredBox(
      color: Colors.black,
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        itemCount: widget.posts.length,
        itemBuilder: (context, i) {
          final post = widget.posts[i];
          final name = widget.contacts.displayName(post.personId);

          return Stack(
            fit: StackFit.expand,
            children: [
              if (post.imageAsset != null)
                Image.asset(
                  post.imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      ColoredBox(color: device.surfaceRaised),
                )
              else
                ColoredBox(color: device.surfaceRaised),
              // A scrim only where the text sits. Dimming the whole frame would
              // take detail out of the one thing the player is here to look at.
              const Align(
                alignment: Alignment.bottomCenter,
                child: FractionallySizedBox(
                  heightFactor: 0.42,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0xCC000000)],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: ColdSpace.lg,
                right: 72,
                bottom: ColdSpace.xl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Avatar(
                          photoAsset: widget.contacts.photo(post.personId),
                          name: name,
                          colorHex: widget.contacts.avatarColor(post.personId),
                          size: 34,
                        ),
                        const SizedBox(width: ColdSpace.sm),
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ColdType.subtitle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (post.caption.isNotEmpty) ...[
                      const SizedBox(height: ColdSpace.sm),
                      Text(
                        post.caption,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: ColdType.body.copyWith(color: Colors.white),
                      ),
                    ],
                  ],
                ),
              ),
              // The rail of counts, where a reel puts them.
              Positioned(
                right: ColdSpace.md,
                bottom: ColdSpace.xl,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      post.likedByOwner
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: post.likedByOwner ? device.danger : Colors.white,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.likeCount}',
                      style: ColdType.meta.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: ColdSpace.lg),
                    const Icon(
                      Icons.mode_comment_outlined,
                      color: Colors.white,
                      size: 26,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${post.comments.length}',
                      style: ColdType.meta.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
