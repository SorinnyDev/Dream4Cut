import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'archived_goals_view.dart';

/// 설정 화면 - 앱 설정 및 테마 관리
class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        children: [
          const SizedBox(height: AppTheme.spacingXl),
          Text('내 서랍', style: AppTheme.headingLarge),
          const SizedBox(height: AppTheme.spacingL),
          _buildSettingsItem(
            context,
            Icons.inventory_2_rounded,
            '보관된 목표 (서랍)',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ArchivedGoalsView()),
            ),
          ),
          _buildSettingsItem(context, Icons.palette_outlined, '테마 설정'),
          _buildSettingsItem(
            context,
            Icons.notifications_none_rounded,
            '기록 알림',
          ),
          _buildSettingsItem(context, Icons.cloud_upload_outlined, '데이터 백업'),
          _buildSettingsItem(context, Icons.info_outline_rounded, '앱 정보'),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context,
    IconData icon,
    String title, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppTheme.spacingM),
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary),
            const SizedBox(width: AppTheme.spacingM),
            Text(title, style: AppTheme.bodyLarge),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
