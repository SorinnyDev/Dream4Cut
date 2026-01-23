import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../widgets/analog_widgets.dart';
import 'detail_view.dart';
import 'goal_create_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      body: Consumer<GoalProvider>(
        builder: (context, provider, child) {
          // Identify used frame indices
          final maxFrameIndex = provider.activeGoals.isEmpty
              ? 0
              : provider.activeGoals
                    .map((e) => e.frameIndex)
                    .reduce((a, b) => a > b ? a : b);

          final frameCount =
              maxFrameIndex + 2; // Always show an extra empty frame

          return SafeArea(
            child: Column(
              children: [
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  '드림포컷 (Dream4Cut)',
                  style: AppTheme.headingLarge.copyWith(
                    letterSpacing: 2.0,
                    color: AppTheme.textPrimary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingS),
                Text(
                  '나만의 소중한 기록 조각들',
                  style: AppTheme.bodySmall.copyWith(
                    letterSpacing: 1.2,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingXl),

                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemCount: frameCount,
                    itemBuilder: (context, frameIndex) {
                      return _buildFrame(provider, frameIndex);
                    },
                  ),
                ),

                // Indicators
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingM,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(frameCount, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.textPrimary
                              : AppTheme.pencilDash,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrame(GoalProvider provider, int frameIndex) {
    final frameGoals = provider.activeGoals
        .where((g) => g.frameIndex == frameIndex)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingM),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppTheme.paperShadow,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: List.generate(4, (slotIndex) {
            final goal = frameGoals.any((g) => g.slotIndex == slotIndex)
                ? frameGoals.firstWhere((g) => g.slotIndex == slotIndex)
                : null;
            return Expanded(
              child: _GoalFrameItem(
                goal: goal,
                frameIndex: frameIndex,
                slotIndex: slotIndex,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _GoalFrameItem extends StatelessWidget {
  final Goal? goal;
  final int frameIndex;
  final int slotIndex;

  const _GoalFrameItem({
    this.goal,
    required this.frameIndex,
    required this.slotIndex,
  });

  @override
  Widget build(BuildContext context) {
    if (goal == null) {
      return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  GoalCreateView(frameIndex: frameIndex, slotIndex: slotIndex),
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.ivoryPaper,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppTheme.pencilDash.withOpacity(0.5),
              style: BorderStyle.solid,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  color: AppTheme.textTertiary,
                  size: 30,
                ),
                const SizedBox(height: 4),
                Text('새로운 수집품', style: AppTheme.caption),
              ],
            ),
          ),
        ),
      );
    }

    final themeIndex = int.tryParse(goal!.backgroundTheme.split('_').last) ?? 0;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailView(goal: goal!)),
        );
        if (result == true && context.mounted) {
          context.read<GoalProvider>().setTabIndex(1);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.getPastelColor(themeIndex).withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.pencilDash.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 8,
              top: 8,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  Icons.stars,
                  size: 40,
                  color: AppTheme.getPastelColor(themeIndex),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    goal!.title,
                    style: AppTheme.headingSmall.copyWith(
                      color: AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spacingS),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildInfoBadge('Stamp', '${goal!.totalCount}')],
                  ),
                ],
              ),
            ),
            const Positioned(
              left: 10,
              top: 0,
              child: MaskingTape(width: 40, height: 10, rotation: 0.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value',
        style: AppTheme.caption.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: 9,
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }
}
