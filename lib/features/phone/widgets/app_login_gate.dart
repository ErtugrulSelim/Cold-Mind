import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';
import '../../../data/providers/progress_providers.dart';

/// The sign-in an app asks for before it opens.
///
/// A rung of the lock chain: the password is written down somewhere else on the
/// phone — a note, an email, a photograph of a sticky label — and finding it is
/// the puzzle. So the check is real, against the password the case authored.
///
/// **One gate for every app that has one.** The vault grew its own inline login
/// first and Mail never grew one at all, which meant a case whose chain gated
/// Mail had that door standing open. A shared gate is also the only way the two
/// stay agreed on what counts as the right password.
///
/// Signing in is remembered for the case, because the player earned it once.
/// Replaying the case clears it along with everything else.
class AppLoginGate extends ConsumerStatefulWidget {
  /// The case this login belongs to. Progress is per case, so the same app on
  /// another case is locked again.
  final String caseId;

  /// The app's key, both the storage key and what names it on screen.
  final String appKey;

  /// Localization key for the app's name, for "Sign in to …".
  final String appNameKey;

  /// What opens it. Null can never be matched, so an app flagged as needing a
  /// login with no password authored stays shut rather than falling open.
  final String? expected;

  /// The case's own nudge about where the password is written down. The chain
  /// must never dead-end: when a password exists only inside a photograph the
  /// player cannot read, this is the way through.
  final String? hintKey;

  final CaseStrings? strings;

  /// The app itself, once the player is in.
  final Widget child;

  const AppLoginGate({
    super.key,
    required this.caseId,
    required this.appKey,
    required this.appNameKey,
    required this.expected,
    required this.hintKey,
    required this.strings,
    required this.child,
  });

  @override
  ConsumerState<AppLoginGate> createState() => _AppLoginGateState();
}

class _AppLoginGateState extends ConsumerState<AppLoginGate> {
  final TextEditingController _password = TextEditingController();
  bool _wrong = false;
  bool _showHint = false;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final expected = widget.expected;
    // Case and surrounding space are forgiven; the password itself is not. A
    // player who read "rand-halo-2019" off a note should not fail on the
    // capital their keyboard added.
    if (expected == null ||
        _password.text.trim().toLowerCase() != expected.toLowerCase()) {
      setState(() => _wrong = true);
      return;
    }
    await ref
        .read(caseProgressProvider(widget.caseId).notifier)
        .unlockApp(widget.appKey);
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = ref
        .watch(caseProgressProvider(widget.caseId))
        .unlockedApps
        .contains(widget.appKey);

    if (unlocked) return widget.child;

    final device = context.device;
    final strings = widget.strings;
    final appName = strings?.c(widget.appNameKey) ?? widget.appKey;

    return Scaffold(
      backgroundColor: device.background,
      appBar: AppBar(title: Text(appName)),
      body: ListView(
        padding: const EdgeInsets.all(ColdSpace.lg),
        children: [
          const SizedBox(height: ColdSpace.xl),
          Icon(Icons.lock_outline_rounded, size: 42, color: device.accent),
          const SizedBox(height: ColdSpace.lg),
          Text(
            strings?.cp('ui.login.title', {'app': appName}) ??
                'Sign in to $appName',
            textAlign: TextAlign.center,
            style: ColdType.title.copyWith(color: device.textPrimary),
          ),
          const SizedBox(height: ColdSpace.xl),
          TextField(
            controller: _password,
            autofocus: true,
            onSubmitted: (_) => _submit(),
            onChanged: (_) {
              if (_wrong) setState(() => _wrong = false);
            },
            style: ColdType.body.copyWith(color: device.textPrimary),
            decoration: InputDecoration(
              hintText: strings?.c('ui.login.password') ?? 'Password',
              errorText: _wrong
                  ? (strings?.c('ui.login.wrong') ??
                        'Incorrect password. Try again.')
                  : null,
            ),
          ),
          const SizedBox(height: ColdSpace.lg),
          FilledButton(
            onPressed: _submit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: ColdSpace.md),
              shape: const RoundedRectangleBorder(
                borderRadius: ColdRadius.card,
              ),
            ),
            child: Text(strings?.c('ui.login.button') ?? 'Log In'),
          ),
          if (widget.hintKey != null) ...[
            const SizedBox(height: ColdSpace.md),
            TextButton(
              onPressed: () => setState(() => _showHint = !_showHint),
              child: Text(
                strings?.c('ui.login.forgot') ?? 'Forgot password?',
                style: TextStyle(color: device.textSecondary),
              ),
            ),
            if (_showHint)
              Container(
                padding: const EdgeInsets.all(ColdSpace.md),
                decoration: BoxDecoration(
                  color: device.surfaceRaised,
                  borderRadius: ColdRadius.card,
                ),
                child: Text(
                  strings?.t(widget.hintKey!) ?? '',
                  style: ColdType.bodySmall.copyWith(
                    color: device.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
