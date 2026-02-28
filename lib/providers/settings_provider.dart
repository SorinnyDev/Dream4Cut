import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class SettingsProvider with ChangeNotifier {
  static const String _notificationKey = 'is_notification_enabled';
  final NotificationService _notificationService = NotificationService();

  bool _isNotificationEnabled = false;

  bool get isNotificationEnabled => _isNotificationEnabled;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isNotificationEnabled = prefs.getBool(_notificationKey) ?? false;
    notifyListeners();
  }

  Future<void> setNotificationEnabled(bool value) async {
    _isNotificationEnabled = value;
    notifyListeners(); // UI 즉시 반영

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
      // 에러 상황에서도 상태 유지를 위해 다시 알림을 보내지는 않지만 로그 기록
    }
  }
}
