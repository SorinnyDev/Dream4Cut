import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dream4Cut 앱 테마 - [Scrapbook & Retro Diary] 컨셉
class AppTheme {
  // ============ 메인 배경: 종이 질감 (Paper Base) ============
  static const Color ivoryPaper = Color(0xFFF9F7F2); // 기본 종이색 (Eggshell)
  static const Color oatSilk = Color(0xFFF3E7D9); // 약간 더 차분한 종이색
  static const Color champagneGold = Color(0xFFFFF9E3); // 성공 앨범 배경
  static const Color archiveBeige = Color(0xFFE5E2D9); // 기록 보관소 배경

  // ============ 텍스트 및 선: 딥 차콜 (Pencil/Ink) ============
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF888888);
  static const Color pencilCharcoal = Color(0xFF333333);
  static const Color pencilDash = Color(0xFFDDDDDD);

  /// 지능형 테두리 시스템: 포인트 컬러에 맞는 최적의 테두리색 반환
  static Color getSmartBorderColor(Color pointColor) {
    final hsv = HSVColor.fromColor(pointColor);
    final hue = hsv.hue;
    final saturation = hsv.saturation;

    // Muted Color (Saturation < 0.25)
    if (saturation < 0.25) {
      return const Color(0xFF5D4037); // 중립적인 월넛 브라운
    }

    // Warm Color (Orange, Yellow, Red, Pink)
    if (hue < 70 || hue > 320) {
      return const Color(0xFF3E2723); // 붉은 기가 도는 딥 브라운
    }

    // Cold Color (Blue, Green, Teal)
    return const Color(0xFF263238); // 푸른 기가 도는 다크 차콜
  }

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
  // 모든 위젯에서 포인트 색상 그림자를 제거하고 실선으로 대체하기 위해 기존 그림자 투명도 조절
  static final List<BoxShadow> scrapbookShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.04), // 더욱 옅게
      offset: const Offset(2, 2),
      blurRadius: 0,
    ),
  ];

  static final List<BoxShadow> paperShadow = []; // 그림자 제거 대안

  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.03),
      offset: const Offset(0, 1),
      blurRadius: 3,
    ),
  ];

  // 타이포그래피 (나눔명조 기반 아날로그 감성)
  static const String fontFamily = 'NanumMyeongjo';

  // 손글씨 폰트 스타일 (Nanum Pen Script - OFL License)
  // Baseline 보정: height를 1.0으로 설정하여 상하 여백 최소화
  static TextStyle handwritingLarge = GoogleFonts.nanumPenScript(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.0, // 베이스라인 보정
  );

  static TextStyle handwritingMedium = GoogleFonts.nanumPenScript(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.0,
  );

  static TextStyle handwritingSmall = GoogleFonts.nanumPenScript(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.0,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    height: 1.2,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    height: 1.3,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle bodyBold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static const TextStyle bodyRegular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
  );

  static const TextStyle bodyLight = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
  );

  // Backward Compatibility Aliases
  static TextStyle get headingLarge => titleLarge;
  static TextStyle get headingMedium => titleMedium;
  static TextStyle get headingSmall => titleSmall;
  static TextStyle get bodyLarge => bodyBold;
  static TextStyle get caption => labelSmall;

  // 간격 및 곡률
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
      scaffoldBackgroundColor: oatSilk, // 기본 배경을 Oat Silk로 고정
      fontFamily: fontFamily,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: titleSmall,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: UnderlineInputBorder(
          borderSide: BorderSide(
            color: pencilCharcoal.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: pencilCharcoal.withOpacity(0.3),
            width: 1.0,
          ),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: pencilCharcoal, width: 2.0),
        ),
      ),
    );
  }

  static GoalThemeSet getGoalTheme(int index) =>
      goalThemes[index % goalThemes.length];

  static int getThemeIndex(String theme) {
    if (theme.isEmpty) return 0;
    try {
      if (theme.contains('_')) {
        return int.parse(theme.split('_').last);
      }
      return 0;
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
