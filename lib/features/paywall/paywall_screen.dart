import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/settings_providers.dart';
import 'store.dart';

/// The subscription screen.
///
/// Pops `true` when access was bought or restored, `false` on every other way
/// out — so a caller can gate on the result without having to ask the store
/// again.
///
/// Laid out the way the previous build's was, because that layout was tuned
/// against real installs: the picture holds the top, the promise and what it
/// buys sit under it, and the plans, the button and the legal line stack on a
/// solid block at the bottom where nothing competes with them. What changed is
/// underneath — the store lives behind [Store] instead of being called from
/// inside the widget, which is what made the old screen impossible to open
/// without live billing credentials.
class PaywallScreen extends ConsumerStatefulWidget {
  /// Where the player was when this opened. Not analytics — the screen has
  /// none — but the caller usually knows, and a gate that opens the paywall
  /// wants to say so.
  final String source;

  const PaywallScreen({super.key, this.source = 'unknown'});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  static const String _background = 'assets/paywall/paywall_bg.jpg';

  List<StorePlan> _plans = const [];
  String? _selected;

  bool _loading = true;
  bool _working = false;
  StoreFailure? _failure;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _failure = null;
    });
    try {
      final plans = await ref.read(storeProvider).plans();
      if (!mounted) return;
      setState(() {
        _plans = plans;
        _selected = plans
            .firstWhere((p) => p.recommended, orElse: () => plans.first)
            .id;
      });
    } on StoreException catch (error) {
      if (mounted) setState(() => _failure = error.failure);
    } catch (_) {
      if (mounted) setState(() => _failure = StoreFailure.other);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _run(Future<bool> Function() action) async {
    setState(() {
      _working = true;
      _failure = null;
    });
    try {
      final granted = await action();
      if (!mounted) return;
      // False is a cancellation, not a failure: the player closed the store
      // sheet, and telling them something went wrong would be a lie.
      if (granted) {
        // Persisted here rather than re-derived from the store on every
        // launch, because [UnconfiguredStore] has no notion of "already
        // owns this" to ask — the moment of purchase is the only moment
        // this app ever learns the answer.
        await ref.read(isSubscribedProvider.notifier).grant();
        if (!mounted) return;
        Navigator.of(context).pop(true);
      }
    } on StoreException catch (error) {
      if (mounted) setState(() => _failure = error.failure);
    } catch (_) {
      if (mounted) setState(() => _failure = StoreFailure.other);
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final strings = ref.watch(commonStringsProvider).value;
    final store = ref.read(storeProvider);

    return PopScope(
      // Not while the store has the purchase in hand: leaving mid-transaction
      // is how a player ends up charged for something the app never applied.
      canPop: !_working,
      child: Scaffold(
        backgroundColor: desk.corkDark,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Top-aligned and nudged up, so the subject sits high and the gap
            // it leaves at the bottom falls inside the solid block below.
            FractionalTranslation(
              translation: const Offset(0, -0.15),
              child: Image.asset(
                _background,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            // One gradient doing two jobs: the picture stays clear down to
            // about halfway, then goes solid before the plans start, so the
            // cards and the button never sit on top of somebody's photograph.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    desk.corkDark.withValues(alpha: 0),
                    desk.corkDark.withValues(alpha: 0),
                    desk.corkDark.withValues(alpha: 0.55),
                    desk.corkDark,
                    desk.corkDark,
                  ],
                  stops: const [0, 0.4, 0.55, 0.68, 1],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    restoreLabel: strings?.c('paywall.restore') ?? 'Restore',
                    busy: _working,
                    onClose: () => Navigator.of(context).pop(false),
                    onRestore: () => _run(store.restore),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      ColdSpace.xl,
                      0,
                      ColdSpace.xl,
                      ColdSpace.md,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          strings?.c('paywall.title') ?? 'Get Unlimited Access',
                          style: ColdType.display.copyWith(
                            fontSize: 28,
                            color: desk.paper,
                            shadows: const [
                              Shadow(color: Colors.black54, blurRadius: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: ColdSpace.lg),
                        for (var i = 1; i <= 5; i++)
                          _Feature(text: strings?.c('paywall.feature$i') ?? ''),
                        const SizedBox(height: ColdSpace.lg),
                        ..._plansOrState(strings),
                        const SizedBox(height: ColdSpace.md),
                        Center(
                          child: Text(
                            strings?.c('paywall.cancel_anytime') ??
                                'Cancel Anytime',
                            style: ColdType.micro.copyWith(
                              color: desk.paper.withValues(alpha: 0.45),
                            ),
                          ),
                        ),
                        if (_failure case final failure?) ...[
                          const SizedBox(height: ColdSpace.sm),
                          Text(
                            _failureText(failure, strings),
                            textAlign: TextAlign.center,
                            style: ColdType.bodySmall.copyWith(
                              color: desk.string,
                            ),
                          ),
                        ],
                        const SizedBox(height: ColdSpace.md),
                        _Continue(
                          label: strings?.c('paywall.continue') ?? 'CONTINUE',
                          busy: _working,
                          onTap: _loading || _selected == null
                              ? null
                              : () => _run(() => store.purchase(_selected!)),
                        ),
                        const SizedBox(height: ColdSpace.sm),
                        _LegalLine(strings: strings),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// The plan cards, or whatever stands in for them while there are none.
  List<Widget> _plansOrState(CaseStrings? strings) {
    if (_loading) {
      return const [
        Center(
          child: Padding(
            padding: EdgeInsets.all(ColdSpace.lg),
            child: CircularProgressIndicator(),
          ),
        ),
      ];
    }
    if (_plans.isEmpty) return const [];

    return [
      for (final plan in _plans) ...[
        _PlanCard(
          title: strings?.c(plan.titleKey) ?? plan.titleKey,
          price: plan.priceLabel,
          perWeek: plan.perWeekLabel,
          perWeekLabel: strings?.c('paywall.per_week') ?? 'per week',
          badge: plan.recommended
              ? (strings?.c('paywall.best_offer') ?? 'BEST OFFER')
              : null,
          selected: plan.id == _selected,
          onTap: _working ? null : () => setState(() => _selected = plan.id),
        ),
        if (plan != _plans.last) const SizedBox(height: ColdSpace.sm),
      ],
    ];
  }

  String _failureText(StoreFailure failure, CaseStrings? strings) {
    final key = switch (failure) {
      StoreFailure.network => 'paywall.err_network',
      StoreFailure.notAllowed => 'paywall.err_not_allowed',
      StoreFailure.unavailable => 'paywall.err_unavailable',
      StoreFailure.nothingToRestore => 'paywall.err_restore_none',
      StoreFailure.other => 'paywall.err_generic',
    };
    return strings?.c(key) ?? '';
  }
}

/// Close on the left, restore on the right — where a store screen puts them.
class _TopBar extends StatelessWidget {
  final String restoreLabel;
  final bool busy;
  final VoidCallback onClose;
  final VoidCallback onRestore;

  const _TopBar({
    required this.restoreLabel,
    required this.busy,
    required this.onClose,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: busy ? null : onClose,
          icon: const Icon(Icons.close_rounded, size: 24),
          color: desk.paper.withValues(alpha: 0.7),
        ),
        TextButton(
          onPressed: busy ? null : onRestore,
          child: Text(
            restoreLabel,
            style: ColdType.label.copyWith(
              color: desk.paper.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}

/// One line of what the subscription buys.
class _Feature extends StatelessWidget {
  final String text;

  const _Feature({required this.text});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_rounded, size: 17, color: desk.highlight),
          const SizedBox(width: ColdSpace.sm),
          Expanded(
            child: Text(
              text,
              style: ColdType.body.copyWith(
                color: desk.paper.withValues(alpha: 0.92),
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One purchasable plan.
class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String? perWeek;
  final String perWeekLabel;
  final String? badge;
  final bool selected;
  final VoidCallback? onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.perWeek,
    required this.perWeekLabel,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Material(
      color: desk.paper.withValues(alpha: selected ? 0.10 : 0.04),
      borderRadius: ColdRadius.card,
      child: InkWell(
        onTap: onTap,
        borderRadius: ColdRadius.card,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: ColdSpace.md,
            vertical: ColdSpace.md,
          ),
          decoration: BoxDecoration(
            borderRadius: ColdRadius.card,
            border: Border.all(
              color: selected
                  ? desk.highlight
                  : desk.paper.withValues(alpha: 0.14),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              _Radio(selected: selected),
              const SizedBox(width: ColdSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ColdType.subtitle.copyWith(
                              color: desk.paper,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (badge case final text?) ...[
                          const SizedBox(width: ColdSpace.sm),
                          _Badge(text: text),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      price,
                      style: ColdType.meta.copyWith(
                        color: desk.paper.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: ColdSpace.sm),
              // The per-week figure is what the two plans can actually be
              // compared on, so it is the number set large.
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    perWeek ?? price,
                    style: ColdType.title.copyWith(
                      fontSize: 19,
                      color: desk.paper,
                    ),
                  ),
                  Text(
                    perWeekLabel,
                    style: ColdType.micro.copyWith(
                      color: desk.paper.withValues(alpha: 0.45),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Radio extends StatelessWidget {
  final bool selected;

  const _Radio({required this.selected});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? desk.highlight : desk.paper.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: desk.highlight,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: desk.highlight,
        borderRadius: const BorderRadius.all(Radius.circular(999)),
      ),
      child: Text(text, style: ColdType.micro.copyWith(color: desk.ink)),
    );
  }
}

/// The one button on the screen that costs money, drawn like it.
class _Continue extends StatelessWidget {
  final String label;
  final bool busy;
  final VoidCallback? onTap;

  const _Continue({
    required this.label,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: busy ? null : onTap,
        style: FilledButton.styleFrom(
          backgroundColor: desk.paper,
          foregroundColor: desk.ink,
          disabledBackgroundColor: desk.paper.withValues(alpha: 0.35),
          shape: const RoundedRectangleBorder(borderRadius: ColdRadius.card),
        ),
        child: busy
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: desk.ink,
                ),
              )
            : Text(
                label,
                style: ColdType.label.copyWith(
                  fontSize: 15,
                  letterSpacing: 0.6,
                ),
              ),
      ),
    );
  }
}

/// Terms and privacy. Both stores require them on the screen that sells.
class _LegalLine extends StatelessWidget {
  final CaseStrings? strings;

  const _LegalLine({required this.strings});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final style = ColdType.micro.copyWith(
      color: desk.paper.withValues(alpha: 0.4),
      letterSpacing: 0.2,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(strings?.c('settings.terms') ?? 'Terms of Use', style: style),
        Text('  ·  ', style: style),
        Text(strings?.c('settings.privacy') ?? 'Privacy Policy', style: style),
      ],
    );
  }
}
