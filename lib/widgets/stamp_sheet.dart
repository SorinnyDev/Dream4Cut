import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import 'analog_widgets.dart';

/// 인화지 위젯 (Stamp Sheet)
class StampSheet extends StatefulWidget {
  final int sheetNumber; // 인화지 번호 (1-based)
  final int filledCount; // 채워진 칸 개수 (0~200)
  final String theme; // 배경 테마
  final bool showAnimation; // 현상 효과 애니메이션 표시 여부

  const StampSheet({
    Key? key,
    required this.sheetNumber,
    required this.filledCount,
    required this.theme,
    this.showAnimation = false,
  }) : super(key: key);

  @override
  State<StampSheet> createState() => _StampSheetState();
}

class _StampSheetState extends State<StampSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;

  static const int gridColumns = 10;
  static const int gridRows = 20;
  static const int totalCells = gridColumns * gridRows;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    if (widget.showAnimation) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(opacity: _opacityAnimation.value, child: child);
      },
      child: HandDrawnContainer(
        backgroundColor: Colors.white,
        borderColor: AppTheme.pencilCharcoal.withOpacity(0.1),
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSheetHeader(),
            _buildStampGrid(),
            _buildSheetFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetHeader() {
    final themeIndex = AppTheme.getThemeIndex(widget.theme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: 24, // 여유 있게 배치
      ),
      decoration: BoxDecoration(
        color: themeSet.background.withOpacity(0.5),
        border: Border(
          bottom: BorderSide(color: themeSet.text.withOpacity(0.1), width: 0.5),
        ),
      ),
      child: Center(
        child: MaskingTape(
          text: '목표를 향해 걷는 중',
          rotation: -0.02,
          color: themeSet.point,
          textStyle: AppTheme.bodyMedium.copyWith(
            fontWeight: FontWeight.w900,
            color: themeSet.text.withOpacity(0.8), // 포인트 컬러의 어두운 톤 사용
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildStampGrid() {
    final int rowCount = ((widget.filledCount / gridColumns).floor() + 1).clamp(
      1,
      gridRows,
    );
    final int visibleCells = rowCount * gridColumns;
    final themeIndex = AppTheme.getThemeIndex(widget.theme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingM),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: themeSet.background.withOpacity(0.3), // 그리드 영역 배경 구분
        borderRadius: BorderRadius.circular(4),
      ),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: visibleCells,
        itemBuilder: (context, index) {
          final isFilled = index < widget.filledCount;
          return _buildStampCell(index, isFilled);
        },
      ),
    );
  }

  Widget _buildStampCell(int index, bool isFilled) {
    final themeIndex = AppTheme.getThemeIndex(widget.theme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    // 개별 도장의 불규칙성을 위한 랜덤값 (인덱스를 시드로 고정)
    final cellRandom = math.Random(index + widget.sheetNumber * 100);
    final stampRotation = (cellRandom.nextDouble() - 0.5) * 0.5; // 최대 약 14도 회전
    final stampOffset = Offset(
      (cellRandom.nextDouble() - 0.5) * 4,
      (cellRandom.nextDouble() - 0.5) * 4,
    );
    final inkOpacity = 0.7 + (cellRandom.nextDouble() * 0.3); // 0.7 ~ 1.0

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: themeSet.text.withOpacity(isFilled ? 0.6 : 0.15),
          width: 1.2, // 테두리 두께 1.2px로 강화
        ),
      ),
      child: isFilled
          ? Transform.translate(
              offset: stampOffset,
              child: Transform.rotate(
                angle: stampRotation,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Center(
                      child: Opacity(
                        opacity: inkOpacity,
                        child: Icon(
                          Icons.check,
                          size: constraints.maxWidth * 0.9, // 도장 크기 살짝 키움
                          color: themeSet.point.withOpacity(0.9),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSheetFooter() {
    return const SizedBox(height: AppTheme.spacingM);
  }
}

class StampSheetStack extends StatefulWidget {
  final int totalCount;
  final String theme;
  final Function(int sheetNumber)? onSheetChanged;

  const StampSheetStack({
    Key? key,
    required this.totalCount,
    required this.theme,
    this.onSheetChanged,
  }) : super(key: key);

  @override
  State<StampSheetStack> createState() => _StampSheetStackState();
}

class _StampSheetStackState extends State<StampSheetStack> {
  late int _currentSheetNumber;

  @override
  void initState() {
    super.initState();
    _currentSheetNumber = _getCurrentSheetNumber();
  }

  @override
  void didUpdateWidget(StampSheetStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalCount != widget.totalCount) {
      setState(() {
        _currentSheetNumber = _getCurrentSheetNumber();
      });
    }
  }

  int _getCurrentSheetNumber() => (widget.totalCount ~/ 200) + 1;

  int _getFilledCountForSheet(int sheetNumber) {
    if (sheetNumber < _getCurrentSheetNumber()) return 200;
    if (sheetNumber == _getCurrentSheetNumber()) return widget.totalCount % 200;
    return 0;
  }

  void _changeSheet(int sheetNumber) {
    if (sheetNumber >= 1 && sheetNumber <= _getCurrentSheetNumber()) {
      setState(() => _currentSheetNumber = sheetNumber);
      widget.onSheetChanged?.call(sheetNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSheets = _getCurrentSheetNumber();
    return Column(
      children: [
        if (totalSheets > 1) _buildBookmarkNavigation(totalSheets),
        const SizedBox(height: AppTheme.spacingM),
        StampSheet(
          sheetNumber: _currentSheetNumber,
          filledCount: _getFilledCountForSheet(_currentSheetNumber),
          theme: widget.theme,
          showAnimation: true,
        ),
      ],
    );
  }

  Widget _buildBookmarkNavigation(int totalSheets) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalSheets,
        itemBuilder: (context, index) {
          final sheetNumber = index + 1;
          final isSelected = sheetNumber == _currentSheetNumber;
          final bookmarkColor = AppTheme.getBookmarkColor(index);

          return GestureDetector(
            onTap: () => _changeSheet(sheetNumber),
            child: Container(
              margin: const EdgeInsets.only(right: AppTheme.spacingS),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingM,
                vertical: AppTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? bookmarkColor
                    : bookmarkColor.withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusS),
                  topRight: Radius.circular(AppTheme.radiusS),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No.$sheetNumber',
                    style: AppTheme.bodySmall.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
