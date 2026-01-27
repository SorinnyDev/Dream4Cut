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
          final maxFrameIndex = provider.activeGoals.isEmpty
              ? 0
              : provider.activeGoals
                    .map((e) => e.frameIndex)
                    .reduce((a, b) => a > b ? a : b);

          final frameCount = maxFrameIndex + 2;

          return SafeArea(
            child: Column(
              children: [
                // Condensed Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacingM,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'DREAM 4 CUT',
                        style: AppTheme.headingMedium.copyWith(
                          letterSpacing: 4.0,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 2,
                        margin: const EdgeInsets.only(top: 4),
                        color: AppTheme.pencilCharcoal.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),

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

                // Concise Indicators
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
                        width: _currentPage == index ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.pencilCharcoal
                              : AppTheme.pencilCharcoal.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(3),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL,
        vertical: AppTheme.spacingS,
      ),
      child: HandDrawnContainer(
        padding: const EdgeInsets.all(12),
        backgroundColor: Colors.white,
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
      return Bounceable(
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
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
          decoration: BoxDecoration(
            color: AppTheme.ivoryPaper.withOpacity(0.5),
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: AppTheme.pencilDash.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: AppTheme.textTertiary.withOpacity(0.4),
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  '새로운 수집품',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textTertiary.withOpacity(0.5),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final themeIndex = int.tryParse(goal!.backgroundTheme.split('_').last) ?? 0;

    return Bounceable(
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
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          color: AppTheme.getPastelColor(themeIndex).withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: AppTheme.pencilCharcoal, width: 1),
          boxShadow: [
            BoxShadow(
              color: AppTheme.pencilCharcoal.withOpacity(0.1),
              offset: const Offset(1.5, 1.5),
              blurRadius: 0,
            ),
          ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              child: Center(
                child: Text(
                  goal!.title,
                  style: AppTheme.headingSmall.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const Positioned(
              left: 8,
              top: -2,
              child: MaskingTape(width: 30, height: 8, rotation: 0.1),
            ),
          ],
        ),
      ),
    );
  }
}
