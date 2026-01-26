import 'package:flutter/material.dart';

/// Dream4Cut 앱 테마
///
/// 다꾸(다이어리 꾸미기) 감성의 아날로그 디자인 시스템
/// - 종이 질감
/// - 파스텔 톤
/// - 마스킹 테이프 효과
/// - 연필 점선
class AppTheme {
  // ============ 색상 팔레트 ============

  /// 배경색 - 아이보리 미선지
  static const Color ivoryPaper = Color(0xFFFAF8F3);

  /// 주요 파스텔 톤 (인화지 칸 채우기용)
  static const List<Color> pastelColors = [
    Color(0xFFFFE5E5), // 파스텔 핑크
    Color(0xFFFFE8CC), // 파스텔 피치
    Color(0xFFFFF4CC), // 파스텔 옐로우
    Color(0xFFE5F5E5), // 파스텔 민트
    Color(0xFFE5F0FF), // 파스텔 블루
    Color(0xFFF0E5FF), // 파스텔 라벤더
    Color(0xFFFFE5F5), // 파스텔 로즈
    Color(0xFFE5FFFA), // 파스텔 시안
  ];

  /// 주요 강조 톤 (버튼 등 활성화 요소용)
  static const List<Color> accentColors = [
    Color(0xFFFF9BAA), // 강조 핑크
    Color(0xFFFFB347), // 강조 피치
    Color(0xFFFFD700), // 강조 옐로우
    Color(0xFF77DD77), // 강조 민트
    Color(0xFF779ECB), // 강조 블루
    Color(0xFFB39EB5), // 강조 라벤더
    Color(0xFFFF69B4), // 강조 로즈
    Color(0xFF00CED1), // 강조 시안
  ];

  /// 마스킹 테이프 색상
  static const Color maskingTape = Color(0xFFFFD6A5);
  static const Color maskingTapeLight = Color(0xFFFFF0DB);

  /// 텍스트 색상
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textTertiary = Color(0xFF9B9B9B);

  /// 연필 점선 색상
  static const Color pencilDash = Color(0xFFCCCCCC);

  /// 책갈피 색상
  static const List<Color> bookmarkColors = [
    Color(0xFFFF9999), // 레드
    Color(0xFFFFCC99), // 오렌지
    Color(0xFFFFFF99), // 옐로우
    Color(0xFF99FF99), // 그린
    Color(0xFF99CCFF), // 블루
    Color(0xFFCC99FF), // 퍼플
  ];

  // ============ 타이포그래피 ============

  static const String fontFamily = 'NanumMyeongjo'; // 명조체 (아날로그 감성)

  static const TextStyle headingLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.6,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.6,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.4,
  );

  // ============ 스페이싱 ============

  static const double spacingXs = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ============ 보더 반경 ============

  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // ============ 그림자 (종이 질감) ============

  static List<BoxShadow> paperShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  // ============ ThemeData ============

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: ivoryPaper,
      fontFamily: fontFamily,
      colorScheme: ColorScheme.light(
        primary: pastelColors[0],
        secondary: pastelColors[4],
        surface: Colors.white,
        background: ivoryPaper,
      ),
      textTheme: const TextTheme(
        displayLarge: headingLarge,
        displayMedium: headingMedium,
        displaySmall: headingSmall,
        bodyLarge: bodyLarge,
        bodyMedium: bodyMedium,
        bodySmall: bodySmall,
        labelSmall: caption,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: ivoryPaper,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: headingMedium,
        iconTheme: IconThemeData(color: textPrimary),
      ),
    );
  }

  /// 파스텔 컬러 선택 (인덱스 기반)
  static Color getPastelColor(int index) {
    return pastelColors[index % pastelColors.length];
  }

  /// 강조 컬러 선택 (인덱스 기반)
  static Color getAccentColor(int index) {
    return accentColors[index % accentColors.length];
  }

  /// 책갈피 컬러 선택 (인덱스 기반)
  static Color getBookmarkColor(int index) {
    return bookmarkColors[index % bookmarkColors.length];
  }
}
