import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';
import 'detail_view.dart';

/// 메인 홈 화면 - 1x4 세로 고정 프레임 레이아웃
class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 임시 데이터 (나중에 상태 관리 프레임워크나 DB 연동 가능)
    final List<Goal> mockGoals = [
      Goal(
        id: '1',
        title: '매일 아침 스트레칭',
        backgroundTheme: 'pastel_pink',
        totalCount: 245,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      Goal(
        id: '2',
        title: '경제/IT 뉴스 읽기',
        backgroundTheme: 'pastel_blue',
        totalCount: 88,
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        updatedAt: DateTime.now(),
      ),
      Goal(
        id: '3',
        title: '물 2L 마시기',
        backgroundTheme: 'pastel_mint',
        totalCount: 12,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
      Goal(
        id: '4',
        title: '새로운 목표 추가하기',
        backgroundTheme: 'pastel_yellow',
        totalCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppTheme.spacingL),
              // 상단 타이틀
              Text(
                '드림포컷 (Dream4Cut)',
                style: AppTheme.headingLarge.copyWith(
                  letterSpacing: 2.0,
                  color: AppTheme.textPrimary.withOpacity(0.8),
                ),
              ),
              const SizedBox(height: AppTheme.spacingS),
              Text(
                '너의 발걸음을 기록해',
                style: AppTheme.bodySmall.copyWith(
                  letterSpacing: 1.2,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),

              // 1x4 프레임 컨테이너
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppTheme.spacingM),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: AppTheme.paperShadow,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Column(
                    children: List.generate(4, (index) {
                      final goal = mockGoals[index];
                      return Expanded(
                        child: _GoalFrameItem(goal: goal, index: index),
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
            ],
          ),
        ),
      ),
    );
  }
}

/// 개별 목표 프레임 아이템 (1x4 중 하나)
class _GoalFrameItem extends StatelessWidget {
  final Goal goal;
  final int index;

  const _GoalFrameItem({required this.goal, required this.index});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailView(goal: goal)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.getPastelColor(index).withOpacity(0.15),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.pencilDash.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            // 배경 장식 (모서리에 아날로그 느낌 점선)
            Positioned(
              right: 12,
              bottom: 12,
              child: Opacity(
                opacity: 0.2,
                child: Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: AppTheme.getPastelColor(index),
                ),
              ),
            ),

            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    goal.title,
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppTheme.spacingS),

                  // 하단 누적 정보
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoBadge('Total', '${goal.totalCount}'),
                      const SizedBox(width: AppTheme.spacingS),
                      _buildInfoBadge(
                        'Progress',
                        '${goal.currentSheetProgress}/200',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
