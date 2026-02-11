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
    final provider = context.watch<GoalProvider>();
    final selectedIndex = provider.currentTabIndex;

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
          // 배경 텍스처 및 비네팅
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  CustomPaint(painter: NoiseTexturePainter(opacity: 0.03)),
                  Container(decoration: AppTheme.getVignetteDecoration()),
                ],
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
              child: _buildCustomBottomBar(provider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBottomBar(GoalProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth * 0.85; // 85% 너비

    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 20), // 하단 20px 떨어짐
      alignment: Alignment.bottomCenter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            width: barWidth,
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9), // 글라스모피즘
              borderRadius: BorderRadius.circular(30), // 캐슐 모양
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  offset: const Offset(0, 8),
                  blurRadius: 24,
                ),
              ],
            ),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            left: _calculateTapePosition(provider.currentTabIndex),
            bottom: 50,
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                width: 40,
                height: 15,
                decoration: BoxDecoration(
                  color: AppTheme.maskingTape.withOpacity(0.8),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    provider,
                    0,
                    Icons.auto_awesome_mosaic_outlined,
                    Icons.auto_awesome_mosaic,
                    '오늘의 꿈',
                  ),
                  _buildNavItem(
                    provider,
                    1,
                    Icons.military_tech_outlined,
                    Icons.military_tech,
                    '성공 앨범',
                  ),
                  _buildNavItem(
                    provider,
                    2,
                    Icons.inventory_2_outlined,
                    Icons.inventory_2,
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
    final color = isSelected ? AppTheme.textPrimary : AppTheme.textTertiary;

    return GestureDetector(
      onTap: () => provider.setTabIndex(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(isSelected ? 8 : 4),
            child: Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: isSelected ? 28 : 24,
            ),
          ),
          Text(
            label,
            style: AppTheme.handwritingSmall.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateTapePosition(int selectedIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - (AppTheme.spacingL * 2)) / 3;
    return AppTheme.spacingL +
        (itemWidth * selectedIndex) +
        (itemWidth / 2) -
        20;
  }
}
