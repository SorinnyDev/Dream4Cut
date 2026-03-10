import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

class NotificationSettingsView extends StatelessWidget {
  const NotificationSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        title: Text('기록 알림 설정', style: AppTheme.handwritingMedium),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<SettingsProvider>(
        builder: (BuildContext context, SettingsProvider settings, Widget? child) {
          return ListView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            children: <Widget>[
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  settings.setNotificationEnabled(
                    !settings.isNotificationEnabled,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingM,
                    vertical: AppTheme.spacingM,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('데일리 리마인더', style: AppTheme.bodyLarge),
                            const SizedBox(height: 4),
                            Text(
                              '지나가는 하루 속, 잊고 싶지 않은 순간들을 기록해보세요.',
                              style: AppTheme.bodySmall.copyWith(
                                fontSize: 13,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: settings.isNotificationEnabled,
                        activeColor: AppTheme.warmBrown,
                        onChanged: (bool value) {
                          settings.setNotificationEnabled(value);
                        },
                      ),
                    ],
                  ),
                ),
              ),

              if (settings.isNotificationEnabled &&
                  !settings.isExactAlarmAllowed)
                Container(
                  margin: const EdgeInsets.only(top: AppTheme.spacingM),
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                    border: Border.all(color: Colors.red.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '정확한 알림 권한 필요',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.red.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '안드로이드 시스템의 배터리 최적화 정책으로 인해 알림이 늦게 도착할 수 있습니다. 정확한 시간에 알림을 받으려면 시스템 설정에서 \'알람 및 리마인더\' 권한을 허용해 주세요.',
                        style: AppTheme.bodySmall.copyWith(
                          color: Colors.red.shade700,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 32),
              // 시스템 신뢰성 테스트용 버튼
              OutlinedButton.icon(
                onPressed: () async {
                  await NotificationService().scheduleTestNotification();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '1분 후 시점의 예약 시스템을 테스트합니다. 앱을 백그라운드로 내려주세요.',
                        ),
                        backgroundColor: AppTheme.warmBrown,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.timer_outlined, size: 20),
                label: const Text('예약 시스템 테스트 (1분 후)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warmBrown,
                  side: const BorderSide(color: AppTheme.warmBrown),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '* 위 버튼은 실제 밤 10시 알림과 동일한 예약 방식으로 동작합니다.\n테스트 시 앱을 완전히 끄고(백그라운드) 기다려 보시기 바랍니다.',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}
