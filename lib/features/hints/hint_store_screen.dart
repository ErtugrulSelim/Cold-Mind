import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/cold_theme.dart';
import '../../data/l10n/case_strings.dart';
import '../../data/providers/case_providers.dart';
import '../../data/providers/hint_providers.dart';
import '../paywall/store.dart';
import 'hint_store.dart';

/// Where a player buys more hint tokens.
///
/// A separate screen from [PaywallScreen] on purpose: buying a subscription
/// is a single either/or choice with two plans, but a hint shop is several
/// packs at different sizes — a list, not a pair of cards — and nothing
/// here is a recurring commitment the way a subscription is, so "Cancel
/// Anytime" and a restore button would both be meaningless here.
class HintStoreScreen extends ConsumerStatefulWidget {
  /// Where the player was when this opened. Same idea as `PaywallScreen`'s
  /// `source` — not analytics, just something a caller usually knows and a
  /// screen it opens can record having been told.
  final String source;

  const HintStoreScreen({super.key, this.source = 'unknown'});

  @override
  ConsumerState<HintStoreScreen> createState() => _HintStoreScreenState();
}

class _HintStoreScreenState extends ConsumerState<HintStoreScreen> {
  bool _working = false;
  String? _workingPackageId;
  StoreFailure? _failure;

  Future<void> _buy(HintPackage pack) async {
    setState(() {
      _working = true;
      _workingPackageId = pack.id;
      _failure = null;
    });
    try {
      final granted = await ref.read(hintStoreProvider).purchase(pack.id);
      if (granted) {
        ref.invalidate(hintBalanceProvider);
      }
    } on StoreException catch (error) {
      if (mounted) setState(() => _failure = error.failure);
    } catch (_) {
      if (mounted) setState(() => _failure = StoreFailure.other);
    } finally {
      if (mounted) {
        setState(() {
          _working = false;
          _workingPackageId = null;
        });
      }
    }
  }

  String _failureText(StoreFailure failure, CaseStrings? strings) {
    final key = switch (failure) {
      StoreFailure.network => 'hints.err_network',
      StoreFailure.notAllowed => 'hints.err_not_allowed',
      StoreFailure.unavailable => 'hints.err_unavailable',
      StoreFailure.nothingToRestore => 'hints.err_generic',
      StoreFailure.other => 'hints.err_generic',
    };
    return strings?.c(key) ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;
    final strings = ref.watch(commonStringsProvider).value;
    final balance = ref.watch(hintBalanceProvider);
    final packages = ref.watch(hintPackagesProvider);

    return Scaffold(
      backgroundColor: desk.corkDark,
      appBar: AppBar(
        backgroundColor: desk.corkDark,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
          color: desk.paper,
        ),
        centerTitle: false,
        title: Text(
          strings?.c('hints.title') ?? 'Get Hints',
          style: ColdType.subtitle.copyWith(color: desk.paper),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            ColdSpace.lg,
            0,
            ColdSpace.lg,
            ColdSpace.xl,
          ),
          children: [
            _BalanceCard(
              label: strings?.c('hints.balance') ?? 'Your hints',
              balance: balance,
            ),
            const SizedBox(height: ColdSpace.md),
            Text(
              strings?.c('hints.subtitle') ?? '',
              style: ColdType.bodySmall.copyWith(
                color: desk.paper.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: ColdSpace.lg),
            if (_failure case final failure?) ...[
              Text(
                _failureText(failure, strings),
                textAlign: TextAlign.center,
                style: ColdType.bodySmall.copyWith(color: desk.string),
              ),
              const SizedBox(height: ColdSpace.md),
            ],
            packages.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(ColdSpace.lg),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, _) => Center(
                child: Text(
                  strings?.c('hints.empty') ?? 'No hint packs available right now.',
                  style: ColdType.bodySmall.copyWith(
                    color: desk.paper.withValues(alpha: 0.5),
                  ),
                ),
              ),
              data: (list) {
                if (list.isEmpty) {
                  return Center(
                    child: Text(
                      strings?.c('hints.empty') ??
                          'No hint packs available right now.',
                      style: ColdType.bodySmall.copyWith(
                        color: desk.paper.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (final pack in list) ...[
                      _PackCard(
                        pack: pack,
                        buyLabel: strings?.c('hints.buy') ?? 'Buy',
                        busy: _working && _workingPackageId == pack.id,
                        onTap: _working ? null : () => _buy(pack),
                      ),
                      if (pack != list.last) const SizedBox(height: ColdSpace.sm),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final String label;
  final AsyncValue<int> balance;

  const _BalanceCard({required this.label, required this.balance});

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ColdSpace.lg,
        vertical: ColdSpace.md,
      ),
      decoration: BoxDecoration(
        color: desk.paper.withValues(alpha: 0.06),
        borderRadius: ColdRadius.card,
        border: Border.all(color: desk.paper.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(Icons.lightbulb_rounded, color: desk.highlight, size: 22),
          const SizedBox(width: ColdSpace.sm),
          Expanded(
            child: Text(
              label,
              style: ColdType.body.copyWith(
                color: desk.paper.withValues(alpha: 0.8),
              ),
            ),
          ),
          balance.when(
            loading: () => SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: desk.paper.withValues(alpha: 0.5),
              ),
            ),
            error: (_, _) => Text('0', style: ColdType.title.copyWith(color: desk.paper)),
            data: (value) => Text(
              '$value',
              style: ColdType.title.copyWith(color: desk.paper),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackCard extends StatelessWidget {
  final HintPackage pack;
  final String buyLabel;
  final bool busy;
  final VoidCallback? onTap;

  const _PackCard({
    required this.pack,
    required this.buyLabel,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final desk = context.desk;

    return Material(
      color: desk.paper.withValues(alpha: 0.04),
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
            border: Border.all(color: desk.paper.withValues(alpha: 0.14)),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, color: desk.highlight, size: 20),
              const SizedBox(width: ColdSpace.md),
              Expanded(
                child: Text(
                  '${pack.amount}',
                  style: ColdType.title.copyWith(color: desk.paper, fontSize: 18),
                ),
              ),
              SizedBox(
                height: 34,
                child: FilledButton(
                  onPressed: onTap,
                  style: FilledButton.styleFrom(
                    backgroundColor: desk.paper,
                    foregroundColor: desk.ink,
                    disabledBackgroundColor: desk.paper.withValues(alpha: 0.35),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                    ),
                  ),
                  child: busy
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: desk.ink,
                          ),
                        )
                      : Text(
                          pack.priceLabel ?? buyLabel,
                          style: ColdType.label.copyWith(fontSize: 13),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
