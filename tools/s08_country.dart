// Closes the hole in s08's opening.
//
// ignore_for_file: avoid_print — a command line script reports on stdout.
//
//   dart run tools/s08_country.dart
//
// Re-running is safe.
//
// ── Why ─────────────────────────────────────────────────────────────────────
//
// The client's opening says three things in a row:
//
//   * the mother took Zosia out of Poland "without telling anybody";
//   * there is a return hearing in England on the ninth of June;
//   * "the court needs an address and nobody has one".
//
// Read together those do not hold. If she vanished and nobody knows where they
// are, how is anybody certain of the country — and how is an English court
// listing a hearing at all?
//
// The procedure is fine: a Hague return application is made to the Central
// Authority of the state the child was taken **to**, so the country has to be
// named, and the address does not — an English court will list the case and
// make a location order precisely because nobody has one. Enforcement is what
// needs the address, not the listing.
//
// What was missing was the case ever saying so. The country arrived out of
// nowhere and the reader was left to assume a mistake, which is worse than a
// mistake: it makes them stop trusting the rest of the file.
//
// So the solicitor's one solid fact goes in — the flight — and the board node
// says what the address is actually for. The hole stays exactly where the case
// wants it: everybody knows she landed in England, nobody knows where she went
// after the airport, and finding that out is q15.
import 'dart:convert';
import 'dart:io';

const _casePath = 'assets/cases/s08/case.json';
const _packPath = 'assets/l10n/en/s08.json';

void main() {
  final json =
      jsonDecode(File(_casePath).readAsStringSync()) as Map<String, dynamic>;
  final pack =
      jsonDecode(File(_packPath).readAsStringSync()) as Map<String, dynamic>;

  pack['s08.client_chat.cc_002b'] =
      'They know she flew. Kraków to Manchester on the eleventh, two seats, '
      'and that is the one solid thing anybody has. After the airport there '
      'is nothing at all.';

  // What the address is for, said plainly. "Everything it needs except an
  // address" read as though the hearing itself were impossible.
  pack['s08.board.hearing.sub'] =
      'Return hearing, England. The court can list it without knowing where '
      'she is. It cannot serve her, or enforce an order, until somebody does.';

  final intro = ((json['chats'] as Map)['intro'] as Map)['messages'] as List;
  if (intro.any((m) => (m as Map)['id'] == 'cc_002b')) {
    print('s08  the flight is already in the opening');
  } else {
    final at = intro.indexWhere((m) => (m as Map)['id'] == 'cc_002');
    if (at < 0) {
      stderr.writeln('s08 has no cc_002 to follow');
      exitCode = 1;
      return;
    }
    intro.insert(at + 1, {
      'id': 'cc_002b',
      'sender': 'client',
      'text_key': 's08.client_chat.cc_002b',
      'timestamp': '2026-05-11T10:05:22',
      'delay_ms': 15000,
    });
    print('s08  the opening says how they know the country');
  }

  File(_casePath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(json)}\n',
  );
  File(_packPath).writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(pack)}\n',
  );
}
