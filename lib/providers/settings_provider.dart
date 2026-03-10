import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  static const String _notificationKey = 'is_notification_enabled';
  static const String _homeBackgroundKey = 'home_background_index';
  // 최초 설치 여부를 판단하는 키
  static const String _hasInitializedKey = 'has_initialized_v1';

  final NotificationService _notificationService = NotificationService();

  bool _isNotificationEnabled = true; // 기본값: 허용
  bool _isExactAlarmAllowed = true; // 정확한 알람 허용 여부
  int _homeBackgroundIndex = 0;

  bool get isNotificationEnabled => _isNotificationEnabled;
  bool get isExactAlarmAllowed => _isExactAlarmAllowed;
  int get homeBackgroundIndex => _homeBackgroundIndex;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasInitialized = prefs.getBool(_hasInitializedKey) ?? false;

    // 시스템 권한 상태 확인
    _isExactAlarmAllowed = await _notificationService
        .checkExactAlarmPermission();

    if (!hasInitialized) {
      // ─── 첫 설치·첫 실행 ───
      _isNotificationEnabled = true;
      _homeBackgroundIndex = 0;

      await prefs.setBool(_notificationKey, true);
      await prefs.setInt(_homeBackgroundKey, 0);
      await prefs.setBool(_hasInitializedKey, true);

      debugPrint("[SettingsProvider] 첫 실행 감지 → 알림 권한 요청 및 예약");
      final bool granted = await _notificationService.requestPermissions();

      if (granted) {
        _isNotificationEnabled = true;
        await prefs.setBool(_notificationKey, true);
        await _notificationService.scheduleDailyNotification();
      } else {
        _isNotificationEnabled = false;
        await prefs.setBool(_notificationKey, false);
      }
    } else {
      // ─── 재실행 ───
      _isNotificationEnabled = prefs.getBool(_notificationKey) ?? true;
      _homeBackgroundIndex = prefs.getInt(_homeBackgroundKey) ?? 0;

      if (_isNotificationEnabled) {
        _notificationService.scheduleDailyNotification();
      }
    }

    notifyListeners();
  }

  Future<void> setHomeBackgroundIndex(int index) async {
    _homeBackgroundIndex = index;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_homeBackgroundKey, index);
  }

  Future<void> setNotificationEnabled(bool value) async {
    _isNotificationEnabled = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationKey, value);

      if (value) {
        await _notificationService.scheduleDailyNotification();
      } else {
        await _notificationService.cancelAllNotifications();
      }
    } catch (e) {
      debugPrint("[SettingsProvider] Notification Error: $e");
    }
  }
}
