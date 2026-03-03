import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../models/goal.dart';
import '../widgets/analog_widgets.dart';
import 'archived_goals_view.dart';
import 'dart:math' as math;
import 'goal_create_view.dart';
import 'detail_view.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';

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
    // 테마 설정을 감시하여 배경 인덱스 변화 시 전체 리빌드 유도
    final settings = context.watch<SettingsProvider>();
    debugPrint(
      "[HomeView] Rebuilding HomeView. backgroundIndex: ${settings.homeBackgroundIndex}",
    );

    return Container(
      color: AppTheme.premiumCream,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 헤더: 타이틀 + Push/서랍장 버튼 (배경 패턴 없음)
            _buildHeader(context),

            // 바디: 배경 패턴 + 목표 카드들
            Expanded(
              child: Stack(
                children: <Widget>[
                  // 배경 패턴 (바디 영역에만 적용)
                  Positioned.fill(
                    child: _buildBackground(settings.homeBackgroundIndex),
                  ),

                  // 목표 카드 페이지뷰
                  Selector<GoalProvider, _HomeViewStateData>(
                    selector: (context, provider) => _HomeViewStateData(
                      goals: provider.goals,
                      isLoading: provider.isLoading,
                    ),
                    builder: (context, data, child) {
                      if (data.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.warmBrown,
                          ),
                        );
                      }

                      final goals = data.goals;
                      final int maxFrameIndex = goals.isNotEmpty
                          ? goals.map((g) => g.frameIndex).reduce(math.max)
                          : 0;
                      final int totalFrames = math.max(maxFrameIndex + 2, 2);

                      return PageView.builder(
                        controller: _pageController,
                        itemCount: totalFrames,
                        onPageChanged: (index) =>
                            _currentPageNotifier.value = index,
                        itemBuilder: (context, frameIndex) =>
                            _buildGoalFrame(context, frameIndex),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 페이지 인디케이터
            const SizedBox(height: 8),
            ValueListenableBuilder<int>(
              valueListenable: _currentPageNotifier,
              builder: (context, currentPage, _) {
                return Selector<GoalProvider, int>(
                  selector: (context, provider) {
                    final maxIdx = provider.goals.isNotEmpty
                        ? provider.goals
                              .map((g) => g.frameIndex)
                              .reduce(math.max)
                        : 0;
                    return math.max(maxIdx + 2, 2);
                  },
                  builder: (context, totalFrames, _) {
                    return _buildPageIndicator(totalFrames, currentPage);
                  },
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 40, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Flexible(
            child: Column(
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
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Bounceable(
                onTap: () => NotificationService().showImmediateNotification(),
                child: _buildHeaderButton('Push'),
              ),
              const SizedBox(width: 6),
              Bounceable(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ArchivedGoalsView(),
                    ),
                  );
                },
                child: _buildHeaderButton('서랍장'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.pencilDash.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: AppTheme.handwritingMedium.copyWith(
          color: AppTheme.warmBrown,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildGoalFrame(BuildContext context, int frameIndex) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double cardWidth = constraints.maxWidth * 0.48;
        final double cardHeight = constraints.maxHeight * 0.42;

        return Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
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

  Widget _buildBackground(int index) {
    if (index == 1) {
      return Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: GridPaperPainter(gridSize: 24)),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: PaperTexturePainter()),
              ),
            ),
          ],
        ),
      );
    } else if (index == 2) {
      return Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: LinedPaperPainter(lineHeight: 28)),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: PaperTexturePainter()),
              ),
            ),
          ],
        ),
      );
    } else if (index == 3) {
      return Container(
        color: const Color(0xFFFFFDE7),
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                'assets/backgrounds/legal_pad.svg',
                fit: BoxFit.cover,
              ),
            ),
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: PaperTexturePainter()),
              ),
            ),
          ],
        ),
      );
    }

    return const Stack(
      children: <Widget>[
        CustomPaint(painter: NoiseTexturePainter(opacity: 0.03)),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[Colors.transparent, Color(0x1A000000)],
              stops: <double>[0.6, 1.0],
            ),
          ),
        ),
      ],
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
      selector: (context, provider) =>
          provider.getGoalAt(frameIndex, slotIndex),
      builder: (context, goal, child) {
        if (goal == null) {
          return Transform.rotate(
            angle: rotation,
            child: Bounceable(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => GoalCreateView(
                      frameIndex: frameIndex,
                      slotIndex: slotIndex,
                    ),
                  ),
                );
              },
              child: HandDrawnContainer(
                backgroundColor: Colors.white.withOpacity(0.8),
                borderColor: Colors.black.withOpacity(0.5),
                strokeWidth: 1.5,
                showOffsetLayer: true,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.add_rounded,
                        color: AppTheme.warmBrown.withOpacity(
                          0.3,
                        ), // More visible icon
                        size: 30,
                      ),
                      Text(
                        '새로운 조각',
                        style: AppTheme.handwritingSmall.copyWith(
                          color: AppTheme.warmBrown.withOpacity(
                            0.5,
                          ), // More visible text
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
                MaterialPageRoute<void>(builder: (_) => DetailView(goal: goal)),
              );
            },
            child: HandDrawnContainer(
              showStackEffect: true,
              backgroundColor: Colors.white,
              borderColor: Colors.black.withOpacity(0.1),
              padding: const EdgeInsets.all(10),
              child: Column(
                children: <Widget>[
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
