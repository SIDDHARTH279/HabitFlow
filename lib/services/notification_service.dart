import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:habit_tracker/models/habit.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  // ── Helper: Safe 32-bit notification ID ──────────
  int _notifId(String habitId, int dayIndex, {bool isFollowUp = false}) {
    int base = habitId.hashCode.abs() % 100000;
    return base * 10 + dayIndex + (isFollowUp ? 70 : 0);
  }

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: android);
    await _notifications.initialize(initSettings);
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  tz.TZDateTime _nextWeeklyDate(int hour, int minute, int weekday) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local, now.year, now.month, now.day, hour, minute,
    );
    while (scheduled.isBefore(now) || scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> scheduleHabitReminder(HabitModel habit) async {
    if (habit.reminderTime == null) {
      print('❌ No reminder time set for ${habit.name}');
      return;
    }

    List<String> parts = habit.reminderTime!.split(':');
    int hour = int.parse(parts[0]);
    int minute = int.parse(parts[1]);

    print('✅ Scheduling for ${habit.name} at $hour:$minute');
    print('✅ Selected days: ${habit.repeatDays}');

    await cancelHabitReminder(habit.id);

    for (int dayIndex in habit.repeatDays) {
      int dartWeekday = dayIndex + 1;
      tz.TZDateTime scheduled = _nextWeeklyDate(hour, minute, dartWeekday);
      print('📅 Next scheduled: $scheduled for dayIndex=$dayIndex');

      // PRIMARY notification
      await _notifications.zonedSchedule(
        _notifId(habit.id, dayIndex),              // ← uses helper ✅
        '⏰ Habit Reminder',
        '${habit.name} is not done yet! 💪',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel', 'Habit Reminders',
            channelDescription: 'Daily habit reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );

      // FOLLOW-UP at 9 PM
      await _notifications.zonedSchedule(
        _notifId(habit.id, dayIndex, isFollowUp: true), // ← uses helper ✅
        '⚠️ Last Chance!',
        '${habit.name} is still not completed today!',
        _nextWeeklyDate(21, 0, dartWeekday),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_channel', 'Habit Reminders',
            channelDescription: 'Daily habit reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  Future<void> cancelTodayNotification(
      String habitId, int todayDayIndex) async {
    await _notifications.cancel(_notifId(habitId, todayDayIndex));              // ← helper ✅
    await _notifications.cancel(_notifId(habitId, todayDayIndex, isFollowUp: true)); // ← helper ✅
  }

  Future<void> cancelHabitReminder(String habitId) async {
    for (int dayIndex = 0; dayIndex < 7; dayIndex++) {
      await _notifications.cancel(_notifId(habitId, dayIndex));                  // ← helper ✅
      await _notifications.cancel(_notifId(habitId, dayIndex, isFollowUp: true)); // ← helper ✅
    }
  }

  Future<void> showTestNotification() async {
    await _notifications.show(
      999,
      'Test Notification 🔔',
      'Habit Tracker notifications are working!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'habit_channel', 'Habit Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}