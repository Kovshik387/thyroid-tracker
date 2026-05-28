import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../features/medication/domain/medication_plan.dart';

class NotificationService {
  NotificationService._();

  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  var _isInitialized = false;
  var _lastSignature = '';

  Future<void> initialize() async {
    if (_isInitialized || kIsWeb) {
      return;
    }

    debugPrint('NotificationService step: initialize time zones');
    tz.initializeTimeZones();
    debugPrint('NotificationService step: initialize plugin');

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
      ),
    );

    await _requestPermissions();
    _isInitialized = true;
    debugPrint('NotificationService step: complete');
  }

  Future<void> syncMedicationReminders({
    required List<MedicationPlan> plans,
    required bool enabled,
  }) async {
    if (kIsWeb) {
      return;
    }

    await initialize();
    final signature = enabled
        ? plans
            .map((plan) =>
                '${plan.id}:${plan.name}:${plan.dosage}:${plan.intakeTime.hour}:${plan.intakeTime.minute}')
            .join('|')
        : 'disabled';

    if (signature == _lastSignature) {
      return;
    }
    _lastSignature = signature;

    await _cancelMedicationReminders();
    if (!enabled) {
      return;
    }

    for (var index = 0; index < plans.length; index++) {
      final plan = plans[index];
      await _plugin.zonedSchedule(
        id: _notificationIdForPlan(plan.id, index),
        title: 'Пора принять препарат',
        body: '${plan.name} ${plan.dosage}',
        scheduledDate: _nextDailyTime(plan.intakeTime),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_reminders',
            'Прием препаратов',
            channelDescription: 'Ежедневные напоминания о приеме препаратов',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            MacOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _cancelMedicationReminders() async {
    final pending = await _plugin.pendingNotificationRequests();
    for (final request in pending) {
      if (request.id >= 10000 && request.id < 20000) {
        await _plugin.cancel(id: request.id);
      }
    }
  }

  tz.TZDateTime _nextDailyTime(DateTime time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  int _notificationIdForPlan(String id, int fallbackIndex) {
    return 10000 + (id.hashCode & 0x1fff) + fallbackIndex;
  }
}
