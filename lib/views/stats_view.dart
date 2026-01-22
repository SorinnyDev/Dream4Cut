import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 통계 화면 - 누적 발자국 확인
class StatsView extends StatelessWidget {
  const StatsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_graph_rounded,
              size: 64,
              color: AppTheme.pencilDash,
            ),
            const SizedBox(height: AppTheme.spacingM),
            Text('차곡차곡 쌓인 발걸음', style: AppTheme.headingMedium),
            const SizedBox(height: AppTheme.spacingS),
            Text('곧 통계 데이터가 준비될 거예요!', style: AppTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
