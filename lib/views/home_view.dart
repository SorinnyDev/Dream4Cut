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

        return Container(
          color: AppTheme.premiumCream, // 프리미엄 크림 배경
          child: SafeArea(
            child: Stack(
              children: [
                // 배경 텍스처 및 비네팅
                Positioned.fill(
                  child: IgnorePointer(
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: NoiseTexturePainter(opacity: 0.03),
                        ),
                        Container(decoration: AppTheme.getVignetteDecoration()),
                      ],
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (Left Aligned, Top Padding 40+)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 48, 20, 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '나의 꿈 기록장',
                                style: AppTheme.handwritingLarge.copyWith(
                                  color: AppTheme.warmBrown, // 따뜻한 브라운
                                  fontSize: 28, // 32에서 28로 축소
                                  fontWeight: FontWeight.w600, // w700에서 w600으로
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '오늘의 꿈을 수집해보세요',
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.warmBrown.withOpacity(0.5),
                                  letterSpacing: 0.5,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Bounceable(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const ArchivedGoalsView(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppTheme.pencilDash.withOpacity(0.3),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  '서랍장',
                                  style: AppTheme.handwritingMedium.copyWith(
                                    color: AppTheme.warmBrown,
                                    fontWeight:
                                        FontWeight.w500, // bold에서 w500으로
                                    fontSize: 14, // 15에서 14로
                                  ),
                                ),
                              ),
                            ),
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
                      padding: const EdgeInsets.only(bottom: 24),
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
                                  : AppTheme.pencilCharcoal.withOpacity(0.15),
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
          ),
        );
      },
    );
  }

  Widget _buildGoalFrame(GoalProvider provider, int frameIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.42; // 42% 너비

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Wrap(
        spacing: 16, // 가로 간격
        runSpacing: 0, // 세로 간격 (지그재그로 제어)
        alignment: WrapAlignment.center,
        children: List.generate(4, (slotIndex) {
          final goal = provider.getGoalAt(frameIndex, slotIndex);
          final isRightColumn = slotIndex % 2 == 1; // 오른쪽 열

          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(
              top: isRightColumn ? 32 : 0, // 지그재그 효과
              bottom: 16,
            ),
            child: _GoalFrameItem(
              goal: goal,
              frameIndex: frameIndex,
              slotIndex: slotIndex,
            ),
          );
        }),
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
        child: AspectRatio(
          aspectRatio: 3 / 4, // 3:4 비율
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.ivoryPaper.withOpacity(0.5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppTheme.pencilDash.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A3E2723),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0x333E2723),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.pencilDash.withOpacity(0.3),
                        width: 2,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: AppTheme.textTertiary.withOpacity(0.3),
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
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
        ),
      );
    }

    final cardRandom = math.Random(goal!.id.hashCode);
    final rotationAngle =
        (cardRandom.nextDouble() - 0.5) * 0.052; // -1.5도 ~ +1.5도

    final themeIndex = AppTheme.getThemeIndex(goal!.backgroundTheme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    final tapeRotation = (cardRandom.nextDouble() - 0.5) * 0.12;
    // 테이프를 중앙에서 약간 치우치게
    final tapeOffsetFromCenter =
        (cardRandom.nextDouble() - 0.5) * 40; // -20 ~ +20px

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
      child: Transform.rotate(
        angle: rotationAngle,
        child: AspectRatio(
          aspectRatio: 3 / 4, // 3:4 비율
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A3E2723),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: const Color(0x333E2723),
                  offset: const Offset(0, 2),
                  blurRadius: 4,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                final tapeLeft = (cardWidth / 2) - 30 + tapeOffsetFromCenter;

                return Column(
                  children: [
                    // 상단 65% - 테마색 영역
                    Expanded(
                      flex: 65,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: themeSet.background,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Center(
                              child: Transform.rotate(
                                angle:
                                    (cardRandom.nextDouble() - 0.5) *
                                    0.08, // 이모지 미세 회전
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.15),
                                        offset: const Offset(0, 4),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    goal!.emojiTag,
                                    style: const TextStyle(
                                      fontSize: 72,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: tapeLeft,
                            top: 4,
                            child: MaskingTape(
                              rotation: tapeRotation,
                              color: themeSet.point,
                              opacity: 0.7,
                              height: 24, // 24px 고정
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 하단 35% - 기록 영역
                    Expanded(
                      flex: 35,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          goal!.title,
                          style: AppTheme.handwritingSmall.copyWith(
                            color: AppTheme.warmBrown,
                            fontSize: 15, // 15sp
                            letterSpacing: 0.5, // 0.5px 자간
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
