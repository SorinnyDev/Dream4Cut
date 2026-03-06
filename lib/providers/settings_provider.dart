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
  int _homeBackgroundIndex = 0;

  bool get isNotificationEnabled => _isNotificationEnabled;
  int get homeBackgroundIndex => _homeBackgroundIndex;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final bool hasInitialized = prefs.getBool(_hasInitializedKey) ?? false;

    if (!hasInitialized) {
      // ─── 첫 설치·첫 실행 ───
      // 알림을 기본값 '허용'으로 설정하고 권한을 한 번만 요청
      _isNotificationEnabled = true;
      _homeBackgroundIndex = 0;

      await prefs.setBool(_notificationKey, true);
      await prefs.setInt(_homeBackgroundKey, 0);
      await prefs.setBool(_hasInitializedKey, true); // 다음 실행부터는 이 블록 실행 안 됨

      debugPrint("[SettingsProvider] 첫 실행 감지 → 알림 권한 요청 및 예약");
      final bool granted = await _notificationService.requestPermissions();

      if (granted) {
        // 허용: 토글 on + 22:00 알림 예약
        _isNotificationEnabled = true;
        await prefs.setBool(_notificationKey, true);
        await _notificationService.scheduleDailyNotification();
        debugPrint("[SettingsProvider] 권한 허용 → 알림 예약 완료");
      } else {
        // 거부: 토글도 false로 맞춰줌
        _isNotificationEnabled = false;
        await prefs.setBool(_notificationKey, false);
        debugPrint("[SettingsProvider] 권한 거부 → 토글 off 처리");
      }
    } else {
      // ─── 재실행 ───
      // 저장된 설정만 불러오고, 권한은 다시 묻지 않음
      _isNotificationEnabled = prefs.getBool(_notificationKey) ?? true;
      _homeBackgroundIndex = prefs.getInt(_homeBackgroundKey) ?? 0;

      // 알림이 켜져 있다면 앱 재시작 시 예약을 갱신
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
