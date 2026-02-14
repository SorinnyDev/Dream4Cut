import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../widgets/analog_widgets.dart';
import 'home_view.dart';
import 'footsteps_view.dart';
import 'settings_view.dart';

/// 메인 스캐폴드 - 종이 질감 하단 네비게이션 포함
class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  final List<Widget> _screens = [
    const HomeView(),
    const FootstepsView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    // 탭 인덱스만 개별 구독하여 목표 변경 시 전체 스캐폴드 리빌드 방지
    final selectedIndex = context.select<GoalProvider, int>(
      (p) => p.currentTabIndex,
    );

    // 탭별 배경색 차별화
    Color backgroundColor;
    switch (selectedIndex) {
      case 1:
        backgroundColor = AppTheme.champagneGold;
        break;
      case 2:
        backgroundColor = AppTheme.archiveBeige;
        break;
      default:
        backgroundColor = AppTheme.oatSilk;
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          // 배경 텍스처 및 비네팅 - RepaintBoundary 추가로 성능 최적화
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: Stack(
                  children: [
                    CustomPaint(painter: NoiseTexturePainter(opacity: 0.03)),
                    Container(decoration: AppTheme.getVignetteDecoration()),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: 80 + bottomPadding),
            child: _screens[selectedIndex],
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              child: RepaintBoundary(
                child: Consumer<GoalProvider>(
                  builder: (context, provider, _) =>
                      _buildCustomBottomBar(provider),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomBar(GoalProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth * 0.90; // 너비를 약간 확장 (90%)

    return Container(
      height: 100,
      padding: const EdgeInsets.only(bottom: 24), // 하단 24px 플로팅
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Glassmorphism 배경
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: barWidth,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x1A3E2723),
                      offset: const Offset(0, 12),
                      blurRadius: 24,
                      spreadRadius: -4,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 선택된 탭 위 마스킹 테이프 애니메이션
          AnimatedPositioned(
            duration: const Duration(milliseconds: 400),
            curve: Curves.fastOutSlowIn,
            left: _calculateTapePosition(provider.currentTabIndex),
            bottom: 58,
            child: Transform.rotate(
              angle: -0.04,
              child: Opacity(
                opacity: 0.6,
                child: Container(
                  width: 44,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppTheme.getGoalTheme(0).point, // 기본 테마의 포인트 색
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: barWidth,
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavItem(
                    provider,
                    0,
                    Icons.dashboard_outlined,
                    Icons.dashboard_rounded,
                    '오늘의 꿈',
                  ),
                  _buildNavItem(
                    provider,
                    1,
                    Icons.auto_awesome_outlined,
                    Icons.auto_awesome_rounded,
                    '성공 앨범',
                  ),
                  _buildNavItem(
                    provider,
                    2,
                    Icons.archive_outlined,
                    Icons.archive_rounded,
                    '기록 보관소',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    GoalProvider provider,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = provider.currentTabIndex == index;
    final color = isSelected
        ? AppTheme.warmBrown
        : AppTheme.warmBrown.withOpacity(0.4);

    return Expanded(
      child: Bounceable(
        onTap: () {
          provider.setTabIndex(index);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: isSelected ? 26 : 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.handwritingSmall.copyWith(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateTapePosition(int selectedIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth * 0.90;
    final itemWidth = barWidth / 3;
    final sidePadding = (screenWidth - barWidth) / 2;
    return sidePadding + (itemWidth * selectedIndex) + (itemWidth / 2) - 22;
  }
}
