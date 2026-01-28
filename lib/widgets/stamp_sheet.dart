import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'analog_widgets.dart';

/// 인화지 위젯 (Stamp Sheet)
///
/// 200칸 그리드로 구성된 실천 기록 인화지
/// - 10x20 그리드 (가로 10칸, 세로 20칸)
/// - 각 칸은 파스텔 톤으로 채워짐
/// - 종이 질감과 현상 효과 애니메이션
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

  static const int gridColumns = 10; // 가로 칸 수
  static const int gridRows = 20; // 세로 칸 수
  static const int totalCells = gridColumns * gridRows; // 200칸

  @override
  void initState() {
    super.initState();

    // 현상 효과 애니메이션 설정
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: AppTheme.paperShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 인화지 헤더
            _buildSheetHeader(),

            // 200칸 그리드
            _buildStampGrid(),

            // 인화지 푸터 (진행률)
            _buildSheetFooter(),
          ],
        ),
      ),
    );
  }

  /// 인화지 헤더 (목표 상태 표시)
  Widget _buildSheetHeader() {
    final themeIndex = AppTheme.getThemeIndex(widget.theme);
    final deepMutedColor = AppTheme.getDeepMutedColor(themeIndex);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingM,
        vertical: AppTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: AppTheme.getPastelColor(themeIndex).withOpacity(0.3),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusM),
          topRight: Radius.circular(AppTheme.radiusM),
        ),
        border: Border(
          bottom: BorderSide(
            color: deepMutedColor.withOpacity(0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Center(
        child: MaskingTape(
          text: '목표를 향해 걷는 중',
          width: 140,
          height: 32,
          rotation: -0.02,
          color: AppTheme.getPastelColor(themeIndex),
          textStyle: AppTheme.bodySmall.copyWith(
            fontWeight: FontWeight.w900,
            color: deepMutedColor,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  /// 200칸 스탬프 그리드
  Widget _buildStampGrid() {
    final int rowCount = ((widget.filledCount / gridColumns).floor() + 1).clamp(
      1,
      gridRows,
    );
    final int visibleCells = rowCount * gridColumns;

    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingM),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
        ),
        itemCount: visibleCells,
        itemBuilder: (context, index) {
          final isFilled = index < widget.filledCount;
          return _buildStampCell(index, isFilled);
        },
      ),
    );
  }

  /// 개별 스탬프 칸
  Widget _buildStampCell(int index, bool isFilled) {
    final themeIndex = AppTheme.getThemeIndex(widget.theme);
    final deepMutedColor = AppTheme.getDeepMutedColor(themeIndex);

    return Container(
      decoration: BoxDecoration(
        color: isFilled
            ? AppTheme.getAccentColor(index)
            : AppTheme.ivoryPaper.withOpacity(0.3),
        borderRadius: BorderRadius.circular(1),
        border: Border.all(
          color: isFilled
              ? deepMutedColor.withOpacity(0.5)
              : AppTheme.pencilCharcoal.withOpacity(0.1),
          width: 0.8,
        ),
      ),
      child: isFilled
          ? LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: Icon(
                    Icons.check,
                    size: constraints.maxWidth * 0.8,
                    color: Colors.white,
                  ),
                );
              },
            )
          : null,
    );
  }

  /// 인화지 푸터 (그냥 여백으로 대체)
  Widget _buildSheetFooter() {
    return const SizedBox(height: AppTheme.spacingS);
  }
}

/// 인화지 스택 위젯 (여러 인화지를 쌓아서 표시)
///
/// 책갈피 시스템으로 과거 인화지 조회 가능
class StampSheetStack extends StatefulWidget {
  final int totalCount; // 전체 누적 횟수
  final String theme; // 배경 테마
  final Function(int sheetNumber)? onSheetChanged; // 인화지 변경 콜백

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

  int _getCurrentSheetNumber() {
    return (widget.totalCount ~/ 200) + 1;
  }

  int _getFilledCountForSheet(int sheetNumber) {
    if (sheetNumber < _getCurrentSheetNumber()) {
      return 200; // 완성된 인화지
    } else if (sheetNumber == _getCurrentSheetNumber()) {
      return widget.totalCount % 200; // 현재 진행 중인 인화지
    } else {
      return 0; // 미래 인화지
    }
  }

  void _changeSheet(int sheetNumber) {
    if (sheetNumber >= 1 && sheetNumber <= _getCurrentSheetNumber()) {
      setState(() {
        _currentSheetNumber = sheetNumber;
      });
      widget.onSheetChanged?.call(sheetNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSheets = _getCurrentSheetNumber();

    return Column(
      children: [
        // 책갈피 네비게이션
        if (totalSheets > 1) _buildBookmarkNavigation(totalSheets),

        const SizedBox(height: AppTheme.spacingM),

        // 현재 선택된 인화지
        StampSheet(
          sheetNumber: _currentSheetNumber,
          filledCount: _getFilledCountForSheet(_currentSheetNumber),
          theme: widget.theme,
          showAnimation: true,
        ),
      ],
    );
  }

  /// 책갈피 네비게이션
  Widget _buildBookmarkNavigation(int totalSheets) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: totalSheets,
        itemBuilder: (context, index) {
          final sheetNumber = index + 1;
          final isSelected = sheetNumber == _currentSheetNumber;

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
                    ? AppTheme.getBookmarkColor(index)
                    : AppTheme.getBookmarkColor(index).withOpacity(0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusS),
                  topRight: Radius.circular(AppTheme.radiusS),
                ),
                boxShadow: isSelected ? AppTheme.cardShadow : null,
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
                  if (sheetNumber < totalSheets)
                    Icon(
                      Icons.check_circle,
                      size: 12,
                      color: Colors.white.withOpacity(0.8),
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
