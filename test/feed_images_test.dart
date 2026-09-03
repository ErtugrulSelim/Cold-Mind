import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The pictures the feed draws, and whether they are there.
///
/// `assets/stock/photos/` held `1.jpg` … `59.jpg` carried over from v1, and
/// twenty-nine posts across four cases pointed into it. Replacing that folder
/// left every one of those references aimed at a file that no longer exists.
///
/// Nothing catches that on its own. `Image.asset` on a missing path draws an
/// error box inside the grid tile, the screen still lays out, `app_render_test`
/// still passes, and the Explore tab looks like a design decision rather than
/// a broken one.
void main() {
  final peopleFiles = Directory('assets/people')
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .toList()
    ..sort((a, b) => a.path.compareTo(b.path));

  test('every post points at a picture that exists', () {
    final failures = <String>[];
    var checked = 0;

    for (final file in peopleFiles) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final posts = (json['instagram_posts'] as List? ?? const [])
          .cast<Map<String, dynamic>>();

      for (final post in posts) {
        final asset = post['image_asset'];
        if (asset == null) continue;
        checked++;
        if (!File('$asset').existsSync()) {
          failures.add(
            '${json['case_id']} ${post['id']} -> $asset does not exist',
          );
        }
      }
    }

    expect(checked, greaterThan(0), reason: 'some case has posts with images');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('a post that plays a clip also keeps the still it grew out of', () {
    // Only the Reels tab plays video; the profile grid and Explore draw
    // `image_asset`. A post with a clip and no still is a grey tile in two
    // surfaces out of three, and `_ReelVideo` has nothing to show while the
    // first frame decodes — or if the plugin is not there at all, which is the
    // case in every widget test.
    final failures = <String>[];
    var clips = 0;

    for (final file in peopleFiles) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      for (final post in (json['instagram_posts'] as List? ?? const [])
          .cast<Map<String, dynamic>>()) {
        final video = post['video_asset'];
        if (video == null) continue;
        clips++;

        if (!File('$video').existsSync()) {
          failures.add('${json['case_id']} ${post['id']} -> $video is missing');
        }
        if (post['image_asset'] == null) {
          failures.add(
            '${json['case_id']} ${post['id']} plays a clip with no still '
            'behind it',
          );
        }
      }
    }

    expect(clips, greaterThan(0), reason: 'some case has a reel');
    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('the feed the player reads is never the filler', () {
    // The filler exists to give the Explore tab a stranger's grid, which is
    // the one surface on this phone that is meant to be noise. Explore is
    // derived — every post that is not the owner's and not in their feed — so
    // the way filler stays out of the way is by staying out of
    // `feed_post_ids`. Put one in there and the player is reading somebody's
    // lunch as evidence.
    final failures = <String>[];

    for (final file in peopleFiles) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final id = '${json['case_id']}';
      final casePath = File('assets/cases/$id/case.json');
      if (!casePath.existsSync()) continue;

      final instagram = ((jsonDecode(casePath.readAsStringSync())
              as Map<String, dynamic>)['apps']
          as Map<String, dynamic>)['instagram'];
      if (instagram is! Map) continue;

      final feed = [
        for (final one in (instagram['feed_post_ids'] as List? ?? const []))
          '$one',
      ];
      final own = [
        for (final one in ((instagram['profile'] as Map?)?['post_ids'] as List? ??
            const []))
          '$one',
      ];

      for (final postId in [...feed, ...own]) {
        if (postId.startsWith('f_ig_')) {
          failures.add('$id shows filler post $postId to the player');
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });

  test('no filler caption is long enough to be read as evidence', () {
    // A filler line says nothing on purpose: no names, no places, no dates and
    // no numbers. The length cap is the cheap proxy — anything that grew into
    // a sentence with content in it has stopped being filler.
    final failures = <String>[];

    for (final file in peopleFiles) {
      final json = jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      for (final post in (json['instagram_posts'] as List? ?? const [])
          .cast<Map<String, dynamic>>()) {
        if (!'${post['id']}'.startsWith('f_ig_')) continue;
        final caption = '${post['caption'] ?? ''}';

        if (caption.length > 60) {
          failures.add('${json['case_id']} ${post['id']}: "$caption"');
        }
        if (RegExp(r'\d').hasMatch(caption)) {
          failures.add(
            '${json['case_id']} ${post['id']} carries a number: "$caption"',
          );
        }
      }
    }

    expect(failures, isEmpty, reason: '\n${failures.join('\n')}');
  });
}
