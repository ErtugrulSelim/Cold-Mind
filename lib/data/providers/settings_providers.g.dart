// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden at startup with the resolved instance, so everything downstream
/// reads preferences synchronously instead of awaiting them per call.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// Overridden at startup with the resolved instance, so everything downstream
/// reads preferences synchronously instead of awaiting them per call.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// Overridden at startup with the resolved instance, so everything downstream
  /// reads preferences synchronously instead of awaiting them per call.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'486f34d0d57968a0ee8c28eb9a1bac80ebb13bc1';

/// The selected UI language, persisted across launches.

@ProviderFor(Language)
final languageProvider = LanguageProvider._();

/// The selected UI language, persisted across launches.
final class LanguageProvider extends $NotifierProvider<Language, String> {
  /// The selected UI language, persisted across launches.
  LanguageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'languageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$languageHash();

  @$internal
  @override
  Language create() => Language();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$languageHash() => r'89151acf5ad5911e2eebc074bc1e0370134e78ce';

/// The selected UI language, persisted across launches.

abstract class _$Language extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Whether the "do you like the game?" prompt has ever been shown.
///
/// Once, ever, regardless of which case or which answer — a player who said
/// no should not be asked again next case, and a player who said yes has
/// already been sent to the store and does not need a second invitation.

@ProviderFor(RatingPrompted)
final ratingPromptedProvider = RatingPromptedProvider._();

/// Whether the "do you like the game?" prompt has ever been shown.
///
/// Once, ever, regardless of which case or which answer — a player who said
/// no should not be asked again next case, and a player who said yes has
/// already been sent to the store and does not need a second invitation.
final class RatingPromptedProvider
    extends $NotifierProvider<RatingPrompted, bool> {
  /// Whether the "do you like the game?" prompt has ever been shown.
  ///
  /// Once, ever, regardless of which case or which answer — a player who said
  /// no should not be asked again next case, and a player who said yes has
  /// already been sent to the store and does not need a second invitation.
  RatingPromptedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'ratingPromptedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$ratingPromptedHash();

  @$internal
  @override
  RatingPrompted create() => RatingPrompted();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$ratingPromptedHash() => r'a3b1516ced471c1ff6a56f6993ec3bf8dadff87d';

/// Whether the "do you like the game?" prompt has ever been shown.
///
/// Once, ever, regardless of which case or which answer — a player who said
/// no should not be asked again next case, and a player who said yes has
/// already been sent to the store and does not need a second invitation.

abstract class _$RatingPrompted extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Whether this player has ever completed a purchase or a restore.
///
/// [UnconfiguredStore] cannot produce one — it throws rather than returning
/// true — so until a real billing SDK is behind [Store], this stays false for
/// everybody and every case past the first stays gated. That is the correct
/// behaviour for a build with no payment system connected, not a bug in this
/// flag.
///
/// [PaywallScreen] is what sets it true, the moment a purchase or restore
/// succeeds. [revoke] exists for the other direction: `main()` asks
/// RevenueCat's own cached `CustomerInfo` once at startup and calls it if the
/// entitlement has lapsed, so a cancelled or refunded subscription does not
/// stay unlocked on this device forever.

@ProviderFor(IsSubscribed)
final isSubscribedProvider = IsSubscribedProvider._();

/// Whether this player has ever completed a purchase or a restore.
///
/// [UnconfiguredStore] cannot produce one — it throws rather than returning
/// true — so until a real billing SDK is behind [Store], this stays false for
/// everybody and every case past the first stays gated. That is the correct
/// behaviour for a build with no payment system connected, not a bug in this
/// flag.
///
/// [PaywallScreen] is what sets it true, the moment a purchase or restore
/// succeeds. [revoke] exists for the other direction: `main()` asks
/// RevenueCat's own cached `CustomerInfo` once at startup and calls it if the
/// entitlement has lapsed, so a cancelled or refunded subscription does not
/// stay unlocked on this device forever.
final class IsSubscribedProvider extends $NotifierProvider<IsSubscribed, bool> {
  /// Whether this player has ever completed a purchase or a restore.
  ///
  /// [UnconfiguredStore] cannot produce one — it throws rather than returning
  /// true — so until a real billing SDK is behind [Store], this stays false for
  /// everybody and every case past the first stays gated. That is the correct
  /// behaviour for a build with no payment system connected, not a bug in this
  /// flag.
  ///
  /// [PaywallScreen] is what sets it true, the moment a purchase or restore
  /// succeeds. [revoke] exists for the other direction: `main()` asks
  /// RevenueCat's own cached `CustomerInfo` once at startup and calls it if the
  /// entitlement has lapsed, so a cancelled or refunded subscription does not
  /// stay unlocked on this device forever.
  IsSubscribedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isSubscribedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isSubscribedHash();

  @$internal
  @override
  IsSubscribed create() => IsSubscribed();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isSubscribedHash() => r'8bb4045933d07bc3709f001fd0412ce3d2f8eba4';

/// Whether this player has ever completed a purchase or a restore.
///
/// [UnconfiguredStore] cannot produce one — it throws rather than returning
/// true — so until a real billing SDK is behind [Store], this stays false for
/// everybody and every case past the first stays gated. That is the correct
/// behaviour for a build with no payment system connected, not a bug in this
/// flag.
///
/// [PaywallScreen] is what sets it true, the moment a purchase or restore
/// succeeds. [revoke] exists for the other direction: `main()` asks
/// RevenueCat's own cached `CustomerInfo` once at startup and calls it if the
/// entitlement has lapsed, so a cancelled or refunded subscription does not
/// stay unlocked on this device forever.

abstract class _$IsSubscribed extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Whether this player's plan includes hints.
///
/// Deliberately separate from [IsSubscribed] rather than derived from it:
/// the cheapest weekly plan carries every case and no hints at all, so
/// "subscribed" and "may use hints" are two different questions with two
/// different answers. Kept in the same shape as [IsSubscribed] — persisted,
/// granted at the moment of purchase, revoked when RevenueCat says the
/// entitlement has lapsed — because the reasoning is identical: the answer
/// has to survive an offline launch.

@ProviderFor(HintsUnlocked)
final hintsUnlockedProvider = HintsUnlockedProvider._();

/// Whether this player's plan includes hints.
///
/// Deliberately separate from [IsSubscribed] rather than derived from it:
/// the cheapest weekly plan carries every case and no hints at all, so
/// "subscribed" and "may use hints" are two different questions with two
/// different answers. Kept in the same shape as [IsSubscribed] — persisted,
/// granted at the moment of purchase, revoked when RevenueCat says the
/// entitlement has lapsed — because the reasoning is identical: the answer
/// has to survive an offline launch.
final class HintsUnlockedProvider
    extends $NotifierProvider<HintsUnlocked, bool> {
  /// Whether this player's plan includes hints.
  ///
  /// Deliberately separate from [IsSubscribed] rather than derived from it:
  /// the cheapest weekly plan carries every case and no hints at all, so
  /// "subscribed" and "may use hints" are two different questions with two
  /// different answers. Kept in the same shape as [IsSubscribed] — persisted,
  /// granted at the moment of purchase, revoked when RevenueCat says the
  /// entitlement has lapsed — because the reasoning is identical: the answer
  /// has to survive an offline launch.
  HintsUnlockedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hintsUnlockedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hintsUnlockedHash();

  @$internal
  @override
  HintsUnlocked create() => HintsUnlocked();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hintsUnlockedHash() => r'a29d7732aeed747e42f485a41770bbd675b9fd1a';

/// Whether this player's plan includes hints.
///
/// Deliberately separate from [IsSubscribed] rather than derived from it:
/// the cheapest weekly plan carries every case and no hints at all, so
/// "subscribed" and "may use hints" are two different questions with two
/// different answers. Kept in the same shape as [IsSubscribed] — persisted,
/// granted at the moment of purchase, revoked when RevenueCat says the
/// entitlement has lapsed — because the reasoning is identical: the answer
/// has to survive an offline launch.

abstract class _$HintsUnlocked extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Whether a player who *has* hints wants to be shown them.
///
/// Defaults to **on**: this only ever matters to somebody who paid for
/// hints, and starting a bought feature switched off hides it from the
/// person who bought it. The switch exists for the opposite case — a player
/// who wants the temptation off the screen entirely — which is why turning
/// it off removes the button rather than merely dimming it.
///
/// A plain bool, not the three-state offer the pre-token build used: that
/// existed to ask consent for something free, and there is nothing to
/// consent to once it has been paid for.

@ProviderFor(HintsEnabled)
final hintsEnabledProvider = HintsEnabledProvider._();

/// Whether a player who *has* hints wants to be shown them.
///
/// Defaults to **on**: this only ever matters to somebody who paid for
/// hints, and starting a bought feature switched off hides it from the
/// person who bought it. The switch exists for the opposite case — a player
/// who wants the temptation off the screen entirely — which is why turning
/// it off removes the button rather than merely dimming it.
///
/// A plain bool, not the three-state offer the pre-token build used: that
/// existed to ask consent for something free, and there is nothing to
/// consent to once it has been paid for.
final class HintsEnabledProvider extends $NotifierProvider<HintsEnabled, bool> {
  /// Whether a player who *has* hints wants to be shown them.
  ///
  /// Defaults to **on**: this only ever matters to somebody who paid for
  /// hints, and starting a bought feature switched off hides it from the
  /// person who bought it. The switch exists for the opposite case — a player
  /// who wants the temptation off the screen entirely — which is why turning
  /// it off removes the button rather than merely dimming it.
  ///
  /// A plain bool, not the three-state offer the pre-token build used: that
  /// existed to ask consent for something free, and there is nothing to
  /// consent to once it has been paid for.
  HintsEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hintsEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hintsEnabledHash();

  @$internal
  @override
  HintsEnabled create() => HintsEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hintsEnabledHash() => r'41df351e7902d97a06d30c784127191de74ec297';

/// Whether a player who *has* hints wants to be shown them.
///
/// Defaults to **on**: this only ever matters to somebody who paid for
/// hints, and starting a bought feature switched off hides it from the
/// person who bought it. The switch exists for the opposite case — a player
/// who wants the temptation off the screen entirely — which is why turning
/// it off removes the button rather than merely dimming it.
///
/// A plain bool, not the three-state offer the pre-token build used: that
/// existed to ask consent for something free, and there is nothing to
/// consent to once it has been paid for.

abstract class _$HintsEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Bypasses the paywall for App/Play review builds — the one flag a
/// reviewer needs, since a reviewer cannot subscribe on `UnconfiguredStore`
/// any more than a player can. Every check that would lock a case or stop
/// the game on question 3 asks this first, so a review build plays every
/// case straight through with nothing to unlock.
///
/// Backed by Firebase Remote Config's `review_mode` boolean rather than a
/// compile-time constant, so it can be flipped for the build under review
/// and back again without a new submission. `build()` itself has no Firebase
/// dependency and stays `false` until told otherwise — safe for widget tests,
/// which never call `main()` — because `main()` is the only place [set] is
/// ever called, once, right after Remote Config is fetched and activated at
/// startup. Not persisted to `SharedPreferences`: this is meant to reflect
/// whatever the remote value says on THIS launch, not to survive a change
/// while the app was closed.

@ProviderFor(ReviewMode)
final reviewModeProvider = ReviewModeProvider._();

/// Bypasses the paywall for App/Play review builds — the one flag a
/// reviewer needs, since a reviewer cannot subscribe on `UnconfiguredStore`
/// any more than a player can. Every check that would lock a case or stop
/// the game on question 3 asks this first, so a review build plays every
/// case straight through with nothing to unlock.
///
/// Backed by Firebase Remote Config's `review_mode` boolean rather than a
/// compile-time constant, so it can be flipped for the build under review
/// and back again without a new submission. `build()` itself has no Firebase
/// dependency and stays `false` until told otherwise — safe for widget tests,
/// which never call `main()` — because `main()` is the only place [set] is
/// ever called, once, right after Remote Config is fetched and activated at
/// startup. Not persisted to `SharedPreferences`: this is meant to reflect
/// whatever the remote value says on THIS launch, not to survive a change
/// while the app was closed.
final class ReviewModeProvider extends $NotifierProvider<ReviewMode, bool> {
  /// Bypasses the paywall for App/Play review builds — the one flag a
  /// reviewer needs, since a reviewer cannot subscribe on `UnconfiguredStore`
  /// any more than a player can. Every check that would lock a case or stop
  /// the game on question 3 asks this first, so a review build plays every
  /// case straight through with nothing to unlock.
  ///
  /// Backed by Firebase Remote Config's `review_mode` boolean rather than a
  /// compile-time constant, so it can be flipped for the build under review
  /// and back again without a new submission. `build()` itself has no Firebase
  /// dependency and stays `false` until told otherwise — safe for widget tests,
  /// which never call `main()` — because `main()` is the only place [set] is
  /// ever called, once, right after Remote Config is fetched and activated at
  /// startup. Not persisted to `SharedPreferences`: this is meant to reflect
  /// whatever the remote value says on THIS launch, not to survive a change
  /// while the app was closed.
  ReviewModeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewModeProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewModeHash();

  @$internal
  @override
  ReviewMode create() => ReviewMode();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$reviewModeHash() => r'93cdf47e089b8d08606ed65043da5b9f415a4ca0';

/// Bypasses the paywall for App/Play review builds — the one flag a
/// reviewer needs, since a reviewer cannot subscribe on `UnconfiguredStore`
/// any more than a player can. Every check that would lock a case or stop
/// the game on question 3 asks this first, so a review build plays every
/// case straight through with nothing to unlock.
///
/// Backed by Firebase Remote Config's `review_mode` boolean rather than a
/// compile-time constant, so it can be flipped for the build under review
/// and back again without a new submission. `build()` itself has no Firebase
/// dependency and stays `false` until told otherwise — safe for widget tests,
/// which never call `main()` — because `main()` is the only place [set] is
/// ever called, once, right after Remote Config is fetched and activated at
/// startup. Not persisted to `SharedPreferences`: this is meant to reflect
/// whatever the remote value says on THIS launch, not to survive a change
/// while the app was closed.

abstract class _$ReviewMode extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Whether the player may open every case, and whether they may use hints.
///
/// **These are what the locks ask, and nothing else should.** `IsSubscribed`
/// and `HintsUnlocked` record what was actually bought; these two answer the
/// different question of what this build is currently allowed to show, which
/// is the same thing plus the review-mode free pass.
///
/// Keeping the pass in one place per entitlement is the point. It used to be
/// spelled out at the two case locks and nowhere else, so a reviewer could
/// open all ten cases and still never reach a hint: the button opened the
/// paywall at them and the Settings switch was never drawn. A feature a
/// reviewer cannot exercise is a feature they can only take on trust.
///
/// The sales surfaces deliberately do **not** use these — see [ProButton].
/// A reviewer has to be able to find and open the paywall, so what is offered
/// for sale follows what was really bought, while what is unlocked follows
/// these.

@ProviderFor(hasPro)
final hasProProvider = HasProProvider._();

/// Whether the player may open every case, and whether they may use hints.
///
/// **These are what the locks ask, and nothing else should.** `IsSubscribed`
/// and `HintsUnlocked` record what was actually bought; these two answer the
/// different question of what this build is currently allowed to show, which
/// is the same thing plus the review-mode free pass.
///
/// Keeping the pass in one place per entitlement is the point. It used to be
/// spelled out at the two case locks and nowhere else, so a reviewer could
/// open all ten cases and still never reach a hint: the button opened the
/// paywall at them and the Settings switch was never drawn. A feature a
/// reviewer cannot exercise is a feature they can only take on trust.
///
/// The sales surfaces deliberately do **not** use these — see [ProButton].
/// A reviewer has to be able to find and open the paywall, so what is offered
/// for sale follows what was really bought, while what is unlocked follows
/// these.

final class HasProProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether the player may open every case, and whether they may use hints.
  ///
  /// **These are what the locks ask, and nothing else should.** `IsSubscribed`
  /// and `HintsUnlocked` record what was actually bought; these two answer the
  /// different question of what this build is currently allowed to show, which
  /// is the same thing plus the review-mode free pass.
  ///
  /// Keeping the pass in one place per entitlement is the point. It used to be
  /// spelled out at the two case locks and nowhere else, so a reviewer could
  /// open all ten cases and still never reach a hint: the button opened the
  /// paywall at them and the Settings switch was never drawn. A feature a
  /// reviewer cannot exercise is a feature they can only take on trust.
  ///
  /// The sales surfaces deliberately do **not** use these — see [ProButton].
  /// A reviewer has to be able to find and open the paywall, so what is offered
  /// for sale follows what was really bought, while what is unlocked follows
  /// these.
  HasProProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasProProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasProHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasPro(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasProHash() => r'73e2e21418272927bab66c764535c9f46a478dba';

@ProviderFor(hasHints)
final hasHintsProvider = HasHintsProvider._();

final class HasHintsProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  HasHintsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hasHintsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hasHintsHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return hasHints(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$hasHintsHash() => r'a9672649b5492762527ffa1d6ec37589535d40b9';

/// Whether the player wants to be reminded about a case they left open.
///
/// Defaults to **on**, but that is not the same as being notified: the OS
/// permission is asked for separately and much later, and nothing is
/// delivered without it. This switch is the one the player controls, and it
/// exists because a reminder somebody cannot turn off inside the app gets
/// turned off outside it, for the whole app, permanently.

@ProviderFor(RemindersEnabled)
final remindersEnabledProvider = RemindersEnabledProvider._();

/// Whether the player wants to be reminded about a case they left open.
///
/// Defaults to **on**, but that is not the same as being notified: the OS
/// permission is asked for separately and much later, and nothing is
/// delivered without it. This switch is the one the player controls, and it
/// exists because a reminder somebody cannot turn off inside the app gets
/// turned off outside it, for the whole app, permanently.
final class RemindersEnabledProvider
    extends $NotifierProvider<RemindersEnabled, bool> {
  /// Whether the player wants to be reminded about a case they left open.
  ///
  /// Defaults to **on**, but that is not the same as being notified: the OS
  /// permission is asked for separately and much later, and nothing is
  /// delivered without it. This switch is the one the player controls, and it
  /// exists because a reminder somebody cannot turn off inside the app gets
  /// turned off outside it, for the whole app, permanently.
  RemindersEnabledProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remindersEnabledProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remindersEnabledHash();

  @$internal
  @override
  RemindersEnabled create() => RemindersEnabled();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$remindersEnabledHash() => r'07dc02c05d4af8139a0817e96ba2ccef771b07dd';

/// Whether the player wants to be reminded about a case they left open.
///
/// Defaults to **on**, but that is not the same as being notified: the OS
/// permission is asked for separately and much later, and nothing is
/// delivered without it. This switch is the one the player controls, and it
/// exists because a reminder somebody cannot turn off inside the app gets
/// turned off outside it, for the whole app, permanently.

abstract class _$RemindersEnabled extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Whether the OS permission prompt has been shown. Android only ever shows
/// it once — a refusal is permanent — so this stops a second attempt that
/// would do nothing but look broken.

@ProviderFor(RemindersAsked)
final remindersAskedProvider = RemindersAskedProvider._();

/// Whether the OS permission prompt has been shown. Android only ever shows
/// it once — a refusal is permanent — so this stops a second attempt that
/// would do nothing but look broken.
final class RemindersAskedProvider
    extends $NotifierProvider<RemindersAsked, bool> {
  /// Whether the OS permission prompt has been shown. Android only ever shows
  /// it once — a refusal is permanent — so this stops a second attempt that
  /// would do nothing but look broken.
  RemindersAskedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'remindersAskedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$remindersAskedHash();

  @$internal
  @override
  RemindersAsked create() => RemindersAsked();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$remindersAskedHash() => r'd17d7163d6dace76335893dec3351947b984ca1b';

/// Whether the OS permission prompt has been shown. Android only ever shows
/// it once — a refusal is permanent — so this stops a second attempt that
/// would do nothing but look broken.

abstract class _$RemindersAsked extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
