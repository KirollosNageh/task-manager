// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_timezone/flutter_timezone.dart';
// import 'package:get/get.dart';
// import 'package:timezone/data/latest_all.dart' as tz_data;
// import 'package:timezone/timezone.dart' as tz;
// import '../router/app_routes.dart';

// /// Schedules ON-DEVICE reminders that fire exactly at a task's due date/time
// /// — distinct from NotificationService (FCM), which only delivers messages
// /// someone actively sends from a server. A due-time reminder has no server
// /// trigger to react to, so it must be scheduled locally on the device.
// ///
// /// KNOWN LIMITATION (documented rather than hidden): scheduled reminders
// /// are cleared if the device reboots, since re-registering them after boot
// /// would require a boot-completed receiver + re-scheduling all pending
// /// tasks, which is out of scope for this task's time budget.
// class LocalNotificationService {
//   static final LocalNotificationService _instance =
//       LocalNotificationService._internal();
//   factory LocalNotificationService() => _instance;
//   LocalNotificationService._internal();

//   final FlutterLocalNotificationsPlugin _plugin =
//       FlutterLocalNotificationsPlugin();
//   bool _initialized = false;

//   static const _channelId = 'task_due_reminders';
//   static const _channelName = 'Task due reminders';
//   static const _channelDescription =
//       'Reminds you when a task reaches its due date and time.';

//   Future<void> init() async {
//     if (_initialized) return;
//     _initialized = true;

//     tz_data.initializeTimeZones();
//     try {
//       final localTimezone = await FlutterTimezone.getLocalTimezone();
//       tz.setLocalLocation(tz.getLocation(localTimezone));
//     } catch (_) {
//       // If timezone detection fails, scheduling still works — just against
//       // whatever timezone package's default is, rather than a confirmed
//       // device-accurate one. Not worth blocking app startup over.
//     }

//     const androidSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidSettings);

//     await _plugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (response) {
//         // Same destination as an FCM tap — see NotificationService for the
//         // equivalent handler. Kept consistent so a reminder tap and a
//         // push-notification tap behave identically to the user.
//         Get.toNamed(AppRoutes.home);
//       },
//     );

//     const channel = AndroidNotificationChannel(
//       _channelId,
//       _channelName,
//       description: _channelDescription,
//       importance: Importance.high,
//     );
//     await _plugin
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//   }

//   /// Schedules a reminder for [dueDate]. [id] must be stable per task
//   /// (callers pass task.id.hashCode) so editing a task's due date
//   /// reschedules — rather than duplicates — its reminder.
//   Future<void> scheduleTaskReminder({
//     required int id,
//     required String taskTitle,
//     required DateTime dueDate,
//   }) async {
//     final scheduledDate = tz.TZDateTime.from(dueDate, tz.local);

//     // Never schedule a reminder for a moment that's already passed —
//     // e.g. editing a task's title without changing an already-past due date.
//     if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

//     await _plugin.zonedSchedule(
//       id,
//       'Task due now',
//       taskTitle,
//       scheduledDate,
//       const NotificationDetails(
//         android: AndroidNotificationDetails(
//           _channelId,
//           _channelName,
//           channelDescription: _channelDescription,
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       // inexactAllowWhileIdle avoids requiring Android 12+'s separate
//       // "Exact Alarms" permission — a few minutes of drift is an acceptable
//       // trade-off for a task reminder, not worth an extra permission prompt.
//       androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//     );
//   }

//   Future<void> cancelTaskReminder(int id) => _plugin.cancel(id);
// }
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../router/app_routes.dart';

/// Handles on-device task due-date reminders.
class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();

  factory LocalNotificationService() => _instance;

  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _channelId = 'task_due_reminders';
  static const String _channelName = 'Task due reminders';
  static const String _channelDescription =
      'Reminds you when a task reaches its due date and time.';

  Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();

      tz.setLocalLocation(
        tz.getLocation(timezoneInfo.identifier),
      );
    } catch (_) {
      // Keep the default timezone if device timezone detection fails.
    }

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        Get.toNamed(AppRoutes.home);
      },
    );

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<void> scheduleTaskReminder({
    required int id,
    required String taskTitle,
    required DateTime dueDate,
  }) async {
    final scheduledDate = tz.TZDateTime.from(
      dueDate,
      tz.local,
    );

    if (scheduledDate.isBefore(
      tz.TZDateTime.now(tz.local),
    )) {
      return;
    }

    await _plugin.zonedSchedule(
      id: id,
      title: 'Task due now',
      body: taskTitle,
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskReminder(int id) async {
    await _plugin.cancel(id: id);
  }
}