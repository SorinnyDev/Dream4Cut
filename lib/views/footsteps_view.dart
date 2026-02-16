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
    final stopwatch = Stopwatch()..start();
    final result = Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: PaperTexturePainter()),
                ),
              ),
            ),
            Selector<GoalProvider, List<Goal>>(
              selector: (context, provider) => provider.completedGoals,
              builder: (context, completedGoals, child) {
                return DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      const SizedBox(height: AppTheme.spacingM),
                      TabBar(
                        indicatorColor: AppTheme.textPrimary,
                        indicatorWeight: 2,
                        labelColor: AppTheme.textPrimary,
                        unselectedLabelColor: AppTheme.textTertiary.withOpacity(
                          0.5,
                        ),
                        labelStyle: AppTheme.bodyBold,
                        tabs: const [
                          Tab(text: '꿈의 앨범'),
                          Tab(text: '나의 여정'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildAlbumSection(completedGoals),
                            Selector<GoalProvider, List<Goal>>(
                              selector: (context, provider) => provider.goals,
                              builder: (context, allGoals, _) {
                                return _buildStatsSection(allGoals);
                              },
                            ),
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

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed > 16) {
      debugPrint(
        "[Performance Warning] FootstepsView Build Time: ${elapsed}ms",
      );
    }
    return result;
  }

  Widget _buildAlbumSection(List<Goal> goals) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 48,
              color: AppTheme.textTertiary.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            Text('아직 완성된 꿈의 조각이 없어요.', style: AppTheme.bodyRegular),
          ],
        ),
      );
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
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 20),
              child: Text(
                '$year년의 발걸음',
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 24,
                childAspectRatio: 0.85,
              ),
              itemCount: yearGoals.length,
              itemBuilder: (context, gIndex) {
                final goal = yearGoals[gIndex];
                final themeIndex = AppTheme.getThemeIndex(goal.backgroundTheme);
                final themeSet = AppTheme.getGoalTheme(themeIndex);

                return HandDrawnContainer(
                  showStackEffect: true,
                  backgroundColor: themeSet.background,
                  borderColor: themeSet.text.withOpacity(0.12),
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Expanded(
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  goal.title,
                                  style: AppTheme.bodyBold.copyWith(
                                    color: themeSet.text,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -6,
                              left: 10,
                              child: MaskingTape(
                                rotation: -0.04,
                                color: themeSet.point,
                                opacity: 0.7,
                                height: 26,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 1,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: themeSet.text.withOpacity(0.08),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Text(
                          goal.completedAt != null
                              ? DateFormat('yy.MM.dd').format(goal.completedAt!)
                              : '',
                          style: AppTheme.labelSmall.copyWith(
                            fontWeight: FontWeight.w900,
                            color: themeSet.text.withOpacity(0.4),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 48),
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
            backgroundColor: Colors.white.withOpacity(0.9),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              children: [
                Text(
                  '꿈을 향한 누적 발걸음',
                  style: AppTheme.bodyBold.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalSteps',
                  style: AppTheme.titleLarge.copyWith(
                    fontSize: 52,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.pencilCharcoal,
                  ),
                ),
                Text(
                  'STEPS',
                  style: AppTheme.labelSmall.copyWith(
                    letterSpacing: 4.0,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),

          Row(
            children: [
              const SizedBox(width: 4),
              Icon(
                Icons.grid_view_rounded,
                size: 20,
                color: AppTheme.textSecondary.withOpacity(0.6),
              ),
              const SizedBox(width: 8),
              Text(
                '기록의 조각들 모음',
                style: AppTheme.bodyBold.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.ivoryPaper.withOpacity(0.4),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.pencilCharcoal.withOpacity(0.05),
              ),
            ),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
                mainAxisSpacing: 5,
                crossAxisSpacing: 5,
              ),
              itemCount: 200,
              itemBuilder: (context, index) {
                final isFilled = index < (totalSteps % 200);
                return Container(
                  decoration: BoxDecoration(
                    color: isFilled
                        ? AppTheme.getGoalTheme(0).point.withOpacity(0.5)
                        : Colors.white.withOpacity(0.7),
                    border: Border.all(
                      color: isFilled
                          ? AppTheme.getGoalTheme(0).text.withOpacity(0.4)
                          : AppTheme.pencilCharcoal.withOpacity(0.15),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(1.5),
                  ),
                  child: isFilled
                      ? const Center(
                          child: Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Text(
                '${totalSteps % 200} / 200 steps',
                style: AppTheme.labelSmall.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textSecondary.withOpacity(0.6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
