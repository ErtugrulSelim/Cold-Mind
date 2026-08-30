import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../../data/l10n/case_strings.dart';

/// Drag dated events into the order they actually happened.
///
/// The list starts in the **authored** order, which is deliberately scrambled,
/// and the question grades against indices into that same authored list. So
/// what travels in and out of here is a list of original indices, never the
/// display positions — reordering the display and forgetting to map back is the
/// one bug this interaction has, and keeping the indices as the currency is
/// what stops it.
class TimelineOrder extends StatelessWidget {
  final List<String> eventKeys;
  final CaseStrings? strings;
  final String prompt;

  /// Original indices, in the order the player has arranged them.
  final List<int> order;

  final ValueChanged<List<int>> onReorder;

  const TimelineOrder({
    super.key,
    required this.eventKeys,
    required this.strings,
    required this.prompt,
    required this.order,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    final device = context.device;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompt,
          style: ColdType.fileHeading.copyWith(color: device.textSecondary),
        ),
        const SizedBox(height: ColdSpace.md),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          buildDefaultDragHandles: false,
          itemCount: order.length,
          // `onReorderItem` rather than `onReorder`: it hands back a
          // destination already corrected for the removed item, which is
          // exactly the off-by-one this interaction otherwise ships with.
          onReorderItem: (from, to) {
            final next = [...order];
            next.insert(to, next.removeAt(from));
            onReorder(next);
          },
          itemBuilder: (context, position) {
            final original = order[position];
            return Padding(
              key: ValueKey(original),
              padding: const EdgeInsets.only(bottom: ColdSpace.sm),
              child: ReorderableDragStartListener(
                index: position,
                child: Container(
                  padding: const EdgeInsets.all(ColdSpace.md),
                  decoration: BoxDecoration(
                    color: device.surfaceInput,
                    borderRadius: ColdRadius.card,
                    border: Border.all(color: device.hairline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // The position in the player's ordering, not the event's
                      // own id — this column is the answer being written.
                      Text(
                        '${position + 1}',
                        style: ColdType.fileHeading.copyWith(
                          color: device.textPrimary,
                        ),
                      ),
                      const SizedBox(width: ColdSpace.md),
                      Expanded(
                        child: Text(
                          strings?.t(eventKeys[original]) ?? '',
                          style: ColdType.fileBody.copyWith(
                            color: device.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: ColdSpace.sm),
                      Icon(
                        Icons.drag_indicator_rounded,
                        size: 18,
                        color: device.textSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
