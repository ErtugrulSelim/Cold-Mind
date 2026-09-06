// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CaseProgress)
final caseProgressProvider = CaseProgressFamily._();

final class CaseProgressProvider
    extends $NotifierProvider<CaseProgress, Progress> {
  CaseProgressProvider._({
    required CaseProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'caseProgressProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$caseProgressHash();

  @override
  String toString() {
    return r'caseProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  CaseProgress create() => CaseProgress();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Progress value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Progress>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CaseProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$caseProgressHash() => r'54fd3b1f133cce570875f8078db66597a21c8a33';

final class CaseProgressFamily extends $Family
    with
        $ClassFamilyOverride<
          CaseProgress,
          Progress,
          Progress,
          Progress,
          String
        > {
  CaseProgressFamily._()
    : super(
        retry: null,
        name: r'caseProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  CaseProgressProvider call(String caseId) =>
      CaseProgressProvider._(argument: caseId, from: this);

  @override
  String toString() => r'caseProgressProvider';
}

abstract class _$CaseProgress extends $Notifier<Progress> {
  late final _$args = ref.$arg as String;
  String get caseId => _$args;

  Progress build(String caseId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Progress, Progress>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Progress, Progress>,
              Progress,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
