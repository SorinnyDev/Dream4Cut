import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../widgets/analog_widgets.dart';

class ArchivedGoalsView extends StatelessWidget {
  const ArchivedGoalsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        title: const Text('보관된 목표'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Consumer<GoalProvider>(
          builder: (context, provider, child) {
            final archivedGoals = provider.archivedGoals;

            if (archivedGoals.isEmpty) {
              return Center(
                child: Text('보관된 수집품이 없습니다.', style: AppTheme.bodyMedium),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(AppTheme.spacingL),
              itemCount: archivedGoals.length,
              itemBuilder: (context, index) {
                final goal = archivedGoals[index];
                final themeIndex = AppTheme.getThemeIndex(goal.backgroundTheme);
                final themeSet = AppTheme.getGoalTheme(themeIndex);

                // Sepia-like filter using ColorFiltered
                return ColorFiltered(
                  colorFilter: const ColorFilter.matrix([
                    0.393,
                    0.769,
                    0.189,
                    0,
                    0,
                    0.349,
                    0.686,
                    0.168,
                    0,
                    0,
                    0.272,
                    0.534,
                    0.131,
                    0,
                    0,
                    0,
                    0,
                    0,
                    1,
                    0,
                  ]),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: HandDrawnContainer(
                      backgroundColor: themeSet.background,
                      borderColor: themeSet.text.withOpacity(0.1),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  goal.title,
                                  style: AppTheme.headingSmall.copyWith(
                                    color: themeSet.text,
                                  ),
                                ),
                                Text(
                                  '수집 횟수: ${goal.totalCount}',
                                  style: AppTheme.caption.copyWith(
                                    color: themeSet.text.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () => provider.restoreGoal(goal.id),
                            child: Text(
                              '복원',
                              style: TextStyle(
                                color: themeSet.point,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
