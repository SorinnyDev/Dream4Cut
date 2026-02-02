import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import '../widgets/analog_widgets.dart';
import 'package:intl/intl.dart';

class FootstepsView extends StatelessWidget {
  const FootstepsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: PaperTexturePainter()),
              ),
            ),
            Consumer<GoalProvider>(
              builder: (context, provider, child) {
                final completedGoals = provider.completedGoals;

                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const SizedBox(height: AppTheme.spacingM),
                      TabBar(
                        indicatorColor: AppTheme.textPrimary,
                        labelColor: AppTheme.textPrimary,
                        unselectedLabelColor: AppTheme.textTertiary,
                        labelStyle: AppTheme.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        tabs: const [
                          Tab(text: '추억 앨범'),
                          Tab(text: '나의 발걸음'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAlbumSection(completedGoals),
                            _buildStatsSection(provider.goals),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlbumSection(List<Goal> goals) {
    if (goals.isEmpty) {
      return Center(child: Text('아직 완성된 추억이 없어요.', style: AppTheme.bodyMedium));
    }

    // Group by year
    final Map<int, List<Goal>> goalsByYear = {};
    for (var goal in goals) {
      final year = goal.completedAt?.year ?? goal.createdAt.year;
      goalsByYear.putIfAbsent(year, () => []).add(goal);
    }

    final sortedYears = goalsByYear.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      itemCount: sortedYears.length,
      itemBuilder: (context, index) {
        final year = sortedYears[index];
        final yearGoals = goalsByYear[year]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$year년의 기록',
              style: AppTheme.headingMedium.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              itemCount: yearGoals.length,
              itemBuilder: (context, gIndex) {
                final goal = yearGoals[gIndex];
                final themeIndex = AppTheme.getThemeIndex(goal.backgroundTheme);
                final themeSet = AppTheme.getGoalTheme(themeIndex);

                return HandDrawnContainer(
                  backgroundColor: themeSet.background,
                  borderColor: themeSet.text.withOpacity(0.1),
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  goal.title,
                                  style: AppTheme.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: themeSet.text,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 0,
                              left: 10,
                              child: MaskingTape(
                                rotation: -0.05,
                                color: themeSet.point,
                                opacity: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Sketchy Divider
                      Container(
                        height: 1,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        color: themeSet.text.withOpacity(0.1),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          goal.completedAt != null
                              ? DateFormat('yy.MM.dd').format(goal.completedAt!)
                              : '',
                          style: AppTheme.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: themeSet.text.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        );
      },
    );
  }

  Widget _buildStatsSection(List<Goal> allGoals) {
    final totalSteps = allGoals.fold(0, (sum, g) => sum + g.totalCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        children: [
          HandDrawnContainer(
            child: Column(
              children: [
                Text(
                  '누적 발걸음',
                  style: AppTheme.headingSmall.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalSteps회',
                  style: AppTheme.headingLarge.copyWith(
                    fontSize: 44,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.getDeepMutedColor(0),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // 200 footsteps sheet design
          Text(
            '최근 수집 현황',
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 10,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 200,
            itemBuilder: (context, index) {
              final isFilled = index < (totalSteps % 200);
              return Container(
                decoration: BoxDecoration(
                  color: isFilled
                      ? AppTheme.getGoalTheme(0).point.withOpacity(0.3)
                      : Colors.white,
                  border: Border.all(
                    color: isFilled
                        ? AppTheme.getGoalTheme(0).point.withOpacity(0.5)
                        : AppTheme.pencilDash.withOpacity(0.3),
                  ),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          Text(
            '${totalSteps % 200} / 200',
            style: AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
