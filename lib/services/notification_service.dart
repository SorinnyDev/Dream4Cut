import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._internal();

  final List<Map<String, String>> _randomMessages = [
    {'title': '오늘의 꿈 한 조각', 'body': '하루의 끝에서, 당신의 소중한 꿈을 기록해보세요.'},
    {'title': '오늘 당신의 발걸음은?', 'body': '잠들기 전, 소중한 순간의 조각을 남겨보세요.'},
    {'title': '잊고 싶지 않은 순간', 'body': '지금 그 조각을 인생네컷 보관함에 담아보세요.'},
    {'title': '내일의 나에게 주는 선물', 'body': '오늘의 꿈을 기록으로 남겨 선물해보세요.'},
    {'title': '인생네컷 타임! 🌙', 'body': '오늘 하루 수고 많았어요. 마지막 조각을 채워볼까요?'},
  ];

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      final dynamic timezoneResult = await FlutterTimezone.getLocalTimezone();
      final String timezoneName = (timezoneResult is String)
          ? timezoneResult
          : (timezoneResult as dynamic).identifier;

      tz.setLocalLocation(tz.getLocation(timezoneName));
      debugPrint("[NotificationService] Local timezone set to: $timezoneName");
    } catch (e) {
      debugPrint(
        "[NotificationService] Timezone initialization failed, falling back to UTC: $e",
      );
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: false, // Don't request immediately on init
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap if needed
      },
    );

    // Android 전용: 알림 채널 명시적 생성
    if (defaultTargetPlatform == TargetPlatform.android) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      final AndroidNotificationChannel channel = AndroidNotificationChannel(
        'dream4cut_daily_reminder_v3', // 진동 패턴 변경 반영을 위해 채널 ID 업서트
        '매일 밤 꿈 기록 알림 서비스',
        description: '매일 오후 10시에 꿈 기록을 장려하는 알림입니다.',
        importance: Importance.max,
        enableVibration: true,
        vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
      );

      await androidImplementation?.createNotificationChannel(channel);
      debugPrint("[NotificationService] Android notification channel created.");
    }
  }

  Future<bool> requestPermissions() async {
    bool? granted = false;

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    // Android 13+ POST_NOTIFICATIONS
    granted = await androidImplementation?.requestNotificationsPermission();

    // iOS/Darwin request
    final bool? darwinGranted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    return (granted ?? false) || (darwinGranted ?? false);
  }

  // 정확한 알람 예약 권한이 있는지 확인 (Android 13+ 대응)
  Future<bool> checkExactAlarmPermission() async {
    if (defaultTargetPlatform != TargetPlatform.android) return true;

    final androidImplementation = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    return await androidImplementation?.canScheduleExactNotifications() ??
        false;
  }

  // 시스템 알람 설정 화면으로 이동 (추후 MethodChannel 등을 통해 구현 가능)
  Future<void> openAlarmSettings() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      debugPrint(
        "[NotificationService] Guide user to: android.settings.REQUEST_SCHEDULE_EXACT_ALARM",
      );
    }
  }

  Future<void> scheduleDailyNotification() async {
    await _scheduleNotificationAt(
      id: 0,
      time: _nextInstanceOfTenPM(),
      isDaily: true,
    );
  }

  // 1분 후 예약을 테스트할 수 있는 기능 추가
  Future<void> scheduleTestNotification() async {
    final now = tz.TZDateTime.now(tz.local);
    final testTime = now.add(const Duration(minutes: 1));
    debugPrint(
      "[NotificationService] Scheduled TEST notification for 1 minute later: $testTime",
    );
    await _scheduleNotificationAt(id: 999, time: testTime, isDaily: false);
  }

  Future<void> _scheduleNotificationAt({
    required int id,
    required tz.TZDateTime time,
    required bool isDaily,
  }) async {
    await cancelAllNotifications();

    final randomIdx = math.Random().nextInt(_randomMessages.length);
    final selectedMessage = _randomMessages[randomIdx];

    final Int64List vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'dream4cut_daily_reminder_v3',
          '매일 밤 꿈 기록 알림 서비스',
          channelDescription: '매일 오후 10시에 꿈 기록을 장려하는 알림입니다.',
          importance: Importance.max,
          priority: Priority.high,
          visibility: NotificationVisibility.public,
          fullScreenIntent: true, // 잠금화면에서도 잘 보이도록 함
          vibrationPattern: vibrationPattern,
          enableVibration: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    debugPrint(
      "[NotificationService] Current local time: ${tz.TZDateTime.now(tz.local)}",
    );
    debugPrint("[NotificationService] Scheduling notification at: $time");

    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: selectedMessage['title'],
        body: selectedMessage['body'],
        scheduledDate: time,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: isDaily ? DateTimeComponents.time : null,
      );
      debugPrint(
        "[NotificationService] ✅ Notification successfully scheduled for: $time",
      );
    } catch (e) {
      debugPrint(
        "[NotificationService] ⚠️ Exact schedule failed, trying fallback: $e",
      );
      try {
        await flutterLocalNotificationsPlugin.zonedSchedule(
          id: id,
          title: selectedMessage['title'],
          body: selectedMessage['body'],
          scheduledDate: time,
          notificationDetails: notificationDetails,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          matchDateTimeComponents: isDaily ? DateTimeComponents.time : null,
        );
        debugPrint(
          "[NotificationService] ✅ Inexact notification scheduled as fallback.",
        );
      } catch (e2) {
        debugPrint("[NotificationService] ❌ Fatal error in scheduling: $e2");
      }
    }
  }

  Future<void> showImmediateNotification() async {
    // 권한은 첫 실행 시 이미 요청됨

    // 테스트 시에도 동일한 랜덤 문구 중 하나를 선택하도록 변경
    final randomIdx = math.Random().nextInt(_randomMessages.length);
    final selectedMessage = _randomMessages[randomIdx];

    final Int64List vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    final AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'dream4cut_daily_reminder_v3', // 실제 채널 ID와 동일하게 설정하여 테스트
          '매일 밤 꿈 기록 알림 서비스',
          channelDescription: '매일 오후 10시에 꿈 기록을 장려하는 알림입니다.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          vibrationPattern: vibrationPattern,
          enableVibration: true,
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await flutterLocalNotificationsPlugin.show(
      id: 99,
      title: "[테스트] ${selectedMessage['title']}", // 테스트임을 명시
      body: selectedMessage['body'],
      notificationDetails: notificationDetails,
    );
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  tz.TZDateTime _nextInstanceOfTenPM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      22,
      0,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
