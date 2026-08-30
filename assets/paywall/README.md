# Paywall background

`paywall_bg.jpg` — the full-screen image behind the subscription screen.

Keep the **exact filename**; `lib/screens/paywall_screen.dart` references it directly.
If the file is missing the paywall falls back to a gradient, so nothing breaks.

## How it is framed

The screen top-aligns the image, nudges it up 15%, and fades to a solid block from
about two-thirds down where the plan cards and the white CONTINUE button sit. So:

- **Portrait, 9:16 or taller.** Anything wide gets cropped hard.
- **Put the subject in the top two-thirds.** The bottom third is covered.
- **Keep the lower half dark** so the buttons stay readable without fighting it.
- **No faces, no legible text.** It's a store-facing screen; a rendered face is a
  person nobody cleared, and rendered lettering is always gibberish.

## Regenerating

The prompt lives in `tools/prompts/ui.json` (the `out_dir` field is what lets it
write outside `assets/scenarios/`):

    powershell -ExecutionPolicy Bypass -File tools/gen_images.ps1 -Id ui -Missing

## What it should show

**A cold case, not a romance.** The app was once an infidelity game and the old
paywall art was still couples in Paris — completely wrong for what this is now.
The current image is a detective's cork wall at night: pinned photographs, red
string, one desk lamp, everything else in blue-black shadow. It says *every case*,
which is what the subscription actually sells, and it matches the Investigation
Board the player already knows.
