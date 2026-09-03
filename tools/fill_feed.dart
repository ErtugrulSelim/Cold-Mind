// Gives every phone that has the feed app something to explore.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/fill_feed.dart
//
// Re-running is safe: a case that already has its filler is skipped.
//
// It does two things, and both are about the same folder.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// **The pictures changed underneath the posts.** `assets/stock/photos/` used
// to hold `1.jpg` … `59.jpg` carried over from v1, and twenty-nine posts
// across s01–s04 pointed at twenty-five of them. Those files are gone and the
// replacements are generated — `f01.jpg` upward, from `tools/prompts/stock.json`
// — so every one of those references had to move. A post whose image is
// missing still renders: the grid draws a grey tile and nothing anywhere says
// why, which is the failure that looks like a design choice.
//
// **Five phones have the feed installed** — s01, s02, s03, s04 and s10 — and
// between them they held thirty-one posts. s03 and s04 had four each. The
// Explore tab is derived rather than authored (`feed_screen.dart`: every post
// in the case that is not the owner's and not already in their feed), so on
// those two phones it opened on "Nothing to explore", and Reels fell back to
// showing the feed again.
//
// A real account has a stranger's grid behind that tab and it is the one
// surface on this phone that is *supposed* to be noise. So these go into
// Explore and nowhere else: they are never added to `feed_post_ids`, which is
// what keeps them out of the feed the player reads for evidence.
//
// Two rules the filler obeys, both for the same reason — it must not be
// mistaken for the case:
//
//   * **It is attributed to tier-3 people only.** A picture of somebody's soup
//     under the name of the suspect is characterisation, and wrong
//     characterisation. Tier 3 is the background of a cast; nobody is reading
//     them for a motive.
//   * **The captions say nothing.** No names, no places that matter, no dates,
//     no numbers. A caption is one of the three surfaces that never localises,
//     so it is read in English in all eighteen languages, and there is no
//     version of this where a filler line should be worth reading twice.
import 'dart:convert';
import 'dart:io';
import 'dart:math';

/// The phones with the app on them. A key in `apps` is the install list, and
/// the other five cases do not have it — an eighteen-year-old with no
/// corporate console and a registrar with no feed are both characterisation.
const _cases = ['s01', 's02', 's03', 's04', 's10'];

/// The generated pool, `assets/stock/photos/f01.jpg` upward. Kept separate
/// from the numbered stock already in that folder so a re-run of either
/// generator cannot overwrite the other.
const _poolSize = 48;

/// The two clips, keyed by the still each was generated from.
///
/// `tools/prompts/videos.json` grows them out of a photograph that is already
/// in the grid, so the post that draws that still is the post that should play
/// the clip: the same place, one swipe apart. Everywhere except Reels the post
/// keeps drawing the still, which is why nothing else has to change.
const _clips = <String, String>{
  'assets/stock/photos/f21.jpg': 'assets/stock/video/f01.mp4',
  'assets/stock/photos/f37.jpg': 'assets/stock/video/f02.mp4',
};

/// Deliberately about nothing. See the note above.
const _captions = <String>[
  'finally',
  'this again',
  'no notes',
  'worth it',
  'same time next week',
  'the light this evening',
  'took three goes',
  'not sorry',
  'small victories',
  'it lives',
  'better than yesterday',
  'someone else can cook tomorrow',
  'ten out of ten',
  'we go again',
  'nobody asked',
  'still here',
  'earned this',
  'good weekend for it',
  'left it too late as usual',
  'the usual spot',
  'could get used to this',
  'about time',
  'never doing that again',
  'quiet one',
  'rain stopped for eleven minutes',
  'attempt two',
  'no complaints',
  'happy with that',
  'back at it',
  'peak of my career',
  'last one of these',
  'that will do',
  'up early for once',
  'went the long way round',
  'this is the whole post',
  'unbothered',
  'a good hour',
  'first time in ages',
  'nothing to report',
  'end of an era',
];

void main() {
  for (final id in _cases) {
    final peoplePath = 'assets/people/people_$id.json';
    final people =
        jsonDecode(File(peoplePath).readAsStringSync()) as Map<String, dynamic>;
    final posts = people['instagram_posts'] as List? ?? people['posts'] as List?;

    if (posts == null) {
      print('$id  no posts array — skipped');
      continue;
    }

    // Background people only.
    final cast = (people['people'] as List).cast<Map<String, dynamic>>();
    final background = cast
        .where((person) => (person['tier'] as int? ?? 3) >= 3)
        .map((person) => '${person['id']}')
        .toList();
    if (background.isEmpty) {
      print('$id  no tier-3 people to attribute to — skipped');
      continue;
    }

    // The newest thing already on the feed, so the filler sits behind it
    // rather than in the case's own future.
    var anchor = DateTime(2025, 6);
    for (final post in posts.cast<Map<String, dynamic>>()) {
      final at = DateTime.tryParse('${post['timestamp']}');
      if (at != null && at.isAfter(anchor)) anchor = at;
    }

    // Seeded on the case id so the same run twice gives the same grid, and so
    // two phones do not deal their pictures in the same order.
    final random = Random(id.hashCode);
    final pool = [for (var i = 1; i <= _poolSize; i++) i]..shuffle(random);
    final lines = [..._captions]..shuffle(random);
    var next = 0;
    String draw() =>
        'assets/stock/photos/f${pool[next++ % _poolSize].toString().padLeft(2, '0')}.jpg';

    // ── the posts that were already here ────────────────────────────────────
    var moved = 0;
    for (final post in posts.cast<Map<String, dynamic>>()) {
      final asset = '${post['image_asset'] ?? ''}';
      // Only the shared stock. A case's own photographs — s10's posts are all
      // `assets/cases/s10/photos/…` — are evidence and stay where they are.
      if (!asset.startsWith('assets/stock/photos/')) continue;
      if (RegExp(r'/f\d\d\.jpg$').hasMatch(asset)) continue;
      post['image_asset'] = draw();
      moved++;
    }

    // ── and the filler behind them ──────────────────────────────────────────
    final already =
        posts.where((post) => '${(post as Map)['id']}'.startsWith('f_ig_'));
    var added = 0;
    if (already.isEmpty) {
      final count = 12 + random.nextInt(4); // 12–15
      for (var i = 0; i < count; i++) {
        final at = anchor.subtract(
          Duration(days: random.nextInt(430), minutes: random.nextInt(1440)),
        );
        posts.add({
          'id': 'f_ig_${101 + i}',
          'caption': lines[i % lines.length],
          'like_count': 12 + random.nextInt(880),
          'tags': <String>[],
          'comments': <dynamic>[],
          'person_id': background[i % background.length],
          'timestamp': at.toIso8601String().split('.').first,
          'liked_by_owner': false,
          'image_asset': draw(),
        });
      }
      added = count;
    }

    // ── and the two that move ───────────────────────────────────────────────
    var clipped = 0;
    for (final post in posts.cast<Map<String, dynamic>>()) {
      final clip = _clips['${post['image_asset'] ?? ''}'];
      if (clip == null || post['video_asset'] == clip) continue;
      post['video_asset'] = clip;
      clipped++;
    }

    File(peoplePath).writeAsStringSync(
      '${const JsonEncoder.withIndent('  ').convert(people)}\n',
    );
    print('$id  ${clipped > 0 ? '$clipped reel(s), ' : ''}'
        '${moved > 0 ? '$moved moved off the old stock, ' : ''}'
        '${added > 0 ? '$added added to Explore from ${background.length} '
            'background account(s)' : 'filler already present'}');
  }
}
