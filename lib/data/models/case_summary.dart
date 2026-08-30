import 'package:freezed_annotation/freezed_annotation.dart';

part 'case_summary.freezed.dart';
part 'case_summary.g.dart';

/// One row of the case list.
///
/// Generated into `assets/cases/index.json` from the case files themselves, so
/// the list can be rendered without parsing ten 200 KB documents — and cannot
/// drift from what those documents say, the way a hand-maintained index does.
@freezed
abstract class CaseSummary with _$CaseSummary {
  const factory CaseSummary({
    required String id,
    required String titleKey,
    required String difficulty,
    required String city,
    required String clientName,
    @Default(0) int questionCount,
    String? thumbnail,

    /// Photographs from the case, spread out behind its file on the desk.
    /// Never includes [thumbnail]: the same picture sharp and blurred at once
    /// reads as the file's own shadow rather than as a background.
    @Default(<String>[]) List<String> backdrop,
  }) = _CaseSummary;

  factory CaseSummary.fromJson(Map<String, dynamic> json) =>
      _$CaseSummaryFromJson(json);
}
