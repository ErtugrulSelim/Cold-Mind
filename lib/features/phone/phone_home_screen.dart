import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/models/case_file.dart';
import '../../data/providers/case_providers.dart';
import '../../data/models/person.dart';
import 'app_registry.dart';
import 'app_router.dart';
import 'contact_book.dart';
import '../board/board_screen.dart';
import '../quiz/question_screen.dart';
import '../paywall/pro_button.dart';
import '../settings/settings_screen.dart';
import 'widgets/app_pager.dart';
import 'widgets/app_tile.dart';
import 'widgets/home_widgets.dart';
import 'widgets/phone_status_bar.dart';

/// The subject's home screen.
///
/// What is on it is decided entirely by the case: a key in `CaseFile.apps` means
/// the app is installed, and `home.grid` / `home.dock` only say where it sits.
/// That is what lets a phone characterise whoever carried it — an eighteen year
/// old with no corporate access console, someone who has never travelled with no
/// booking app, a person with two hundred followers and no posts who still has
/// the feed installed, because that *is* the characterisation.
///
/// It is built to be believed. The wallpaper is the owner's, the widgets show
/// their photographs and their calendar, and the icons are real. A player who
/// does not accept that this is somebody's actual phone reads what is on it as
/// puzzle pieces instead of as a life.
class PhoneHomeScreen extends ConsumerWidget {
  final String caseId;
  final CaseFile file;
  final VoidCallback onLeave;

  const PhoneHomeScreen({
    super.key,
    required this.caseId,
    required this.file,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = context.device;
    final strings = ref.watch(caseStringsProvider(caseId)).value;
    final people =
        ref.watch(peopleProvider(caseId)).value ?? const PeoplePool();
    final contacts = ContactBook(file: file, people: people, strings: strings);

    // The player's own controls: the way into settings, the subscription, the
    // questions and the board. They live on the phone because that is where
    // the player spends the session.
    final chrome = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Chrome(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          ),
          child: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: 21,
          ),
        ),
        const SizedBox(width: ColdSpace.sm),
        // The same filled pill the deck carries. It shares this row with the
        // clock and the live indicator, so it was drawn small and outlined to
        // stay out of the way — which made the one thing on the screen asking
        // for money the least visible thing on it.
        ProButton(strings: strings, source: 'phone_home', large: true),
      ],
    );

    final deskButtons = _DeskButtons(
      casesLabel: strings?.c('ui.phone.cases') ?? 'Cases',
      onCases: onLeave,
      questionsLabel: strings?.c('ui.phone.questions') ?? 'Questions',
      boardLabel: strings?.c('board.title') ?? 'Board',
      onQuestions: () => _open(context, 'questions', contacts, strings),
      onBoard: file.board == null
          ? null
          : () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BoardScreen(caseId: caseId, board: file.board!),
              ),
            ),
    );

    final wallpaper = file.device.wallpaperAsset;

    return Scaffold(
      backgroundColor: device.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          if (wallpaper != null)
            Image.asset(
              wallpaper,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => ColoredBox(color: device.background),
            ),
          // Only enough shading at the very top and bottom to keep the status
          // row and the dock readable. A scrim over the whole wallpaper is what
          // made the first version look like a menu with a picture behind it
          // rather than a phone.
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x66000000),
                  Color(0x00000000),
                  Color(0x59000000),
                ],
                stops: [0, 0.28, 1],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                PhoneStatusBar(
                  liveLabel: strings?.c('ui.live') ?? 'LIVE',
                  leading: chrome,
                ),
                Expanded(
                  child: AppPager(
                    apps: gridAppsFor(file),
                    // Never the raw key as a fallback: the keys are the
                    // internal ones and a pack that failed to load would put
                    // them on screen.
                    labelFor: (app) => strings?.c(app.nameKey) ?? '',
                    onOpen: (key) => _open(context, key, contacts, strings),
                    // Which pages carry widgets, and what is in them, is the
                    // case's own arrangement — a real home screen's second
                    // page can have its own just as easily as the first.
                    headerFor: (page) {
                      final widgets = homeWidgetsFor(file, strings, page: page);
                      if (widgets.isEmpty) return null;
                      return HomeWidgetRow(
                        widgets: widgets,
                        onOpen: (key) => _open(context, key, contacts, strings),
                      );
                    },
                  ),
                ),
                deskButtons,
                const SizedBox(height: ColdSpace.md),
                if (dockAppsFor(file).isNotEmpty)
                  _Dock(
                    apps: dockAppsFor(file),
                    onOpen: (key) => _open(context, key, contacts, strings),
                  ),
                const SizedBox(height: ColdSpace.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _open(
    BuildContext context,
    String appKey,
    ContactBook contacts,
    CaseStrings? strings,
  ) {
    // Not an app, and not a screen either: the client interrupts the player on
    // the phone they are holding. A transparent route keeps the device behind
    // the card, so checking something is a dismiss rather than a journey.
    if (appKey == 'questions') {
      Navigator.of(context).push(
        PageRouteBuilder<void>(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: ColdMotion.quick,
          pageBuilder: (_, animation, _) => FadeTransition(
            opacity: animation,
            child: QuestionScreen(
              caseId: caseId,
              file: file,
              contacts: contacts,
            ),
          ),
        ),
      );
      return;
    }

    final screen = buildAppScreen(
      appKey: appKey,
      file: file,
      contacts: contacts,
      strings: strings,
    );
    if (screen != null) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => screen));
      return;
    }
    // App surfaces are built one at a time; until a key has one, saying so is
    // better than opening an empty screen.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$appKey — not built yet'),
        duration: ColdMotion.settle,
      ),
    );
  }
}

/// Installed apps that reach the grid, in the order the case arranges them.
/// Anything installed but unplaced falls in afterwards in the registry's own
/// order, so adding data for an app a case forgot to place still shows it. The
/// dock's own apps never appear here — they are a separate shelf, not a
/// highlight within the grid.
///
/// Public, rather than private to [PhoneHomeScreen]: how many of these end up
/// on one page is exactly what decides whether a page two exists at all, and
/// that arithmetic has to be checked against the same list the screen itself
/// paginates — a count taken from `file.apps` directly once overstated every
/// case by however many apps its dock carried.
List<ColdApp> gridAppsFor(CaseFile file) {
  final docked = file.home.dock.toSet();
  final placed = [
    for (final key in file.home.grid)
      if (!docked.contains(key)) ?coldAppFor(key),
  ];
  final placedKeys = {for (final a in placed) a.key};
  final rest = [
    for (final app in coldApps)
      if (file.hasApp(app.key) &&
          !placedKeys.contains(app.key) &&
          !docked.contains(app.key))
        app,
  ];
  return [...placed, ...rest];
}

/// The shelf along the bottom.
List<ColdApp> dockAppsFor(CaseFile file) => [
  for (final key in file.home.dock) ?coldAppFor(key),
];

/// The shelf along the bottom. Docked apps are not repeated in the grid — the
/// dock is a separate place, not a highlight.
class _Dock extends StatelessWidget {
  final List<ColdApp> apps;
  final ValueChanged<String> onOpen;

  const _Dock({required this.apps, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    // No panel behind it. A frosted tray was the phone drawing a box around
    // its own dock, and against a photograph it reads as a control bar the
    // player might belong to. The icons sit straight on the wallpaper, the way
    // the grid above them does.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ColdSpace.xl),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final app in apps)
            AppTile(app: app, label: null, onTap: () => onOpen(app.key)),
        ],
      ),
    );
  }
}

/// The three places the player goes that are not on the phone: back to the
/// case list, to the questions, and to the board.
///
/// They live down here together because they are the same kind of thing — the
/// player's own side of the case, reached from the device without leaving it.
/// **Icons only.** Labelled, they read as a toolbar the phone is showing; bare,
/// they read as the frame around it, which is what they are. Each still carries
/// its name as a tooltip, so nothing is lost to a screen reader.
class _DeskButtons extends StatelessWidget {
  final String casesLabel;
  final String questionsLabel;
  final String boardLabel;
  final VoidCallback onCases;
  final VoidCallback onQuestions;

  /// Null when the case pinned no board, and then that button is not drawn.
  final VoidCallback? onBoard;

  const _DeskButtons({
    required this.casesLabel,
    required this.questionsLabel,
    required this.boardLabel,
    required this.onCases,
    required this.onQuestions,
    required this.onBoard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: ColdSpace.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Leaving the case sits with the other two rather than in the status
          // bar: the bar is the phone's own chrome, and stepping off the device
          // is not something the device offers.
          _DeskButton(
            asset: 'assets/desk/cases.png',
            icon: Icons.folder_outlined,
            label: casesLabel,
            onTap: onCases,
          ),
          const SizedBox(width: ColdSpace.md),
          _DeskButton(
            asset: 'assets/desk/questions.png',
            icon: Icons.help_outline_rounded,
            label: questionsLabel,
            onTap: onQuestions,
          ),
          if (onBoard case final open?) ...[
            const SizedBox(width: ColdSpace.md),
            _DeskButton(
              asset: 'assets/desk/board.png',
              icon: Icons.push_pin_outlined,
              label: boardLabel,
              onTap: open,
            ),
          ],
        ],
      ),
    );
  }
}

/// One round button. [label] is the tooltip, never drawn.
///
/// A brass badge rather than another tinted circle. These three are the only
/// things on this screen that are not the subject's — and they used to be
/// painted in the *device* accent, which put the player's own controls in the
/// phone's colour and made them read as three more apps. Warm metal against
/// the cold tiles says whose they are before anything is tapped.
class _DeskButton extends StatelessWidget {
  final String asset;

  /// Drawn if the badge cannot load, so the control is never a blank disc.
  final IconData icon;

  final String label;
  final VoidCallback onTap;

  const _DeskButton({
    required this.asset,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;
    const size = 52.0;

    return Tooltip(
      message: label,
      child: Material(
        color: device.accentDim.withValues(alpha: 0.92),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: size,
            height: size,
            child: Image.asset(
              asset,
              fit: BoxFit.cover,
              cacheWidth: (size * 3).round(),
              errorBuilder: (_, _, _) =>
                  Icon(icon, color: Colors.white, size: 23),
            ),
          ),
        ),
      ),
    );
  }
}

/// The frame the player's own controls are drawn in on the phone.
///
/// A dark pill, because these sit on somebody's wallpaper: a bare icon
/// disappears against whatever photograph the case chose, and a light chip
/// would read as something the phone itself is showing.
class _Chrome extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _Chrome({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // A flat tint over the wallpaper read as a sticker rather than a control
    // floating on the glass — a real blur behind it lets whatever is moving
    // underneath (the wallpaper, a scrolling photo) still show through.
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: Colors.black.withValues(alpha: 0.32),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            // Sized to the pill beside it, so the two read as one control
            // strip rather than a button and an afterthought.
            child: SizedBox(width: 40, height: 40, child: Center(child: child)),
          ),
        ),
      ),
    );
  }
}
