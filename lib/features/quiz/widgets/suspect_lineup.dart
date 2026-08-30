import 'package:flutter/material.dart';

import '../../../core/theme/cold_theme.dart';
import '../../phone/contact_book.dart';
import '../../phone/widgets/avatar.dart';

/// Accuse someone from a line-up of the cast.
///
/// Faces and real names, not the nicknames the phone saved them under. By the
/// time a case asks this, the player is naming a person rather than picking a
/// contact — and "Ema" on a suspect card would be the owner's word for them,
/// not an identification.
///
/// The accusation is pinned like a photograph: one card lifts and gets a red
/// string border when chosen, so committing to it looks like a decision.
class SuspectLineup extends StatelessWidget {
  final List<String> personIds;
  final ContactBook contacts;
  final String prompt;
  final String? selected;
  final ValueChanged<String> onTap;

  const SuspectLineup({
    super.key,
    required this.personIds,
    required this.contacts,
    required this.prompt,
    required this.selected,
    required this.onTap,
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
        Wrap(
          spacing: ColdSpace.md,
          runSpacing: ColdSpace.md,
          children: [
            for (final id in personIds)
              GestureDetector(
                onTap: () => onTap(id),
                child: Container(
                  width: 104,
                  padding: const EdgeInsets.all(ColdSpace.sm),
                  decoration: BoxDecoration(
                    color: device.surfaceInput,
                    borderRadius: ColdRadius.card,
                    border: Border.all(
                      color: selected == id ? device.warning : device.hairline,
                      width: selected == id ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Avatar(
                        photoAsset: contacts.photo(id),
                        // The person, not the contact: a line-up names people.
                        name: contacts.realName(id),
                        colorHex: contacts.avatarColor(id),
                        size: 76,
                      ),
                      const SizedBox(height: ColdSpace.sm),
                      Text(
                        contacts.realName(id),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: ColdType.handLabel.copyWith(
                          color: device.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
