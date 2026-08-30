import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Icons drawn rather than shipped.
///
/// Five apps never had an image file, and a flat coloured square next to
/// eighteen real icons is the one thing that gives a fake phone away. Drawing
/// them costs nothing, they scale to any size, and two of them can show live
/// values — the clock reads the actual time and the calendar the actual date,
/// which is exactly what those two icons do on a real phone.
typedef IconPainter = Widget Function(double size);

/// Rounded-square chrome shared by every painted icon, so they sit in the grid
/// at the same radius and weight as the image-backed ones.
Widget _plate({
  required double size,
  required Widget child,
  Gradient? gradient,
  Color? color,
}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      gradient: gradient,
      borderRadius: BorderRadius.circular(size * 0.225),
    ),
    clipBehavior: Clip.antiAlias,
    child: child,
  );
}

/// White face, real hands. Reads the device clock, like the icon it imitates.
Widget buildClockIcon(double size) {
  return _plate(
    size: size,
    color: Colors.white,
    child: CustomPaint(painter: _ClockPainter(DateTime.now())),
  );
}

class _ClockPainter extends CustomPainter {
  final DateTime now;

  const _ClockPainter(this.now);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;

    final tick = Paint()
      ..color = const Color(0xFF9A9AA0)
      ..strokeWidth = size.width * 0.014;
    for (var i = 0; i < 12; i++) {
      final a = i * math.pi / 6;
      final outer = r * 0.86;
      final inner = i % 3 == 0 ? r * 0.72 : r * 0.78;
      canvas.drawLine(
        center + Offset(math.sin(a) * inner, -math.cos(a) * inner),
        center + Offset(math.sin(a) * outer, -math.cos(a) * outer),
        tick,
      );
    }

    void hand(double angle, double length, double width, Color color) {
      canvas.drawLine(
        center,
        center + Offset(math.sin(angle) * length, -math.cos(angle) * length),
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    final minute = now.minute / 60;
    final hour = (now.hour % 12 + minute) / 12;
    hand(hour * 2 * math.pi, r * 0.42, size.width * 0.055, Colors.black);
    hand(minute * 2 * math.pi, r * 0.64, size.width * 0.045, Colors.black);
    hand(
      now.second / 60 * 2 * math.pi,
      r * 0.68,
      size.width * 0.022,
      const Color(0xFFFF9500),
    );

    canvas.drawCircle(
      center,
      size.width * 0.035,
      Paint()..color = Colors.black,
    );
  }

  @override
  bool shouldRepaint(_ClockPainter old) => old.now.minute != now.minute;
}

/// Sky gradient, sun behind a cloud.
Widget buildWeatherIcon(double size) {
  return _plate(
    size: size,
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF2E9BE8), Color(0xFF6FC4F5)],
    ),
    child: CustomPaint(painter: const _WeatherPainter()),
  );
}

class _WeatherPainter extends CustomPainter {
  const _WeatherPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    canvas.drawCircle(
      Offset(w * 0.63, h(size, 0.34)),
      w * 0.15,
      Paint()..color = const Color(0xFFFFD23F),
    );

    final cloud = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(w * 0.38, h(size, 0.58)), w * 0.15, cloud);
    canvas.drawCircle(Offset(w * 0.58, h(size, 0.56)), w * 0.19, cloud);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h(size, 0.58), w * 0.48, h(size, 0.18)),
        Radius.circular(w * 0.09),
      ),
      cloud,
    );
  }

  double h(Size s, double f) => s.height * f;

  @override
  bool shouldRepaint(_WeatherPainter old) => false;
}

/// White page, red weekday, today's number. Live, like the real one.
/// Agenda — the calendar. Live: it reads today's date, which is what a
/// calendar icon is for.
///
/// It was a white plate with a red weekday, which is the convention every
/// desktop calendar borrowed from the same place. Restyled into the house
/// palette once the rest of the set was drawn, because one white tile among
/// twenty-two coloured ones reads as the odd one bought in.
Widget buildCalendarIcon(double size) {
  final now = DateTime.now();
  const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];

  return _plate(
    size: size,
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFB0453F), Color(0xFF7E2B27)],
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: size * 0.08),
        Text(
          days[now.weekday - 1],
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: size * 0.16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          '${now.day}',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.44,
            fontWeight: FontWeight.w300,
            height: 1.05,
          ),
        ),
      ],
    ),
  );
}

Widget buildStaysIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF5A5F), Color(0xFFE0484D)],
  ),
  child: Icon(Icons.hotel_rounded, color: Colors.white, size: size * 0.52),
);

Widget buildMatchesIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6036), Color(0xFFFD267D)],
  ),
  child: Icon(
    Icons.local_fire_department_rounded,
    color: Colors.white,
    size: size * 0.56,
  ),
);

Widget buildMarginIcon(double size) => _plate(
  size: size,
  color: const Color(0xFF1A1714),
  child: Icon(
    Icons.menu_book_rounded,
    color: const Color(0xFFE8DFC8),
    size: size * 0.5,
  ),
);

// ── The rest of the phone ────────────────────────────────────────────────────
//
// Every icon below replaces a shipped image of a real product's logo. They are
// built the same way the ones above are — a plate, a colour and a mark — and
// each is deliberately steered *away* from the palette of the app it stands in
// for: the messenger is not green, the search is not four colours, the feed is
// not an orange gradient. A mark that lands near the original is the failure
// case here, not the goal.
//
// One system, one weight, one radius: on a real phone the icons come from
// twenty different design teams, but this phone has one, and letting it read
// that way is what makes it feel like a device rather than a collage.

/// Dial — the phone.
Widget buildDialIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D57), Color(0xFF1E5E40)],
  ),
  child: Icon(Icons.call_rounded, color: Colors.white, size: size * 0.5),
);

/// Texts — the SMS app the network gave the phone.
Widget buildTextsIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5B6B87), Color(0xFF3E4A61)],
  ),
  child: Icon(
    Icons.chat_bubble_rounded,
    color: Colors.white,
    size: size * 0.46,
  ),
);

/// Circle — the messenger. Teal, precisely because the app it stands in for is
/// the most recognisable green on any phone.
Widget buildCircleIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2A9D9B), Color(0xFF187A78)],
  ),
  child: Icon(Icons.forum_rounded, color: Colors.white, size: size * 0.48),
);

/// Inbox — mail.
Widget buildInboxIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF44618F), Color(0xFF2C4368)],
  ),
  child: Icon(Icons.mail_rounded, color: Colors.white, size: size * 0.46),
);

/// Frames — the feed. Violet rather than the sunset gradient everyone knows.
Widget buildFramesIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6E4BC4), Color(0xFF3F2A80)],
  ),
  child: Icon(Icons.camera_outlined, color: Colors.white, size: size * 0.54),
);

/// Album — the photo library.
Widget buildAlbumIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE0A33C), Color(0xFFC0762A)],
  ),
  child: Icon(
    Icons.photo_library_rounded,
    color: Colors.white,
    size: size * 0.46,
  ),
);

/// Pages — notes. The one light plate in the set, because it is paper.
Widget buildPagesIcon(double size) => _plate(
  size: size,
  color: const Color(0xFFF0E7D2),
  child: Icon(
    Icons.notes_rounded,
    color: const Color(0xFF3A3324),
    size: size * 0.5,
  ),
);

/// Atlas — maps.
Widget buildAtlasIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3E7C59), Color(0xFF24543A)],
  ),
  child: Icon(Icons.map_rounded, color: Colors.white, size: size * 0.5),
);

/// Locker — the cloud drive.
Widget buildLockerIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4A7EA8), Color(0xFF2E5878)],
  ),
  child: Icon(Icons.cloud_rounded, color: Colors.white, size: size * 0.5),
);

/// Keyring — the password vault.
Widget buildKeyringIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6B3F63), Color(0xFF42263E)],
  ),
  child: Icon(Icons.vpn_key_rounded, color: Colors.white, size: size * 0.46),
);

/// Access — the building's door system.
Widget buildAccessIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF41569C), Color(0xFF27336B)],
  ),
  child: Icon(Icons.badge_rounded, color: Colors.white, size: size * 0.48),
);

/// Recorder — voice memos. Dark, with the level meter every recorder shows.
Widget buildRecorderIcon(double size) => _plate(
  size: size,
  color: const Color(0xFF17181C),
  child: Icon(
    Icons.graphic_eq_rounded,
    color: const Color(0xFFD9534F),
    size: size * 0.54,
  ),
);

/// Ledger — payments.
Widget buildLedgerIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2C7A72), Color(0xFF19514C)],
  ),
  child: Icon(
    Icons.account_balance_wallet_rounded,
    color: Colors.white,
    size: size * 0.46,
  ),
);

/// Lookup — search. Graphite, not four colours.
Widget buildLookupIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4C5058), Color(0xFF2B2E34)],
  ),
  child: Icon(Icons.search_rounded, color: Colors.white, size: size * 0.54),
);

/// Airwave — music.
Widget buildAirwaveIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7B4BB7), Color(0xFF4A2A78)],
  ),
  child: Icon(Icons.music_note_rounded, color: Colors.white, size: size * 0.52),
);

/// Slate — the work chat.
Widget buildSlateIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC26A34), Color(0xFF8E4620)],
  ),
  child: Icon(Icons.tag_rounded, color: Colors.white, size: size * 0.52),
);

/// Settings — the one app every phone has under the same name.
Widget buildSettingsIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6A6E76), Color(0xFF43464D)],
  ),
  child: Icon(Icons.settings_rounded, color: Colors.white, size: size * 0.52),
);

/// Fare — journeys taken. Night blue, because almost every ride that matters
/// in these cases was taken after dark.
Widget buildFareIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1F3A5F), Color(0xFF14263D)],
  ),
  child: Icon(
    Icons.local_taxi_rounded,
    color: const Color(0xFFE8C15A),
    size: size * 0.5,
  ),
);

/// Pulse — what the body was doing. The one app on the phone whose readings
/// were taken from the owner rather than entered by them.
Widget buildPulseIcon(double size) => _plate(
  size: size,
  gradient: const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF9B2F4A), Color(0xFF5E1B2C)],
  ),
  child: Icon(
    Icons.monitor_heart_rounded,
    color: Colors.white,
    size: size * 0.52,
  ),
);
