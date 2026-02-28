import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

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
        builder:
            (BuildContext context, SettingsProvider settings, Widget? child) {
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
                ],
              );
            },
      ),
    );
  }
}
