# Cold Mind

A detective game. A client hands the player live remote access to one phone
belonging to someone at the centre of a case — a victim, a suspect, a missing
person, sometimes the client themselves — and the player works the case by
reading what is on it.

The ten cases are authored data, and `assets/cases/sNN/case.json` is the whole
of a case: the phone, the cast, the lock chain and the questions in one
document. **Adding a case never means touching Dart.**

## Core concept

- The player explores a simulated phone's apps — messaging, photos, mail, maps,
  notes, a password vault, cloud storage, voice memos, an e-reader and more
- Each case is a chain of sequential questions; one unlocks only when the
  previous is solved
- Answers are graded **entirely on device** — no network call, no model, at
  runtime or otherwise
- Hidden content opens through a lock chain: a note gives up a vault password,
  the vault holds an album code, the album holds the code to a locked note
- A corkboard gives each case its opening picture of who is who
- Cases open and close with a client conversation; the closing choice branches
  and is persisted into the epilogue

**The genre is crime, not infidelity.** Deaths, disappearances, frauds,
extortion, staged scenes.

## The premise everything runs on: live access, not a copy

The player is connected to the phone **as it is right now**, remotely. A client
hands over *access*, never a file. Lines like "I'm uploading an image of the
device" contradict the frame — a forensic image is frozen and could not be live.

---

## Project structure

```
lib/
  core/
    answers/           normalize.dart, answer_evaluator.dart
    theme/             palette, typography, dimensions, cold_theme
    app_config.dart    outward-facing URLs, and the review-mode flag that
                       bypasses the paywall for App/Play review
  data/
    models/            case_file, question, lock, chat, board, person, case_summary
    l10n/              case_strings.dart
    repository/        case_repository.dart
    providers/         case, progress, settings
  features/
    cases/             the case deck: one card per screen, no chrome
                       (desk register)
    case_flow/         briefing → connecting → phone
    phone/
      app_registry     what the phone can draw
      app_router       which key opens which screen
      contact_book     who a person is on this phone
      phone_format     one clock for every surface
      chats/           the conversation reader (shared by Chats, SMS, DMs)
      apps/            one file per app surface
    board/             the corkboard, and the layout that arranges it
    quiz/              where the player answers, and how a case closes
                       (desk register)
    paywall/           the subscription screen, and the store behind it
    settings/          language, and the outward-facing
                       rows — restore, rate, share, the legal pages, all
                       reading their URLs from `core/app_config.dart`

assets/
  cases/index.json     generated case list
  cases/sNN/           case.json + photos/ + audio/
  l10n/<lang>/         common.json + sNN.json (18 language folders)
  people/              people_sNN.json (cast + posts)
  stock/               shared filler for the feed grid
  textures/            the cork the board is pinned to

test/
  case_integrity_test    the gate every case must pass
  case_loading_test      loads through the asset bundle, not the filesystem
  app_coverage_test      every installed app — and every app a question names —
                         actually opens
  app_render_test        …and survives being drawn on a 390pt phone, with that
                         case's real data — plus every case's home screen.
                         Overflow counts as a failure.
  app_content_test       …and actually shows that data. A screen that renders
                         an empty list passes the sweep above; this is what
                         catches a parsing bug behind a working widget
  desk_render_test       the screens that are not the phone: the case deck,
                         the paywall, the handover
  settings_screen_test   which rows exist, that restore never quietly grants
                         access, and that all 18 languages can be reached
  home_widget_test       every case's home widgets fit across a phone
  phone_surface.dart     the 390pt surface itself. `setSurfaceSize` does not
                         resize anything — the whole suite was measuring
                         against 800x600 until this replaced it
  question_flow_test     every question accepts its own intended answer, so
                         every case can actually be finished
  question_answerability_test
                         …and the answer is findable on the phone, the
                         timeline is actually scrambled, and a wrong answer is
                         refused. Formed, graded and *playable* are three
                         different promises
  question_screen_test   every question in every case draws, and a correct
                         answer moves the cursor
  timeline_order_test    the one question answered by dragging: the handle
                         starts a drag, and a row lands where it was dropped
  case_ending_test       every case has a closing chat, every branch it offers
                         has an epilogue, every interstitial can fire
  board_layout_test      every node pinned, nothing overlapping, same every time
  app_login_test         the doors the lock chain gates are actually shut
  case_completion_test   plays s01's last question through to the epilogue —
                         the only test that proves a case can be finished
  chat_data_test         thread breaks, voice fallback, ordering
  answer_evaluator_test
  voice_registry_test    one voice per person across the whole game, and every
                         audio folder actually bundled
  tiles_game_test        the merge rule — logic on the phone that can be wrong
                         rather than merely ugly
  tiles_screen_test      opens on a new game of nothing but twos, plays, and
                         the session log keeps its clock
  mines_game_test        neighbour counts at the edges, the flood, and the
                         promise that the first tap is never a mine
  mines_screen_test      the field starts closed, a tap digs, flag mode plants
                         — and the two games are not on all the same phones
```

## The two registers

The interface runs two visual languages, and which one a surface uses is a
statement about **whose it is**.

**Desk** — the player's own side: the case index, the client conversation,
the board, settings. **Both registers are dark**; what separates them is that
the desk keeps warm things *on* it — cream paper, polaroids, tape, amber — on a
graphite ground, while the device has no warmth anywhere.

It used to be cork brown, and a screen-filling warm ground made every surface it
touched read as one orange app rather than as a desk with things on it. The
ground moved to graphite in `palette.dart` (`cork` / `corkDark`); `paper`, `ink`
and `tape` did not change, because they are the part that earns the warmth.

**Device (cold)** — the subject's phone. Dark, precise, no warmth. Every app
surface is built from these tokens.

The handover between them is the connecting screen, and it is meant to be felt.
Both palettes are `ThemeExtension`s on one theme; the spacing, radius and motion
scale is shared so the two halves read as one product.

## The phone

**A key in `apps` means the app is installed**; `home.grid` / `home.dock` only
arrange it. `app_registry.dart` says how each app is drawn, `app_router.dart`
says which key opens which screen, and adding an app is a line in each plus a
folder of its own.

The rules the app surfaces are built on:

- **The reader is not the owner.** These apps are for someone reading years of
  somebody else's life looking for one moment, not for someone keeping up with
  their messages. That is why threads draw their silences, why the chat list
  shows a conversation's span instead of "online", and why photographs carry
  their timestamps under them rather than behind an info button.
- **What was hidden is shown.** Deleted messages leave holes, deleted memos get
  their own section, cancelled events stay struck through, and Trash is a
  mailbox. Hiding what a subject hid would side with them against the player.
- **Two apps compute; the rest render.** `games` (Tiles, a 2048) and `mines`
  (a minefield) are the exception to everything above — the player can
  actually play them, and their rules live in `tiles_game.dart` and
  `mines_game.dart` with no widgets attached so they can be tested. Both earn
  their place on the half the player *cannot* operate: `sessions[]`. Every
  other timestamp on this phone was made by somebody doing something
  deliberate; a game session is made by somebody with nothing to do, which is
  why forty minutes of it at 02:14 places a person awake and alone better than
  any message can. **The board itself is never authored** — both open on a new
  game, and nothing the player does to one is saved, because evidence a reader
  can overwrite is not evidence. Tiles deals two twos and only ever spawns
  twos, so every larger number on it is one the player built.
- **They are not on the same phones.** Two games on every device makes both of
  them furniture; s01, s07 and s08 carry both, s04 and s06 have only Mines, the
  other five only Tiles. Which game a person plays, how long they play, and
  whether they ever finish one is the characterisation — `mines_screen_test`
  holds the line that the two install lists differ.
- **Mines is grey, and that is on purpose.** It takes the classic minesweeper
  look — raised bevels, seven-segment counters, the smiley — through
  `app_skin.dart`, the same seam that makes Mail white. The screen never names
  a colour; the theme answers in minesweeper grey, and its canonical numbers
  (blue 1, green 2, red 3) live in that skin as real palette entries. Drawing
  it in the device's cold tokens would read as something this phone invented
  rather than the thing everybody has already played. Its mine, flag and LED
  digits are painted, so each one carries a semantics label — a painted shape
  is silent to a screen reader, and those labels are also the only handle the
  tests have on them.
- **One clock everywhere.** `PhoneFormat` formats every date on the device,
  because the player is constantly comparing a timestamp in one app against one
  in another. Two apps writing the same moment differently is not a style
  inconsistency here; it is a broken clue.

## The case schema

One file per case: `assets/cases/sNN/case.json`. The phone, the cast, the lock
chain and the questions live in one document — so **a case is data end to end
and adding one never means touching Dart**.

```
schema, id
meta       title_key, difficulty, city{name,lat,lng}, thumbnail,
           client{person_id,name,photo}, reveal_total
device     owner_name, model, lock_pin, wallpaper_asset, …
cast       [{person_id, role, nickname, contact_saved, …}]
contacts   the phone's own address book
home       {grid: [...], dock: [...]}     arrangement only
board      {center_node_id, nodes, edges}
chats      {intro, interstitials[], closing}
locks      [{id, order, type, source_app, target_app, hint_toast_key, …}]
questions  [...]                          any length
apps       {whatsapp: {...}, maps: {...}} a key here means installed
```

### Apps that ask for a password

An app whose data sets `login_required: true` opens on a sign-in instead of on
itself. The password is `password`, or `master` in the vault — both are the same
rung of the same chain, and it is written down somewhere else on the phone.

**The gate is applied in `app_router.dart`, never inside an app.** The vault
grew its own inline login first, and for as long as it was the only one, s04 —
whose chain spends a step sending the player to find Mail's password — handed
them Mail for free. Wrapping at the router means a surface cannot forget.

`master_hint_key` is the safety net, shown behind "Forgot password?": a chain
that can dead-end is a chain that can strand a player permanently.

Signing in is persisted per case, because the player earned it; replaying the
case clears it along with everything else.

### `apps` is the install list

**A key in `apps` means the app is on this phone.** The data is the declaration,
not a separate install list that has to be reconciled with it at runtime.
`home.grid` / `home.dock` only arrange what is already there.

Only Settings, Clock and Weather ship with the OS and are on every phone.
Everything else is opt-in — that is what lets a home screen characterise its
owner. An 18-year-old has no corporate access console; a person with 214
followers and zero posts still has Instagram, and *that is the
characterisation*.

`case_integrity_test.dart` enforces that every question and every lock step
points at an installed app. Getting that wrong strands the player on a question
they cannot answer.

### Questions

**Question count is per case and free.** Nothing in the code assumes a number —
the UI reads `questions.length`. s03 already ships 16 where the rest ship 15.
Set `meta.reveal_total: false` to hide the total from the player while still
showing "Question N".

| kind | interaction | payload |
|---|---|---|
| `free_text` | type an answer | `answers_key`, optional `reveal` |
| `timeline` | drag events into order | `events`, `order` |
| `contradiction` | tap the line that doesn't hold up | `snippets` + `lie_index` or `pair` |
| `suspect` | accuse from a line-up | `person_ids`, `correct_person_id` |
| `multi_select` | toggle the exact proving set | `options`, `correct_indices` |

`order` holds indices **into the authored (scrambled) event list**, in true
chronological order.

`reveal` is the stuck-player hint pool, and **the ten cases authored it two
different ways**:

- **s01–s04** wrote the options as *answers*: "Home", "The office", "His
  brother's". The question screen shows a 50/50 — the answer against one decoy.
- **s05–s10** wrote them as *directions*: "Open the album called Counts", "Read
  her procedure note". These are not answers and grade as wrong.

`question_screen.dart` tells them apart by **running the pool's own answer line
through the evaluator**, never by case id, and renders directions as something
to read rather than something to tap. Offering a 50/50 over a direction list
would hand the player a "correct" option that then fails.

Either way the pick still goes through the evaluator: `reveal` is never how an
answer is graded. `question_flow_test.dart` holds the line that matters — where
a 50/50 *is* offered, no decoy may also grade as correct.

### Writing `free_text` answers

Answers live in the l10n pack as `[["phrase","phrase"],["alternative"]]` — the
outer list is **OR**, each inner list is an **AND** of substrings.

**Every accepted answer is one word, two at the most, and readable somewhere on
the phone.** If it cannot be said in one or two words, the question is asked
wrong. One answer is enough to pass; never require the whole set.

Matching is substring-based on a normalized string, which makes a short key
strictly *more* permissive — `chip` already accepts "the aria chip". Two traps:

- **Never glue words together.** `oneway` only matches someone who also types it
  glued. Use the stem the spaced form contains: `care` covers "care home".
- **Prefer stems to inflections.** `forgiv` catches forgive/forgiven/
  forgiveness; `unforgiven` catches none of them.

Keep keys at least three characters — `ai` matches "claire".

Ship typo alternates generously: dropped letters, accent-stripped forms,
first name as well as surname. An alternate is the same answer typed badly.
Widening what *counts* as correct is the OR-group's job and needs the same
evidence backing; typo alternates need none.

Inflected languages need stems (Polish "u dentysty" does not contain
`dentysta` — key `dentyst`); Arabic drops the ال prefix.

## The board

`board` → a corkboard opened from the question screen: polaroids, sticky notes
and map pins joined by red string, with the connection written on a strip of
tape. `is_center` / `center_node_id` marks the node it opens on, drawn larger
and edged in the same red as the string.

It is the **warm** register and lives beside the questions rather than on the
phone — a corkboard pinned inside somebody else's device would be nonsense.

**Never author coordinates.** `board_layout.dart` derives the arrangement from
the graph: a breadth-first walk from the centre puts each node on a ring by how
many strings away it is, and each ring is sized so its own members clear each
other — a ring of nine needs far more radius than a ring of three, and a fixed
gap overlaps one or wastes the other. It is deterministic, tilts included,
because position is how a player remembers who is who.

**It is the case's opening picture, never its solution.** Only what a player
could know before question one. A node that gives away the twist ruins the
case. Six to eight nodes is the working size.

## Client chat & branching endings

`chats.intro` opens the case, `chats.interstitials[]` interrupt it, and
`chats.closing` ends it. One screen plays all three — `client_chat_screen.dart`
— because they are the same conversation with the same client.

An interstitial is keyed to a **solved count**, and fires from the question
screen the moment the count is reached. A choice message carries `choices[]`,
each with an `action` and optionally a `branch`; once a branch is picked, only
messages with a matching `trigger` play from then on, and untagged messages
always play.

The chosen branch is **persisted** (`CaseProgress.chooseEnding`), because it has
to outlive the conversation that produced it: `case_solved_screen.dart` reads it
back and closes the file on `<caseId>.ending.<branch>`. That string is what
makes the choice a decision rather than three ways of saying goodbye — write it
as consequences over months, not as one more line of the client's dialogue. It
is optional, and a case without it closes on the generic line, which is the
failure that looks like nothing at all; `case_ending_test.dart` is there so it
cannot happen quietly.

Replaying a case clears the stored branch, or last run's ending would show
before the player has chosen again.

## Localization

18 language folders. English is the source of truth and the fallback, and packs
are merged per key (`{...en, ...overlay}`) — a partial translation degrades key
by key instead of breaking.

**Case packs land one language and one case at a time.** English is complete;
`tr` ships s01. Every other folder still holds `common.json` alone and reads the
cases in English. Seven languages are in scope — es, it, fr, br, pl, ru, tr —
and the merge is what makes a partial pack safe: an untranslated key falls back
rather than breaking.

`tools/build_pack.dart` assembles a pack from flat `key<TAB>value` files, so a
translator never hand-escapes JSON. **A pack translates `*.answers` too** — it
is a key like any other, so translating a case also translates what the
evaluator accepts, which is the point (a player reading a Turkish phone types
Turkish) and the one place a translation can break a case. Two things stay in
the source language on purpose alongside the three surfaces below: street
addresses and the file names in cloud storage.

`localized_packs_test.dart` holds the lines that matter for every language that
ships a pack, found by looking rather than from a list: every question still
accepts its own answer, and no translated decoy grades as correct — two English
words that share nothing can land on the same Turkish stem.

Keys carrying `{{placeholders}}` are resolved with `strings.cp(key, {...})`, not
spliced in Dart — word order around a number is not the same in every language,
and a translator has to be able to move it. Substitution runs on the resolved
string, so a key that fell back to English still gets its values.

`common.json` runs ahead of the Dart: it ships keys for surfaces that have not
been built yet. **Check it before adding a string** — the key usually already
exists, and the unused ones are a fair map of what a screen was meant to become.

Three surfaces are still unlocalized by design and always render in English:
`instagram_posts[].caption`, wifi network names, and e-reader book titles /
cloud file names / track titles (proper nouns). Nothing a player must read to
solve a case should live there.

## Audio

Clips may carry a `{lang}` placeholder; `langs` lists the languages that ship a
file. **The `en` file must always exist** — every other locale falls back to it,
and the integrity test fails if it doesn't.

Reach for audio when a line needs to be *heard* to land, not to duplicate
something already readable. The voice library is all adults: when a character is
a child, write the transcript and skip the clip.

**A case that grows its first audio folder needs a line in `pubspec.yaml`.**
Assets are declared per case, so the mp3 can be in the repository, on the right
path, with every test passing, and still throw *Unable to load asset* on the
device because the folder was never bundled. `voice_registry_test` checks it.

### One voice per person

`tools/voices.json` maps each speaker to one ElevenLabs voice, and **no two
characters may share one, even across cases** — a player who meets the same
voice as two different people on two different phones stops believing the
phones belong to anybody. `voice_registry_test` fails on a collision.

`dart run tools/gen_voices.dart` generates them through Magnific's voiceover
endpoint (`/v1/ai/voiceover/elevenlabs-turbo-v2-5`), which is task-based:
submit, poll to COMPLETED, download. **A bad `voice_id` is accepted at submit
and only fails later**, so a 200 from the submit call proves nothing about a
voice existing.

Three things the generator has to get right, each of which was a bug first:

- **Stage directions are never spoken.** Transcripts carry `(room tone…)` and
  `[recording starts mid-sentence]`, and a synthesiser reads them aloud
  happily. They are stripped — except that s04's key direction *contains* the
  director's line, and dropping it would leave a player who listens with less
  than one who reads, on a memo a question is asked about. Quoted speech comes
  back out of a direction tagged for that clip's `asideSpeaker`, and applies to
  its own line only.
- **`duration_sec` is rewritten to the real length.** `VoiceNote` draws the
  authored number and plays the file, so a memo written as 46 seconds because
  its transcript describes long silences would show 46 and stop at 12.
- **Multi-speaker memos are joined by appending MP3 frames**, not by ffmpeg —
  ID3 headers stripped from each part. Assuming a full ffmpeg is installed
  makes a two-speaker memo build on one machine and not the next.

---

## Commands

```bash
flutter pub get
dart run build_runner build      # freezed / json / riverpod codegen
flutter analyze
flutter test
flutter run
```


## What the data is guarded against

These are the failures the schema and the tests are shaped around. Worth
knowing, because the guards look arbitrary until you know what they caught.

- **Accepted answers must parse as answer groups, not as raw text.** Six of the
  ten cases once shipped the field as a JSON *string*; every free-text answer in
  them threw before it could be compared, so the player typed, submitted, and
  nothing happened. `case_loading_test` holds the line.
- **`reveal` is a hint pool, never a grader.** It is named for the 50/50 it
  feeds. Anything that grades against it is grading against a decoy —
  `question_flow_test` proves no decoy also reads as correct.
- **Every question and lock step must name an installed app.** Getting it wrong
  strands the player on a question they cannot answer; `case_integrity_test`

  refuses the case.
- **Nothing in a locked album may be on show anywhere else.** The same photo id
  listed in Recents, or in an album with no passcode, hands the player the
  picture for free while the locked album still sits there asking for a code.
  Nothing looks wrong when it happens: the lock works, the passcode works, and
  the photograph was already seen. `case_integrity_test` refuses it.
- **An app that renders nothing is not the same as an app with nothing in it.**
  Venmo shipped dropping sixty per cent of its transactions — a required field
  half the authored rows did not have — and the screen drew the remainder
  perfectly. `app_render_test` passes such a surface; `app_content_test` is the
  one that asks whether the case's own text reached the screen.
- **`instagram_posts[].comments` is empty in all ten cases** — modelled, never
  authored.
## Rules

- Write comments in English.
- Never author board coordinates; layout is computed at runtime.
- Any code that lives only inside an image must also be in the lock step's
  `hint_toast_key`, so an unreadable photo can never hard-block a player.

## Settings

The player's own screen, in grouped sections: gameplay, language, support,
about. Two rules shape it.

**A row with no destination is not drawn.** Rate, share and the two legal
pages all point outside the app, and their URLs live in one block —
`core/app_config.dart` — which ships empty. Each row appears the moment its
URL is filled in. A row that does nothing when tapped reads as broken rather
than as unfinished, and the previous build shipped another product's URLs
precisely because they were literals scattered down the middle of the screen.
`AppConfig.openStoreListing()` is the one door to the store's own listing —
used by Settings' own Rate Us row and by the post-second-question rating
prompt alike — because it is never the OS's in-app review sheet, which is
throttled and shows nothing on most builds.

**Restore goes through `Store` like everything else,** and reports with the
paywall's own messages — it is the same operation reached by a different door.
With no billing wired in the store throws, and that reaches the player as a
message; `settings_screen_test` holds the line that it can never quietly
report success.

The language sheet is height-capped and scrolls. Eighteen languages are taller
than a default bottom sheet, and a shrink-wrapped list inside one is simply cut
off — the languages at the bottom could not be picked at all.

## The paywall

`features/paywall/` is the subscription screen and the seam under it.

**The screen talks to `Store` and nothing else.** Calling a billing SDK
from inside the widget means the paywall cannot be opened — or laid
out, or translated, or screenshotted — without live credentials. Here
the SDK goes behind `Store` and arrives through `storeProvider`, so wiring a
real one is an override in `main` and a test can hand the screen a fake.

`UnconfiguredStore` is what ships until a billing SDK is added. It lists the two
real plans so the screen can be seen, and it **throws rather than returning
true** on purchase and restore. A paywall that quietly grants access when
nothing is connected gives every case away for free and looks correct in every
screenshot — `desk_render_test.dart` holds that line.

Prices are **strings the store already formatted**, never numbers this app
renders: a store returns the currency, separator and position the user's own
account expects, and rebuilding that here gets it wrong for most of the world.

The phone opens it — the GET PRO pill on the status row, beside the gear — and
so does Settings. A gate on a locked case can push
`PaywallScreen` too — nothing about the screen assumes how it was reached.

## First run

Three things happen automatically the first time a player actually plays,
never on a later launch and never for a returning player — each is a
`SharedPreferences` flag that persists on its own, not a check against
session state.

**The hint offer.** Hints are closed by default; asking is a one-time upfront
choice rather than something a player discovers mid-struggle. It fires from
`case_list_screen.dart`'s `onOpen`, the moment `freeCaseId` — the only case
reachable before a subscription — is opened for the very first time
(`progress.solved == 0` and `hintsProvider` still `HintOffer.unset`), through
the same `HelpOfferDialog` the in-question fallback (three wrong answers on
any question) also shows. That dialog is public rather than private to either
screen, because a dialog two screens show is not owned by whichever one
happened to be written first.

**The rating prompt.** Fires once, ever, the instant any case's second
question is solved, gated by `ratingPromptedProvider` — a flag that never
resets, even across a replay. "Yes" goes straight to
`AppConfig.openStoreListing()`; "no" just closes it.

**The free trial.** `freeCaseId` (`s01`) is the only case a player can open
without a subscription — every other case is locked shut on the deck itself
(`_LockableCard` in `case_list_screen.dart`), and tapping one pushes
`PaywallScreen(source: 'case_lock')` instead of opening it. Inside the free
case, the trial ends after its own third question: `question_screen.dart`
pushes `PaywallScreen(source: 'question_3')` there, and declining leaves the
case parked at question three, solved and waiting, rather than losing
progress.

**`AppConfig.reviewMode`** is the escape hatch for both locks — the one flag
a reviewer needs, since `UnconfiguredStore` throws on purchase exactly as it
would for a paying player. Flip it to `true` for the build submitted to
App/Play review, back to `false` before it ships. **Until a real `Store`
replaces `UnconfiguredStore`, this is also the *only* way s02–s10 are
reachable at all** — `purchase()`/`restore()` always throw rather than ever
returning `true`, so nothing in the current build can actually grant
`isSubscribedProvider`.

## Launch

The native splash — shown before the Flutter engine has drawn a single frame,
which no Dart-level widget can reach — is generated by `flutter_native_splash`
from `assets/icons/app_logo.jpeg` against the device register's own graphite
(`palette.dart`'s `Color(0xFF0A0C10)`), so the logo's own dark ground meets it
without a seam. Configured under `flutter_native_splash:` in `pubspec.yaml`;
regenerate with `dart run flutter_native_splash:create` after changing either
the image or the color. It writes directly into the native Android and iOS
projects (launch backgrounds, styles, `LaunchScreen.storyboard`,
`Info.plist`) — nothing here is reachable by `flutter test`, so check it on a
real device or simulator rather than trusting the test suite for it.
