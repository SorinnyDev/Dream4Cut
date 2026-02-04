import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../widgets/analog_widgets.dart';
import '../models/goal.dart';
import 'detail_view.dart';
import 'goal_create_view.dart';
import 'archived_goals_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GoalProvider>(
      builder: (context, provider, child) {
        final maxFrameIndex = provider.goals.isNotEmpty
            ? provider.goals.map((g) => g.frameIndex).reduce(math.max)
            : 0;
        final frameCount = math.max(maxFrameIndex + 2, 2);

        return SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: PaperTexturePainter()),
                ),
              ),
              Column(
                children: [
                  // Condensed Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '나의 꿈 기록장',
                          style: AppTheme.titleMedium.copyWith(
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.collections_bookmark_outlined),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ArchivedGoalsView(),
                              ),
                            );
                          },
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
                        return _buildGoalFrame(provider, frameIndex);
                      },
                    ),
                  ),

                  // Indicator
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildGoalFrame(GoalProvider provider, int frameIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: AppTheme.cardShadow,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(
            color: AppTheme.pencilDash.withOpacity(0.4),
            width: 0.5,
          ),
        ),
        child: Column(
          children: List.generate(4, (slotIndex) {
            final goal = provider.getGoalAt(frameIndex, slotIndex);
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
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: AppTheme.ivoryPaper.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppTheme.pencilDash.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.textTertiary.withOpacity(0.3),
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  '새로운 조각을 기다려요',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textTertiary.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final themeIndex = AppTheme.getThemeIndex(goal!.backgroundTheme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    final cardRandom = math.Random(goal!.id.hashCode);
    final tapeRotation = (cardRandom.nextDouble() - 0.5) * 0.15;
    final tapePosition = 15.0 + (cardRandom.nextDouble() * 30);

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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: HandDrawnContainer(
          showStackEffect: true,
          backgroundColor: themeSet.background,
          borderColor: themeSet.text.withOpacity(0.2),
          padding: EdgeInsets.zero,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                child: Center(
                  child: Text(
                    goal!.title,
                    style: AppTheme.titleSmall.copyWith(
                      color: themeSet.text,
                      fontWeight: FontWeight.w900,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Positioned(
                left: tapePosition,
                top: -8,
                child: MaskingTape(
                  rotation: tapeRotation,
                  color: themeSet.point,
                  opacity: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
