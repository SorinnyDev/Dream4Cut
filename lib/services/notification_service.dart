import 'dart:math' as math;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
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
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));
    } catch (e) {
      // Fallback to UTC if timezone detection fails
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

  Future<void> scheduleDailyNotification() async {
    // 권한 요청은 SettingsProvider에서 첫 실행 시 1회만 처리함
    // (여기서 다시 호출하면 팝업이 중복으로 뜸)

    await cancelAllNotifications();

    // 5개의 문구 중 랜덤 선택
    final randomIdx = math.Random().nextInt(_randomMessages.length);
    final selectedMessage = _randomMessages[randomIdx];

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'dream4cut_daily_reminder',
          '매일 밤 꿈 기록 알림',
          channelDescription: '매일 오후 10시에 꿈 기록을 장려하는 알림입니다.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: false,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
    );

    final scheduledDate = _nextInstanceOfTenPM();
    debugPrint("[NotificationService] Scheduling for: $scheduledDate");

    // 1. 정확한 알람 예약 시도
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: selectedMessage['title'],
        body: selectedMessage['body'],
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
        "[NotificationService] ✅ Exact alarm scheduled successfully for: $scheduledDate",
      );
      return;
    } catch (e) {
      debugPrint("[NotificationService] ⚠️ Exact alarm failed: $e");
    }

    // 2. 정확한 알람 실패 시 inexact 모드로 폴백
    try {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: 0,
        title: selectedMessage['title'],
        body: selectedMessage['body'],
        scheduledDate: scheduledDate,
        notificationDetails: notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint(
        "[NotificationService] ✅ Inexact alarm scheduled (fallback) for: $scheduledDate",
      );
    } catch (e) {
      debugPrint("[NotificationService] ❌ All scheduling attempts failed: $e");
    }
  }

  Future<void> showImmediateNotification() async {
    // 권한은 첫 실행 시 이미 요청됨

    // 테스트 시에도 동일한 랜덤 문구 중 하나를 선택하도록 변경
    final randomIdx = math.Random().nextInt(_randomMessages.length);
    final selectedMessage = _randomMessages[randomIdx];

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'dream4cut_daily_reminder', // 실제 채널 ID와 동일하게 설정하여 테스트
          '매일 밤 꿈 기록 알림',
          channelDescription: '매일 오후 10시에 꿈 기록을 장려하는 알림입니다.',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: DarwinNotificationDetails(),
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
