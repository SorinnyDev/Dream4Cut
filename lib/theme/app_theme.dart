import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dream4Cut 앱 테마 - [Scrapbook & Retro Diary] 컨셉
class AppTheme {
  // ============ 메인 배경: 종이 질감 (Paper Base) ============
  static const Color premiumCream = Color(0xFFFFFBF0); // 프리미엄 크림색 배경
  static const Color vignetteEdge = Color(0xFFE8DCC4); // 비네팅 가장자리 색상
  static const Color ivoryPaper = Color(0xFFF9F7F2); // 기본 종이색 (Eggshell)
  static const Color oatSilk = Color(0xFFF3E7D9); // 약간 더 차분한 종이색
  static const Color champagneGold = Color(0xFFFFF9E3); // 성공 앨범 배경
  static const Color archiveBeige = Color(0xFFE5E2D9); // 기록 보관소 배경

  // ============ 텍스트 및 선: 딥 차콜 (Pencil/Ink) ============
  static const Color warmBrown = Color(0xFF3E2723); // 따뜻한 브라운 (모든 텍스트 기본)
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF4A4A4A);
  static const Color textTertiary = Color(0xFF888888);
  static const Color pencilCharcoal = Color(0xFF333333);
  static const Color pencilDash = Color(0xFFDDDDDD);
  static const Color creamWhite = Color(0xFFFFF9F0); // 눈의 피로를 덜어주는 연한 크림색
  static const Color deepBrownBorder = Color(0xFF5D4037); // 마스킹 테이프 테두리

  /// 지능형 테두리 시스템: 포인트 컬러에 맞는 최적의 테두리색 반환
  static Color getSmartBorderColor(Color pointColor) {
    final hsv = HSVColor.fromColor(pointColor);
    final hue = hsv.hue;
    final saturation = hsv.saturation;

    if (saturation < 0.25) {
      return const Color(0xFF5D4037);
    }

    if (hue < 70 || hue > 320) {
      return const Color(0xFF3E2723);
    }

    return const Color(0xFF263238);
  }

  // ============ 2026 컬러 트렌드 스마트 팔레트 ============
  static const List<GoalThemeSet> goalThemes = [
    GoalThemeSet(
      name: 'Lemonade',
      background: Color(0xFFDDBA7B), // 메인 컬러
      scaffoldBg: Color(0xFFAE9580), // 상세화면 배경 (Clay)
      point: Color(0xFFB5542F), // 버튼 & 강조색
      text: Color(0xFF2D2416), // 텍스트
    ),
    GoalThemeSet(
      name: 'Olive',
      background: Color(0xFF6D7843), // 메인 컬러
      scaffoldBg: Color(0xFFB9B297), // 상세화면 배경
      point: Color(0xFF4B4B1A), // 버튼 & 강조색
      text: Color(0xFF1A1A0A), // 텍스트
    ),
    GoalThemeSet(
      name: 'Blush',
      background: Color(0xFFD1ACA6), // 메인 컬러
      scaffoldBg: Color(0xFFE5D1CA), // 상세화면 배경
      point: Color(0xFFCE938E), // 버튼 & 강조색
      text: Color(0xFF3D2B28), // 텍스트
    ),
    GoalThemeSet(
      name: 'Neutral',
      background: Color(0xFFD3CDC1), // 메인 컬러
      scaffoldBg: Color(0xFFBD9F81), // 상세화면 배경
      point: Color(0xFF6C5A46), // 버튼 & 강조색
      text: Color(0xFF2A2218), // 텍스트
    ),
    GoalThemeSet(
      name: 'Blue',
      background: Color(0xFFE6EBEF), // 메인 컬러
      scaffoldBg: Color(0xFF7F92A3), // 상세화면 배경
      point: Color(0xFF09181B), // 버튼 & 강조색 (Navy)
      text: Color(0xFF09181B), // 텍스트
    ),
  ];

  static const Color maskingTape = Color(0xFFB35C44); // 번트 오렌지 계열로 변경

  /// 배경 비네팅(Vignette) 효과 데코레이션 - 프리미엄 버전
  static BoxDecoration getVignetteDecoration() {
    return BoxDecoration(
      gradient: RadialGradient(
        center: Alignment.center,
        radius: 1.3,
        colors: [
          premiumCream.withOpacity(0.0), // 중앙은 투명
          vignetteEdge.withOpacity(0.4), // 가장자리는 크림 브라운
        ],
        stops: const [0.5, 1.0],
      ),
    );
  }

  /// 노이즈 텍스처 데코레이션 (Multiply 모드)
  static BoxDecoration getNoiseTextureDecoration() {
    return const BoxDecoration(color: Colors.transparent);
  }

  /// 배경색에 따라 자동으로 텍스트 색상 결정 (가독성 보장)
  static Color getAdaptiveTextColor(Color backgroundColor) {
    // 휘도 계산 (0.0 ~ 1.0)
    final luminance = backgroundColor.computeLuminance();

    // 어두운 배경(Clay, Navy 등)일 경우 밝은 크림색 반환
    if (luminance < 0.5) {
      return creamWhite; // #FFF9F0
    }

    // 밝은 배경일 경우 어두운 텍스트 반환
    return warmBrown; // #3E2723
  }

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
  final Color scaffoldBg; // 상세화면 배경색
  final Color point;
  final Color text;

  const GoalThemeSet({
    required this.name,
    required this.background,
    Color? scaffoldBg,
    required this.point,
    required this.text,
  }) : scaffoldBg = scaffoldBg ?? background; // 기본값은 background와 동일
}
