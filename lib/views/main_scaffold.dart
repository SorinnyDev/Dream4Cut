import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    // 1. 배경색만 감시하는 독립된 Selector (Scaffold 전체 리빌드 방지)
    return Selector<GoalProvider, Color>(
      selector: (context, provider) {
        switch (provider.currentTabIndex) {
          case 1:
            return AppTheme.champagneGold;
          case 2:
            return AppTheme.archiveBeige;
          default:
            return AppTheme.oatSilk;
        }
      },
      builder: (BuildContext context, Color backgroundColor, Widget? _) {
        return Scaffold(
          backgroundColor: backgroundColor,
          body: Stack(
            children: <Widget>[
              // 배경 텍스처 (최초 1회 렌더링 후 캐싱)
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

              // 본문 영역 (탭 변경 시에만 해당 인덱스로 전환)
              Padding(
                padding: EdgeInsets.only(bottom: 80 + bottomPadding),
                child: Selector<GoalProvider, int>(
                  selector: (BuildContext context, GoalProvider provider) =>
                      provider.currentTabIndex,
                  builder:
                      (BuildContext context, int selectedIndex, Widget? _) {
                        return IndexedStack(
                          index: selectedIndex,
                          children: _screens,
                        );
                      },
                ),
              ),

              // 하단 바 (본문과 완전히 분리하여 별도 레이어에서 렌더링)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: RepaintBoundary(
                    child: Selector<GoalProvider, int>(
                      selector: (BuildContext context, GoalProvider provider) =>
                          provider.currentTabIndex,
                      builder: (BuildContext context, int index, Widget? _) {
                        return _buildCustomBottomBar(index, context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCustomBottomBar(int currentTabIndex, BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double barWidth = screenWidth * 0.90;

    return Container(
      height: 100,
      padding: const EdgeInsets.only(bottom: 24),
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          // Glassmorphism 배경
          ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: barWidth,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 0.8,
                  ),
                  boxShadow: const <BoxShadow>[
                    BoxShadow(
                      color: Color(0x0D3E2723),
                      offset: Offset(0, 10),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 선택된 탭 위 마스킹 테이프 애니메이션 (더 빠르고 탄력적인 곡선 적용)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutQuart,
            left: _calculateTapePosition(currentTabIndex),
            bottom: 58,
            child: Transform.rotate(
              angle: -0.04,
              child: Container(
                width: 44,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.getGoalTheme(
                    0,
                  ).point.withOpacity(0.7), // Opacity handled at Paint level
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      offset: const Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
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
                children: <Widget>[
                  _buildNavItem(
                    context,
                    0,
                    currentTabIndex,
                    Icons.dashboard_outlined,
                    Icons.dashboard_rounded,
                    '오늘의 꿈',
                  ),
                  _buildNavItem(
                    context,
                    1,
                    currentTabIndex,
                    Icons.auto_awesome_outlined,
                    Icons.auto_awesome_rounded,
                    '성공 앨범',
                  ),
                  _buildNavItem(
                    context,
                    2,
                    currentTabIndex,
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
    BuildContext context,
    int index,
    int currentTabIndex,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final bool isSelected = currentTabIndex == index;
    final Color color = isSelected
        ? AppTheme.warmBrown
        : AppTheme.warmBrown.withValues(alpha: 0.4);

    return Expanded(
      child: Bounceable(
        onTap: () {
          // 화면 전환은 제스처가 확정된 onTap 시점에서 안전하게 수행
          if (currentTabIndex != index) {
            context.read<GoalProvider>().setTabIndex(index);
          }
        },
        child: Container(
          color: Colors.transparent, // 터치 영역 확보
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
