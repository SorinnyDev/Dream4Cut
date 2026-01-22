import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'home_view.dart';
import 'stats_view.dart';
import 'settings_view.dart';

/// 메인 스캐폴드 - 종이 질감 하단 네비게이션 포함
class MainScaffold extends StatefulWidget {
  const MainScaffold({Key? key}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const StatsView(),
    const SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    // 시스템 하단 여백(Safe Area bottom)을 계산합니다.
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      body: Stack(
        children: [
          // 현재 선택된 화면 (하단 바 높이 + 기기 하단 여백만큼 하단에 여백을 줌)
          Padding(
            padding: EdgeInsets.only(bottom: 80 + bottomPadding),
            child: _screens[_selectedIndex],
          ),

          // 하단 커스텀 네비게이션 바
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              bottom: true,
              child: _buildCustomBottomBar(),
            ),
          ),
        ],
      ),
    );
  }

  /// 아날로그 감성 커스텀 하단 바
  Widget _buildCustomBottomBar() {
    return Container(
      height: 90,
      padding: const EdgeInsets.only(bottom: 10),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // 1. 하단 종이 배경 (약간 삐뚤빼뚤한 느낌을 위해 CustomPainter 사용 가능하지만 우선 간단하게)
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

          // 2. 마스킹 테이프 장식 (현재 선택된 탭 강조용)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            left: _calculateTapePosition(),
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

          // 3. 네비게이션 아이콘들
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    0,
                    Icons.auto_awesome_mosaic_outlined,
                    Icons.auto_awesome_mosaic,
                    '기록',
                  ),
                  _buildNavItem(
                    1,
                    Icons.query_stats_outlined,
                    Icons.query_stats_rounded,
                    '발자국',
                  ),
                  _buildNavItem(
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
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _selectedIndex == index;
    final color = isSelected ? AppTheme.textPrimary : AppTheme.textTertiary;

    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
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

  double _calculateTapePosition() {
    final screenWidth = MediaQuery.of(context).size.width;
    final itemWidth = (screenWidth - (AppTheme.spacingL * 2)) / 3;
    return AppTheme.spacingL +
        (itemWidth * _selectedIndex) +
        (itemWidth / 2) -
        20;
  }
}
