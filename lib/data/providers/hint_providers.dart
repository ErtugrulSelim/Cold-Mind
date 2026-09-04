import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/hints/hint_store.dart';

part 'hint_providers.g.dart';

/// The player's current hint-token balance.
///
/// Read fresh from [HintStore.balance] rather than cached locally — the
/// real number lives with RevenueCat (or, on [UnconfiguredHintStore],
/// is always zero), never on this device, so there is nothing here worth
/// persisting between launches. Call `ref.invalidate(hintBalanceProvider)`
/// after a purchase or a spend to pick up the new number.
@riverpod
Future<int> hintBalance(Ref ref) => ref.watch(hintStoreProvider).balance();

/// The packs on offer in the dedicated hints shop.
@riverpod
Future<List<HintPackage>> hintPackages(Ref ref) =>
    ref.watch(hintStoreProvider).packages();
