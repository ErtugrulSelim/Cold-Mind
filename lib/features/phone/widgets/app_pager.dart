import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../app_registry.dart';
import 'app_tile.dart';

/// Apps across, on every page.
const int kAppPagerColumns = 4;

/// Rows on a page that carries nothing else.
///
/// Public, along with [kAppPagerRowsWithHeader] and [kAppPagerColumns]:
/// whether a case's home screen ever reaches a second page is exactly this
/// arithmetic, and anything that needs to check it — a test, a future
/// author-facing tool — has to use the same capacity the pager itself lays
/// out with, not a copy that can drift.
const int kAppPagerRowsPerPage = 3;

/// Rows on a page that also carries a widget row, which gives up most of its
/// height to it.
const int kAppPagerRowsWithHeader = 2;

/// The home screen's app pages.
///
/// How many rows fit is measured rather than hardcoded, because a page that
/// carries widgets gives up most of its height to them and one that does not
/// gets the rest. Fixing the row count would either clip a page with widgets
/// on it or leave the others half empty on a tall device.
class AppPager extends StatefulWidget {
  final List<ColdApp> apps;
  final String Function(ColdApp app) labelFor;
  final ValueChanged<String> onOpen;

  /// The widget row for a given page, or null when that page carries none. A
  /// real home screen's widgets are not only ever on the first page — the
  /// owner can set some up on the second just as easily — so this is asked
  /// for every page as it is laid out, not just the one at index 0.
  final Widget? Function(int page) headerFor;

  const AppPager({
    super.key,
    required this.apps,
    required this.labelFor,
    required this.onOpen,
    required this.headerFor,
  });

  @override
  State<AppPager> createState() => _AppPagerState();
}

class _AppPagerState extends State<AppPager> {
  final PageController _controller = PageController();
  int _page = 0;

  /// Icon, gap and label. Kept in step with [AppTile].
  static const double _cellHeight = 90;
  static const double _rowGap = ColdSpace.md;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (pages, headers) = _paginate(widget.apps, widget.headerFor);

    return Column(
      children: [
        Expanded(
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (i) => setState(() => _page = i),
            itemCount: pages.length,
            itemBuilder: (context, i) => Column(
              children: [
                ?headers[i],
                Expanded(
                  child: _Page(
                    apps: pages[i],
                    labelFor: widget.labelFor,
                    onOpen: widget.onOpen,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (pages.length > 1) _Dots(count: pages.length, current: _page),
      ],
    );
  }

  /// Fills each page in turn, in the order the case arranged the apps, asking
  /// [headerFor] page by page — a page's own capacity depends on whether it
  /// turns out to carry a widget, so this cannot be decided all at once ahead
  /// of time. An app never moves page because of something on a later one —
  /// the owner's arrangement is the arrangement.
  static (List<List<ColdApp>>, List<Widget?>) _paginate(
    List<ColdApp> apps,
    Widget? Function(int page) headerFor,
  ) {
    final pages = <List<ColdApp>>[];
    final headers = <Widget?>[];
    var index = 0;
    var page = 0;
    do {
      final header = headerFor(page);
      headers.add(header);
      final capacity =
          (header == null ? kAppPagerRowsPerPage : kAppPagerRowsWithHeader) *
          kAppPagerColumns;
      final end = (index + capacity).clamp(0, apps.length);
      pages.add(apps.sublist(index, end));
      index = end;
      page++;
    } while (index < apps.length);
    return (pages, headers);
  }
}

class _Page extends StatelessWidget {
  final List<ColdApp> apps;
  final String Function(ColdApp app) labelFor;
  final ValueChanged<String> onOpen;

  const _Page({
    required this.apps,
    required this.labelFor,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // A home page does not scroll; it turns.
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: ColdSpace.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: kAppPagerColumns,
        mainAxisSpacing: _AppPagerState._rowGap,
        crossAxisSpacing: ColdSpace.sm,
        mainAxisExtent: _AppPagerState._cellHeight,
      ),
      itemCount: apps.length,
      itemBuilder: (context, i) => AppTile(
        app: apps[i],
        label: labelFor(apps[i]),
        onTap: () => onOpen(apps[i].key),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: ColdSpace.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < count; i++)
            AnimatedContainer(
              duration: ColdMotion.quick,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: i == current ? 0.9 : 0.35,
                ),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}
