import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'reminders.dart';

/// [Reminders] over `flutter_local_notifications`.
///
/// Every plugin type stays inside this file, the same way every RevenueCat
/// type stays inside `revenuecat_store.dart`: the question screen and the
/// settings screen talk to [Reminders] and cannot tell what is behind it.
class LocalReminders implements Reminders {
  /// The channel the packs already describe — `notif.channel.daily.*`.
  static const String _channelId = 'case_reminders';

  final FlutterLocalNotificationsPlugin _plugin;
  final String channelName;
  final String channelDescription;

  const LocalReminders(
    this._plugin, {
    required this.channelName,
    required this.channelDescription,
  });

  /// Sets the plugin up, or returns null if it cannot be.
  ///
  /// Null rather than a throw: a device that refuses to initialise its
  /// notification stack is not a reason to fail startup, and the app keeps
  /// running on [UnconfiguredReminders] exactly as it does before any of this
  /// is configured.
  static Future<LocalReminders?> start({
    required String channelName,
    required String channelDescription,
  }) async {
    try {
      // The scheduler works in absolute local time, and "seven o'clock" only
      // means anything against a real zone — the default is UTC, which would
      // fire a Turkish player's reminder at ten at night.
      tz_data.initializeTimeZones();
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));

      final plugin = FlutterLocalNotificationsPlugin();
      final ready = await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            // Asked for deliberately later, at a moment the player has some
            // reason to say yes — never as a side effect of starting up.
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      if (ready != true) return null;

      return LocalReminders(
        plugin,
        channelName: channelName,
        channelDescription: channelDescription,
      );
    } catch (_) {
      return null;
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  Future<bool> hasPermission() async {
    try {
      if (Platform.isAndroid) {
        return await _android?.areNotificationsEnabled() ?? false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      if (Platform.isAndroid) {
        return await _android?.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(alert: true, badge: true) ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> schedule(List<ScheduledReminder> reminders) async {
    await cancelAll();
    if (reminders.isEmpty) return;

    for (final reminder in reminders) {
      try {
        await _plugin.zonedSchedule(
          id: reminder.id,
          title: reminder.title,
          body: reminder.body,
          scheduledDate: tz.TZDateTime.from(reminder.at, tz.local),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _channelId,
              channelName,
              channelDescription: channelDescription,
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: const DarwinNotificationDetails(),
          ),
          // Inexact, deliberately. An exact alarm needs its own permission on
          // Android 12+, which is meant for calendars and clocks and is
          // rejected for a nudge like this one; a reminder that lands within
          // the hour is the same reminder.
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (_) {
        // One reminder that cannot be scheduled is not a reason to drop the
        // rest, or to fail the launch that asked for them.
      }
    }
  }

  @override
  Future<void> cancelAll() async {
    try {
      await _plugin.cancelAll();
    } catch (_) {
      // Nothing to cancel, or nothing that will admit to it.
    }
  }
}
