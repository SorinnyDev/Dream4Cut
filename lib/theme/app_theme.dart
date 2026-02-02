import 'package:flutter/material.dart';

/// Dream4Cut 앱 테마 - [Scrapbook & Retro Diary] 컨셉
class AppTheme {
  // ============ 메인 배경: 종이 질감 (Paper Base) ============
  static const Color ivoryPaper = Color(0xFFF9F7F2); // 기본 종이색 (Eggshell)
  static const Color oatSilk = Color(0xFFF3E7D9); // 약간 더 차분한 종이색
  static const Color vintagePaper = Color(0xFFF0EADC); // 빈티지한 종이색

  // ============ 텍스트 및 선: 딥 차콜 (Pencil/Ink) ============
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF888888);
  static const Color pencilCharcoal = Color(0xFF333333);
  static const Color pencilDash = Color(0xFFDDDDDD);

  // ============ 테마 세트 재구성 (포인트 컬러 중심) ============
  static const List<GoalThemeSet> goalThemes = [
    GoalThemeSet(
      name: '빈티지 로즈',
      background: Color(0xFFFDF1F2),
      point: Color(0xFFD48181),
      text: Color(0xFF4A2A2A),
    ),
    GoalThemeSet(
      name: '올리브 가든',
      background: Color(0xFFF4F7F0),
      point: Color(0xFF8A9A5B),
      text: Color(0xFF2D331D),
    ),
    GoalThemeSet(
      name: '썬셋 오렌지',
      background: Color(0xFFFEF6ED),
      point: Color(0xFFE08E45),
      text: Color(0xFF4A2D14),
    ),
    GoalThemeSet(
      name: '미드나잇 블루',
      background: Color(0xFFF0F4F8),
      point: Color(0xFF5A7D9A),
      text: Color(0xFF1D2933),
    ),
    GoalThemeSet(
      name: '코코아 밀크',
      background: Color(0xFFF7F3F0),
      point: Color(0xFF967E67),
      text: Color(0xFF332B24),
    ),
    GoalThemeSet(
      name: '라벤더 안개',
      background: Color(0xFFF5F3F7),
      point: Color(0xFF9A8CBF),
      text: Color(0xFF2D2833),
    ),
    GoalThemeSet(
      name: '포레스트 그린',
      background: Color(0xFFF0F4F2),
      point: Color(0xFF5B8A72),
      text: Color(0xFF1D3328),
    ),
    GoalThemeSet(
      name: '허니 옐로우',
      background: Color(0xFFFBF8EE),
      point: Color(0xFFD4AF37),
      text: Color(0xFF332B10),
    ),
  ];

  static const Color maskingTape = Color(0xFFFFD6A5);

  // ============ 스크랩북 디테일 (Offset Layers & Sketchy Lines) ============
  static final List<BoxShadow> scrapbookShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      offset: const Offset(3, 3),
      blurRadius: 0,
    ),
  ];

  static final List<BoxShadow> paperShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      offset: const Offset(1, 1),
      blurRadius: 4,
    ),
  ];

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      offset: const Offset(0, 2),
      blurRadius: 5,
    ),
  ];

  // 타이포그래피 (나눔명조 기반 아날로그 감성)
  static const String fontFamily = 'NanumMyeongjo';

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 26,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    height: 1.3,
  );
  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );
  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textPrimary,
  );
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    color: textSecondary,
  );
  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    color: textTertiary,
  );

  // 간격
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;

  static const double radiusS = 4.0;
  static const double radiusM = 8.0;
  static const double radiusL = 16.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ivoryPaper,
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingMedium,
      ),
    );
  }

  static GoalThemeSet getGoalTheme(int index) =>
      goalThemes[index % goalThemes.length];

  static int getThemeIndex(String theme) {
    try {
      return int.parse(theme.split('_').last);
    } catch (_) {
      return 0;
    }
  }

  static const List<Color> bookmarkColors = [
    Color(0xFFFFADAD),
    Color(0xFFFFD6A5),
    Color(0xFFFDFFB6),
    Color(0xFFCAFFBF),
    Color(0xFF9BFBC0),
    Color(0xFFA0C4FF),
    Color(0xFFBDB2FF),
    Color(0xFFFFC6FF),
  ];
  static Color getBookmarkColor(int index) =>
      bookmarkColors[index % bookmarkColors.length];

  // 하위 호환성 헬퍼
  static Color getPastelColor(int index) => getGoalTheme(index).background;
  static Color getAccentColor(int index) => getGoalTheme(index).point;
  static Color getDeepMutedColor(int index) => getGoalTheme(index).text;
  static List<Color> get pastelColors =>
      goalThemes.map((t) => t.background).toList();
}

class GoalThemeSet {
  final String name;
  final Color background;
  final Color point;
  final Color text;

  const GoalThemeSet({
    required this.name,
    required this.background,
    required this.point,
    required this.text,
  });
}
