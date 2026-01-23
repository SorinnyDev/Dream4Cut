import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
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

    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      body: Stack(
        children: [
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
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingM,
              vertical: 4,
            ),
            height: 65,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              boxShadow: AppTheme.paperShadow,
              border: Border.all(
                color: AppTheme.pencilDash.withOpacity(0.3),
                width: 1,
              ),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(1, 1),
                    ),
                  ],
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
                    '기록',
                  ),
                  _buildNavItem(
                    provider,
                    1,
                    Icons.query_stats_outlined,
                    Icons.query_stats_rounded,
                    '발자국',
                  ),
                  _buildNavItem(
                    provider,
                    2,
                    Icons.inventory_2_outlined,
                    Icons.inventory_2_rounded,
                    '내 서랍',
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
            style: AppTheme.caption.copyWith(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 10,
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
