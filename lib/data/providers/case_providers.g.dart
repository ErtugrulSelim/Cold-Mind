// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Asset access. Overridden in tests with a repository over a fake bundle.

@ProviderFor(caseRepository)
final caseRepositoryProvider = CaseRepositoryProvider._();

/// Asset access. Overridden in tests with a repository over a fake bundle.

final class CaseRepositoryProvider
    extends $FunctionalProvider<CaseRepository, CaseRepository, CaseRepository>
    with $Provider<CaseRepository> {
  /// Asset access. Overridden in tests with a repository over a fake bundle.
  CaseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'caseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$caseRepositoryHash();

  @$internal
  @override
  $ProviderElement<CaseRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CaseRepository create(Ref ref) {
    return caseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CaseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CaseRepository>(value),
    );
  }
}

String _$caseRepositoryHash() => r'34ecbcda7559dab4eca098832fa522d56f96a622';

/// The case list, read from the generated index rather than from ten 200 KB
/// case files.

@ProviderFor(caseIndex)
final caseIndexProvider = CaseIndexProvider._();

/// The case list, read from the generated index rather than from ten 200 KB
/// case files.

final class CaseIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CaseSummary>>,
          List<CaseSummary>,
          FutureOr<List<CaseSummary>>
        >
    with
        $FutureModifier<List<CaseSummary>>,
        $FutureProvider<List<CaseSummary>> {
  /// The case list, read from the generated index rather than from ten 200 KB
  /// case files.
  CaseIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'caseIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$caseIndexHash();

  @$internal
  @override
  $FutureProviderElement<List<CaseSummary>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CaseSummary>> create(Ref ref) {
    return caseIndex(ref);
  }
}

String _$caseIndexHash() => r'7857df9451c65bbbf692437b267453e31ce888e2';

/// The case the player currently has open, remembered across launches so the
/// game reopens where they left off.
///
/// Everything below is keyed by case id rather than reading a global "current
/// scenario" singleton, so opening a different case builds fresh data instead
/// of mutating shared state underneath whatever is already on screen.

@ProviderFor(OpenCase)
final openCaseProvider = OpenCaseProvider._();

/// The case the player currently has open, remembered across launches so the
/// game reopens where they left off.
///
/// Everything below is keyed by case id rather than reading a global "current
/// scenario" singleton, so opening a different case builds fresh data instead
/// of mutating shared state underneath whatever is already on screen.
final class OpenCaseProvider extends $NotifierProvider<OpenCase, String?> {
  /// The case the player currently has open, remembered across launches so the
  /// game reopens where they left off.
  ///
  /// Everything below is keyed by case id rather than reading a global "current
  /// scenario" singleton, so opening a different case builds fresh data instead
  /// of mutating shared state underneath whatever is already on screen.
  OpenCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'openCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$openCaseHash();

  @$internal
  @override
  OpenCase create() => OpenCase();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$openCaseHash() => r'9051384e2564e846c136999d8b981ce29d4ce889';

/// The case the player currently has open, remembered across launches so the
/// game reopens where they left off.
///
/// Everything below is keyed by case id rather than reading a global "current
/// scenario" singleton, so opening a different case builds fresh data instead
/// of mutating shared state underneath whatever is already on screen.

abstract class _$OpenCase extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(caseFile)
final caseFileProvider = CaseFileFamily._();

final class CaseFileProvider
    extends
        $FunctionalProvider<AsyncValue<CaseFile>, CaseFile, FutureOr<CaseFile>>
    with $FutureModifier<CaseFile>, $FutureProvider<CaseFile> {
  CaseFileProvider._({
    required CaseFileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'caseFileProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$caseFileHash();

  @override
  String toString() {
    return r'caseFileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CaseFile> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CaseFile> create(Ref ref) {
    final argument = this.argument as String;
    return caseFile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CaseFileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$caseFileHash() => r'ab506833ff4b70327235045c4085703c8f894611';

final class CaseFileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CaseFile>, String> {
  CaseFileFamily._()
    : super(
        retry: null,
        name: r'caseFileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  CaseFileProvider call(String caseId) =>
      CaseFileProvider._(argument: caseId, from: this);

  @override
  String toString() => r'caseFileProvider';
}

@ProviderFor(people)
final peopleProvider = PeopleFamily._();

final class PeopleProvider
    extends
        $FunctionalProvider<
          AsyncValue<PeoplePool>,
          PeoplePool,
          FutureOr<PeoplePool>
        >
    with $FutureModifier<PeoplePool>, $FutureProvider<PeoplePool> {
  PeopleProvider._({
    required PeopleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'peopleProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$peopleHash();

  @override
  String toString() {
    return r'peopleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<PeoplePool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<PeoplePool> create(Ref ref) {
    final argument = this.argument as String;
    return people(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PeopleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$peopleHash() => r'71bb0c9ff76cf01618a23b9655084a298f40c63f';

final class PeopleFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<PeoplePool>, String> {
  PeopleFamily._()
    : super(
        retry: null,
        name: r'peopleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  PeopleProvider call(String caseId) =>
      PeopleProvider._(argument: caseId, from: this);

  @override
  String toString() => r'peopleProvider';
}

/// Strings for a case in the selected language. Watching the language means a
/// switch in Settings re-resolves every string in place, with no reload.

@ProviderFor(caseStrings)
final caseStringsProvider = CaseStringsFamily._();

/// Strings for a case in the selected language. Watching the language means a
/// switch in Settings re-resolves every string in place, with no reload.

final class CaseStringsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CaseStrings>,
          CaseStrings,
          FutureOr<CaseStrings>
        >
    with $FutureModifier<CaseStrings>, $FutureProvider<CaseStrings> {
  /// Strings for a case in the selected language. Watching the language means a
  /// switch in Settings re-resolves every string in place, with no reload.
  CaseStringsProvider._({
    required CaseStringsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'caseStringsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$caseStringsHash();

  @override
  String toString() {
    return r'caseStringsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CaseStrings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CaseStrings> create(Ref ref) {
    final argument = this.argument as String;
    return caseStrings(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CaseStringsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$caseStringsHash() => r'23f24c944ba0235a1dc9eb0218958d0467b55789';

/// Strings for a case in the selected language. Watching the language means a
/// switch in Settings re-resolves every string in place, with no reload.

final class CaseStringsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CaseStrings>, String> {
  CaseStringsFamily._()
    : super(
        retry: null,
        name: r'caseStringsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Strings for a case in the selected language. Watching the language means a
  /// switch in Settings re-resolves every string in place, with no reload.

  CaseStringsProvider call(String caseId) =>
      CaseStringsProvider._(argument: caseId, from: this);

  @override
  String toString() => r'caseStringsProvider';
}

/// Shared strings alone — enough for the case list and settings, before any
/// case is open.

@ProviderFor(commonStrings)
final commonStringsProvider = CommonStringsProvider._();

/// Shared strings alone — enough for the case list and settings, before any
/// case is open.

final class CommonStringsProvider
    extends
        $FunctionalProvider<
          AsyncValue<CaseStrings>,
          CaseStrings,
          FutureOr<CaseStrings>
        >
    with $FutureModifier<CaseStrings>, $FutureProvider<CaseStrings> {
  /// Shared strings alone — enough for the case list and settings, before any
  /// case is open.
  CommonStringsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'commonStringsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$commonStringsHash();

  @$internal
  @override
  $FutureProviderElement<CaseStrings> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<CaseStrings> create(Ref ref) {
    return commonStrings(ref);
  }
}

String _$commonStringsHash() => r'9a77e67b2bff49f351e8f12d905c04c0967b60e0';

/// The grader for one case, bound to that case's strings because the accepted
/// answers are localized alongside everything else.

@ProviderFor(answerEvaluator)
final answerEvaluatorProvider = AnswerEvaluatorFamily._();

/// The grader for one case, bound to that case's strings because the accepted
/// answers are localized alongside everything else.

final class AnswerEvaluatorProvider
    extends
        $FunctionalProvider<AnswerEvaluator, AnswerEvaluator, AnswerEvaluator>
    with $Provider<AnswerEvaluator> {
  /// The grader for one case, bound to that case's strings because the accepted
  /// answers are localized alongside everything else.
  AnswerEvaluatorProvider._({
    required AnswerEvaluatorFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'answerEvaluatorProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$answerEvaluatorHash();

  @override
  String toString() {
    return r'answerEvaluatorProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<AnswerEvaluator> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AnswerEvaluator create(Ref ref) {
    final argument = this.argument as String;
    return answerEvaluator(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AnswerEvaluator value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AnswerEvaluator>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is AnswerEvaluatorProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$answerEvaluatorHash() => r'b487aaa4d86bc4148d0b2c36dcec3d3af7f7f200';

/// The grader for one case, bound to that case's strings because the accepted
/// answers are localized alongside everything else.

final class AnswerEvaluatorFamily extends $Family
    with $FunctionalFamilyOverride<AnswerEvaluator, String> {
  AnswerEvaluatorFamily._()
    : super(
        retry: null,
        name: r'answerEvaluatorProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// The grader for one case, bound to that case's strings because the accepted
  /// answers are localized alongside everything else.

  AnswerEvaluatorProvider call(String caseId) =>
      AnswerEvaluatorProvider._(argument: caseId, from: this);

  @override
  String toString() => r'answerEvaluatorProvider';
}
