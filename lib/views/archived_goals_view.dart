import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';

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
      body: Consumer<GoalProvider>(
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
                child: Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: AppTheme.cardShadow,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(goal.title, style: AppTheme.headingSmall),
                            Text(
                              '수집 횟수: ${goal.totalCount}',
                              style: AppTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => provider.restoreGoal(goal.id),
                        child: const Text('복원'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
