import 'package:flutter/material.dart';

import '../../../../core/theme/cold_theme.dart';

/// A column of the months a thread covers, down the right edge.
///
/// These conversations run for a year or more, and the client almost always
/// names a date — "start with the fourth of March". Scrolling blindly through
/// eighteen months of messages to reach one night is not investigation, it is
/// an obstacle, so the reader can jump.
///
/// It only appears on threads that span more than one month; on a short
/// exchange it would be furniture.
class MonthRail extends StatelessWidget {
  /// Month identifiers in thread order, "year-month".
  final List<String> monthKeys;

  final String Function(String key) labelFor;
  final String Function(String key) yearFor;
  final ValueChanged<String> onTap;

  const MonthRail({
    super.key,
    required this.monthKeys,
    required this.labelFor,
    required this.yearFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return SizedBox(
      width: 38,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: ColdSpace.md),
        child: Column(
          children: [
            for (var i = 0; i < monthKeys.length; i++) ...[
              // The year is only written where it changes, the way a hand
              // annotating a long transcript would.
              if (i == 0 || yearFor(monthKeys[i]) != yearFor(monthKeys[i - 1]))
                Padding(
                  padding: const EdgeInsets.only(top: ColdSpace.sm, bottom: 2),
                  child: Text(
                    yearFor(monthKeys[i]),
                    style: ColdType.micro.copyWith(
                      color: device.textSecondary,
                      fontSize: 8.5,
                    ),
                  ),
                ),
              InkWell(
                onTap: () => onTap(monthKeys[i]),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    labelFor(monthKeys[i]),
                    style: ColdType.micro.copyWith(
                      color: device.textTertiary,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
