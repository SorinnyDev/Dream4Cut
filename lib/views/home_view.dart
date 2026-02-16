import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import '../widgets/analog_widgets.dart';
import 'archived_goals_view.dart';
import 'dart:math' as math;
import 'goal_create_view.dart';
import 'detail_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();

    final result = Selector<GoalProvider, _HomeViewStateData>(
      selector: (BuildContext context, GoalProvider provider) =>
          _HomeViewStateData(
            goals: provider.goals,
            isLoading: provider.isLoading,
          ),
      shouldRebuild: (_HomeViewStateData prev, _HomeViewStateData next) {
        return prev.isLoading != next.isLoading || prev.goals != next.goals;
      },
      builder: (BuildContext context, _HomeViewStateData data, Widget? child) {
        if (data.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.warmBrown),
          );
        }

        final List<Goal> goals = data.goals;
        final int maxFrameIndex = goals.isNotEmpty
            ? goals.map((Goal g) => g.frameIndex).reduce(math.max)
            : 0;
        final int totalFrames = math.max(maxFrameIndex + 2, 2);

        return Container(
          color: AppTheme.premiumCream,
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                // 배경 텍스처 (Impeller 최적화: 정적 레이어 RepaintBoundary 격리)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: RepaintBoundary(
                      child: Stack(
                        children: <Widget>[
                          CustomPaint(
                            painter: NoiseTexturePainter(opacity: 0.03),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: <Color>[
                                  Colors.transparent,
                                  Color(0x1A000000),
                                ],
                                stops: <double>[0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    // 헤더 영역
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 40, 24, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                '나의 꿈 기록장',
                                style: AppTheme.handwritingLarge.copyWith(
                                  color: AppTheme.warmBrown,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '오늘의 꿈을 수집해보세요',
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.warmBrown.withOpacity(0.5),
                                  letterSpacing: 0.5,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Bounceable(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<void>(
                                  builder: (BuildContext context) =>
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
                                boxShadow: <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                '서랍장',
                                style: AppTheme.handwritingMedium.copyWith(
                                  color: AppTheme.warmBrown,
                                  fontWeight: FontWeight.w700,
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
                        itemCount: totalFrames,
                        onPageChanged: (int index) {
                          _currentPageNotifier.value = index;
                        },
                        itemBuilder: (BuildContext context, int frameIndex) {
                          return _buildGoalFrame(context, frameIndex);
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                    ValueListenableBuilder<int>(
                      valueListenable: _currentPageNotifier,
                      builder:
                          (BuildContext context, int currentPage, Widget? _) {
                            return _buildPageIndicator(
                              totalFrames,
                              currentPage,
                            );
                          },
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    final int elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed > 16) {
      debugPrint("[Performance Warning] HomeView Build Time: ${elapsed}ms");
    }
    return result;
  }

  Widget _buildGoalFrame(BuildContext context, int frameIndex) {
    // 인생네컷 감성: 지그재그(Staggered) 레이아웃 구현
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        // 크기를 소폭 줄여 카드 간 상호 간섭 최소화
        final double cardWidth = constraints.maxWidth * 0.48;
        final double cardHeight = constraints.maxHeight * 0.42;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            // Slot 0: 상단 좌측
            Positioned(
              top: constraints.maxHeight * 0.03,
              left: constraints.maxWidth * 0.02,
              width: cardWidth,
              height: cardHeight,
              child: _GoalFrameItem(
                frameIndex: frameIndex,
                slotIndex: 0,
                rotation: -0.05,
              ),
            ),
            // Slot 1: 상단 우측 (약간 더 아래로 내려서 Slot 0 제목과 격리)
            Positioned(
              top: constraints.maxHeight * 0.12,
              right: constraints.maxWidth * 0.02,
              width: cardWidth,
              height: cardHeight,
              child: _GoalFrameItem(
                frameIndex: frameIndex,
                slotIndex: 1,
                rotation: 0.04,
              ),
            ),
            // Slot 2: 하단 좌측 (가운데 위주, Slot 0과 겹침 최소화)
            Positioned(
              top: constraints.maxHeight * 0.50,
              left: constraints.maxWidth * 0.04,
              width: cardWidth,
              height: cardHeight,
              child: _GoalFrameItem(
                frameIndex: frameIndex,
                slotIndex: 2,
                rotation: 0.03,
              ),
            ),
            // Slot 3: 하단 우측 (가장 아래, Slot 1 제목과 격리)
            Positioned(
              top: constraints.maxHeight * 0.56,
              right: constraints.maxWidth * 0.02,
              width: cardWidth,
              height: cardHeight,
              child: _GoalFrameItem(
                frameIndex: frameIndex,
                slotIndex: 3,
                rotation: -0.06,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPageIndicator(int count, int current) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List<Widget>.generate(count, (int index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: current == index ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: current == index
                ? AppTheme.warmBrown
                : AppTheme.warmBrown.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}

class _GoalFrameItem extends StatelessWidget {
  final int frameIndex;
  final int slotIndex;
  final double rotation;

  const _GoalFrameItem({
    required this.frameIndex,
    required this.slotIndex,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    return Selector<GoalProvider, Goal?>(
      selector: (BuildContext context, GoalProvider provider) =>
          provider.getGoalAt(frameIndex, slotIndex),
      builder: (BuildContext context, Goal? goal, Widget? child) {
        if (goal == null) {
          return Transform.rotate(
            angle: rotation,
            child: Bounceable(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => GoalCreateView(
                      frameIndex: frameIndex,
                      slotIndex: slotIndex,
                    ),
                  ),
                );
              },
              child: HandDrawnContainer(
                backgroundColor: Colors.white.withOpacity(0.4),
                borderColor: AppTheme.pencilDash.withOpacity(0.2),
                showOffsetLayer: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add_rounded,
                        color: AppTheme.warmBrown.withOpacity(0.1),
                        size: 30,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '새로운 조각',
                        style: AppTheme.handwritingSmall.copyWith(
                          color: AppTheme.warmBrown.withOpacity(0.25),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        return PolaroidGoalCard(goal: goal, rotation: rotation);
      },
    );
  }
}

class PolaroidGoalCard extends StatelessWidget {
  final Goal goal;
  final double rotation;

  const PolaroidGoalCard({
    super.key,
    required this.goal,
    required this.rotation,
  });

  @override
  Widget build(BuildContext context) {
    final int themeIndex = AppTheme.getThemeIndex(goal.backgroundTheme);
    final GoalThemeSet themeSet = AppTheme.getGoalTheme(themeIndex);

    return Transform.rotate(
      angle: rotation,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: <Widget>[
          Bounceable(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => DetailView(goal: goal),
                ),
              );
            },
            child: RepaintBoundary(
              child: HandDrawnContainer(
                showStackEffect: true,
                backgroundColor: Colors.white, // 폴라로이드 외곽 프레임은 흰색
                borderColor: Colors.black.withOpacity(0.1),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    // 상단 이미지 영역 (theme color 적용)
                    Expanded(
                      flex: 4,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: themeSet.background.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Center(
                          child: Text(
                            goal.emojiTag,
                            style: const TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // 하단 텍스트 영역
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: Text(
                          goal.title,
                          style: AppTheme.handwritingMedium.copyWith(
                            color: AppTheme.warmBrown,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
              ),
            ),
          ),
          // 마스킹 테이프 추가: 성공 앨범과 동일하게 테마 색상 및 투명도 적용
          Positioned(
            top: -15,
            child: MaskingTape(
              color: themeSet.point,
              opacity: 0.5,
              width: 70,
              height: 24,
              rotation: rotation * 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeViewStateData {
  final List<Goal> goals;
  final bool isLoading;

  _HomeViewStateData({required this.goals, required this.isLoading});
}
