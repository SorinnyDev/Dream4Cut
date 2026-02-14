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
    final cardWidth = screenWidth * 0.44; // 너비를 약간 확장

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Wrap(
        spacing: 12,
        runSpacing: 0,
        alignment: WrapAlignment.center,
        children: List.generate(4, (slotIndex) {
          final goal = provider.getGoalAt(frameIndex, slotIndex);
          final isRightColumn = slotIndex % 2 == 1;

          return Container(
            width: cardWidth,
            margin: EdgeInsets.only(
              top: isRightColumn ? 48.0 : 0.0,
              bottom: isRightColumn ? 0.0 : 48.0,
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
    // 공통 그림자 스타일 (Warm Brown 계열 이중 그림자)
    final dualShadows = [
      BoxShadow(
        color: const Color(0x1A3E2723), // Soft
        offset: const Offset(0, 12),
        blurRadius: 32,
        spreadRadius: -4,
      ),
      BoxShadow(
        color: const Color(0x4D3E2723), // Sharp
        offset: const Offset(0, 4),
        blurRadius: 8,
        spreadRadius: 0,
      ),
    ];

    return RepaintBoundary(child: _buildItemContent(context, dualShadows));
  }

  Widget _buildItemContent(BuildContext context, List<BoxShadow> dualShadows) {
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
          aspectRatio: 0.7, // 0.7 Aspect Ratio
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.ivoryPaper.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: AppTheme.pencilDash.withOpacity(0.5),
                width: 1,
              ),
              boxShadow: dualShadows,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.pencilDash.withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: AppTheme.textTertiary.withOpacity(0.3),
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '새로운 조각',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textTertiary.withOpacity(0.6),
                      fontSize: 11,
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
    // 1.5 ~ 2.5도 랜덤 회전 (0.026 ~ 0.043 라디안)
    final baseRotation = 0.026 + (cardRandom.nextDouble() * 0.017);
    final rotationAngle = cardRandom.nextBool() ? baseRotation : -baseRotation;

    final themeIndex = AppTheme.getThemeIndex(goal!.backgroundTheme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    final tapeRotation = (cardRandom.nextDouble() - 0.5) * 0.15;
    final tapeOffsetFromCenter = (cardRandom.nextDouble() - 0.5) * 30;

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
          aspectRatio: 0.7, // 0.7 Aspect Ratio
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2),
              boxShadow: dualShadows,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                return Column(
                  children: [
                    // 상단 65% - 이모지 스테이지
                    Expanded(
                      flex: 65,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: themeSet.background,
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: Center(
                              child: Transform.rotate(
                                angle: (cardRandom.nextDouble() - 0.5) * 0.1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        offset: const Offset(0, 6),
                                        blurRadius: 10,
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    goal!.emojiTag,
                                    style: const TextStyle(
                                      fontSize: 64,
                                      height: 1.0,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: (cardWidth / 2) - 30 + tapeOffsetFromCenter,
                            top: -13,
                            child: MaskingTape(
                              rotation: tapeRotation,
                              color: themeSet.point,
                              opacity: 0.75,
                              height: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 하단 35% - 제목 영역 (#FDFDFD 여백)
                    Expanded(
                      flex: 35,
                      child: Container(
                        color: const Color(0xFFFDFDFD),
                        padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
                        alignment: Alignment.center,
                        child: Text(
                          goal!.title,
                          style: AppTheme.handwritingSmall.copyWith(
                            color: AppTheme.warmBrown,
                            fontSize: 14,
                            letterSpacing: 0.3,
                            fontWeight: FontWeight.w700,
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
