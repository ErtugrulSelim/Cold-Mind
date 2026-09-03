import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_config.dart';
import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/settings_providers.dart';
import '../paywall/paywall_screen.dart';
import '../paywall/store.dart';

/// The player's own settings.
///
/// Grouped cards on a dark ground, one section per kind of thing — how the game
/// plays, what language it speaks, where to get help, what it is. The grouping
/// is the design: a flat list of switches is a control panel, and this is meant
/// to be read once and left alone.
///
/// **Rows that lead nowhere are not drawn.** The store links and the legal
/// pages have no destinations yet, and a row that does nothing when tapped
/// reads as broken rather than as unfinished — so each one appears the moment
/// its URL is filled in, in [AppConfig], and not before. The exceptions are the
/// two the store itself answers for: Restore says what the store said, and
/// Rate Us on iOS says it is not published yet, because both of those are
/// states a real user can reach on a shipped build.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = context.device;
    final strings = ref.watch(commonStringsProvider).value;
    final selected = ref.watch(languageProvider);
    final language = supportedLanguages.firstWhere(
      (l) => l.code == selected,
      orElse: () => supportedLanguages.first,
    );

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        backgroundColor: device.background,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: device.textPrimary,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          ColdSpace.lg,
          0,
          ColdSpace.lg,
          ColdSpace.xxl,
        ),
        children: [
          _ProCard(strings: strings),
          const SizedBox(height: ColdSpace.xl),
          _SectionHeader(text: strings?.c('settings.gameplay') ?? 'GAMEPLAY'),
          _Group(children: [_HintRow(strings: strings)]),
          const SizedBox(height: ColdSpace.xl),
          _SectionHeader(
            text: strings?.c('settings.language_header') ?? 'LANGUAGE',
          ),
          _Group(
            children: [
              _Row(
                icon: Icons.language_rounded,
                label: strings?.c('settings.language') ?? 'Language',
                // The language's own name, never translated: somebody looking
                // for their language is looking for the word they know it by.
                value: language.nativeName,
                onTap: () => _pickLanguage(context, ref, selected),
              ),
            ],
          ),
          const SizedBox(height: ColdSpace.xl),
          _SectionHeader(text: strings?.c('settings.support') ?? 'SUPPORT'),
          _Group(
            children: [
              _Row(
                icon: Icons.help_outline_rounded,
                label: strings?.c('settings.faq') ?? 'FAQ',
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const _FaqScreen()),
                ),
              ),
              _Row(
                icon: Icons.shopping_bag_outlined,
                label: strings?.c('settings.restore') ?? 'Restore Purchase',
                chevron: false,
                onTap: () => _restore(context, ref, strings),
              ),
            ],
          ),
          const SizedBox(height: ColdSpace.xl),
          _SectionHeader(text: strings?.c('settings.about') ?? 'ABOUT'),
          _Group(
            children: [
              _Row(
                icon: Icons.star_outline_rounded,
                label: strings?.c('settings.rate') ?? 'Rate Us',
                chevron: false,
                onTap: () => _rate(context, strings),
              ),
              if (AppConfig.hasDownloadLink)
                _Row(
                  icon: Icons.ios_share_rounded,
                  label:
                      strings?.c('settings.send_link') ??
                      'Send App Download Link',
                  chevron: false,
                  onTap: () => _share(strings),
                ),
              if (AppConfig.hasTerms)
                _Row(
                  icon: Icons.description_outlined,
                  label: strings?.c('settings.terms') ?? 'Terms of Use',
                  onTap: () => _open(context, AppConfig.termsUrl, strings),
                ),
              if (AppConfig.hasPrivacy)
                _Row(
                  icon: Icons.verified_user_outlined,
                  label: strings?.c('settings.privacy') ?? 'Privacy Policy',
                  onTap: () => _open(context, AppConfig.privacyUrl, strings),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Asks the store to hand back a subscription bought on another device or
  /// before a reinstall.
  ///
  /// It reports through the same messages the paywall does, because it is the
  /// same operation reached from a different door, and a player who restores
  /// here should not be told something different from one who restores there.
  /// Nothing is granted quietly: with no billing wired in the store throws,
  /// and that reaches the player as a message rather than as silence.
  Future<void> _restore(
    BuildContext context,
    WidgetRef ref,
    CaseStrings? strings,
  ) async {
    String message;
    try {
      final restored = await ref.read(storeProvider).restore();
      message = restored
          ? strings?.c('settings.restored_ok') ?? 'Purchases restored.'
          : strings?.c('settings.restored_none') ??
                'No previous purchases found.';
    } on StoreException catch (error) {
      message = _storeMessage(error.failure, strings);
    } catch (_) {
      message = _storeMessage(StoreFailure.other, strings);
    }

    if (context.mounted) _say(context, message);
  }

  String _storeMessage(StoreFailure failure, CaseStrings? strings) {
    final key = switch (failure) {
      StoreFailure.network => 'paywall.err_network',
      StoreFailure.notAllowed => 'paywall.err_not_allowed',
      StoreFailure.unavailable => 'paywall.err_unavailable',
      StoreFailure.nothingToRestore => 'settings.restored_none',
      StoreFailure.other => 'paywall.err_restore',
    };
    return strings?.c(key) ?? '';
  }

  /// Straight to the store listing — see [AppConfig.openStoreListing] for why
  /// that is the right destination rather than the OS's own review sheet.
  Future<void> _rate(BuildContext context, CaseStrings? strings) async {
    if (await AppConfig.openStoreListing()) return;
    if (context.mounted) {
      _say(
        context,
        strings?.c('settings.rate_unavailable') ??
            'Rating will be available once the app is published.',
      );
    }
  }

  Future<void> _share(CaseStrings? strings) async {
    final text =
        strings?.cp('settings.share_text', {'link': AppConfig.downloadUrl}) ??
        AppConfig.downloadUrl;
    await SharePlus.instance.share(ShareParams(text: text));
  }

  Future<void> _open(
    BuildContext context,
    String url,
    CaseStrings? strings,
  ) async {
    final opened = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      _say(
        context,
        strings?.c('settings.link_error') ?? 'Could not open the link.',
      );
    }
  }

  void _say(BuildContext context, String message) {
    if (message.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _pickLanguage(
    BuildContext context,
    WidgetRef ref,
    String selected,
  ) async {
    final device = context.device;

    final strings = ref.read(commonStringsProvider).value;

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: device.surface,
      shape: const RoundedRectangleBorder(borderRadius: ColdRadius.sheet),
      // Eighteen languages are taller than a default sheet, and a shrink-wrap
      // list inside one does not scroll — it is simply cut off, and the
      // languages at the bottom of the alphabet cannot be chosen at all.
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // A grab handle, because a sheet that scrolls has to look like
              // one that can be dragged away.
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                decoration: BoxDecoration(
                  color: device.textTertiary,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  ColdSpace.lg,
                  ColdSpace.sm,
                  ColdSpace.lg,
                  ColdSpace.sm,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    strings?.c('settings.language') ?? 'Language',
                    style: ColdType.subtitle.copyWith(
                      color: device.textPrimary,
                    ),
                  ),
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: ColdSpace.sm),
                  children: [
                    for (final language in supportedLanguages)
                      ListTile(
                        onTap: () =>
                            Navigator.of(sheetContext).pop(language.code),
                        title: Text(
                          language.nativeName,
                          style: ColdType.body.copyWith(
                            color: language.code == selected
                                ? device.accent
                                : device.textPrimary,
                            fontWeight: language.code == selected
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        trailing: language.code == selected
                            ? Icon(Icons.check_rounded, color: device.accent)
                            : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (picked == null || picked == selected) return;
    await ref.read(languageProvider.notifier).select(picked);

    // Said out loud, because the rest of the change is quiet: the menus around
    // them redraw, but the cases stay in English, and without a word the
    // player is left wondering whether the setting took at all.
    if (context.mounted) {
      _say(context, strings?.c('settings.lang_updated') ?? 'Language updated.');
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String text;

  const _SectionHeader({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: ColdSpace.sm, left: 4),
    child: Text(
      text,
      style: ColdType.label.copyWith(
        color: context.device.textSecondary,
        letterSpacing: 1.2,
      ),
    ),
  );
}

/// A rounded card holding one section's rows.
class _Group extends StatelessWidget {
  final List<Widget> children;

  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Container(
      decoration: BoxDecoration(
        color: device.surface,
        borderRadius: const BorderRadius.all(Radius.circular(ColdRadius.lg)),
        border: Border.all(color: device.hairline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 58, color: device.hairline),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  /// Whether tapping goes somewhere the player can come back from.
  ///
  /// A chevron is a promise about what happens next: another page of this app.
  /// Restore, Rate and Share do not open a page — they do a thing, or hand the
  /// player to another app entirely — so they do not wear one.
  final bool chevron;

  const _Row({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.chevron = true,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ColdSpace.lg,
          vertical: ColdSpace.lg,
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: device.accent),
            const SizedBox(width: ColdSpace.lg),
            Expanded(
              child: Text(
                label,
                style: ColdType.body.copyWith(
                  color: device.textPrimary,
                  fontSize: 16,
                ),
              ),
            ),
            if (value != null)
              Text(
                value!,
                style: ColdType.body.copyWith(color: device.textSecondary),
              ),
            if (chevron) ...[
              const SizedBox(width: ColdSpace.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: device.textTertiary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Whether a stuck player is offered the 50/50.
///
/// The offer is also made in the moment — the third time a question is answered
/// wrong — and the dialog there says it can be changed here, so it has to be.
class _HintRow extends ConsumerWidget {
  final CaseStrings? strings;

  const _HintRow({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Unset counts as off: the offer has not been made yet, and showing it as
    // already on would promise help the player never agreed to.
    final on = ref.watch(hintsProvider) == HintOffer.accepted;

    return _Toggle(
      icon: Icons.lightbulb_outline_rounded,
      title: strings?.c('settings.answer_hints') ?? 'Answer hints',
      subtitle:
          strings?.c('settings.answer_hints_sub') ??
          'Show two options after 3 wrong tries on a question',
      value: on,
      onChanged: (enabled) =>
          ref.read(hintsProvider.notifier).answer(accepted: enabled),
    );
  }
}

class _Toggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _Toggle({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        ColdSpace.lg,
        ColdSpace.md,
        ColdSpace.md,
        ColdSpace.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: device.accent),
          const SizedBox(width: ColdSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: ColdType.body.copyWith(
                    color: device.textPrimary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: ColdType.bodySmall.copyWith(
                    color: device.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Colors.white,
            activeTrackColor: device.accent,
          ),
        ],
      ),
    );
  }
}

/// The questions players actually ask, answered.
///
/// Read by index rather than from a list of keys, so adding a ninth question is
/// a change to the language pack and not to this file.
class _FaqScreen extends ConsumerWidget {
  const _FaqScreen();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = context.device;
    final strings = ref.watch(commonStringsProvider).value;

    final entries = <({String question, String answer})>[];
    for (var i = 1; i <= 12; i++) {
      final question = strings?.c('faq.q$i');
      if (question == null || question == '[faq.q$i]') continue;
      entries.add((question: question, answer: strings?.c('faq.a$i') ?? ''));
    }

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(
        backgroundColor: device.background,
        title: Text(strings?.c('faq.title') ?? 'FAQ'),
      ),
      body: entries.isEmpty
          ? Center(
              child: Text(
                strings?.c('faq.empty') ?? '',
                style: ColdType.body.copyWith(color: device.textTertiary),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(ColdSpace.lg),
              children: [
                for (final entry in entries)
                  Container(
                    margin: const EdgeInsets.only(bottom: ColdSpace.sm),
                    decoration: BoxDecoration(
                      color: device.surface,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(ColdRadius.lg),
                      ),
                      border: Border.all(color: device.hairline),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: ExpansionTile(
                      shape: const Border(),
                      collapsedShape: const Border(),
                      iconColor: device.accent,
                      collapsedIconColor: device.textSecondary,
                      title: Text(
                        entry.question,
                        style: ColdType.subtitle.copyWith(
                          color: device.textPrimary,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            ColdSpace.lg,
                            0,
                            ColdSpace.lg,
                            ColdSpace.lg,
                          ),
                          child: Text(
                            entry.answer,
                            style: ColdType.body.copyWith(
                              color: device.textSecondary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// The way into the subscription screen.
///
/// It sits at the top of Settings rather than being buried under a section
/// heading, and it is the only place in the app that opens the paywall — a gate
/// on a locked case can push [PaywallScreen] too, but nothing about the screen
/// assumes it was reached that way.
class _ProCard extends ConsumerWidget {
  final CaseStrings? strings;

  const _ProCard({required this.strings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final device = context.device;

    return Material(
      color: device.surfaceRaised,
      borderRadius: ColdRadius.card,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<bool>(
            builder: (_) => const PaywallScreen(source: 'settings'),
          ),
        ),
        borderRadius: ColdRadius.card,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: ColdRadius.card,
            border: Border.all(color: device.accent.withValues(alpha: 0.35)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                device.accent.withValues(alpha: 0.14),
                device.surfaceRaised,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(ColdSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: device.accent.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.workspace_premium_rounded,
                        size: 20,
                        color: device.accent,
                      ),
                    ),
                    const SizedBox(width: ColdSpace.sm),
                    Expanded(
                      child: Text(
                        strings?.c('settings.pro_title') ??
                            'Unlock all seasons and\nuncover the mysteries.',
                        style: ColdType.subtitle.copyWith(
                          color: device.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: ColdSpace.md),
                Row(
                  children: [
                    // Flexible, because this line is a full sentence in most
                    // of the eighteen languages and the card is 326pt wide on
                    // a 390pt phone. It overflowed by eight pixels in English
                    // — nothing had ever drawn this screen at phone width, so
                    // nothing caught it.
                    Flexible(
                      child: Text(
                        strings?.c('settings.pro_cta') ??
                            'Continue with Pro Access',
                        style: ColdType.label.copyWith(color: device.accent),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: device.accent,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
