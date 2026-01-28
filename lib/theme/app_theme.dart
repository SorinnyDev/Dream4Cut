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

  /// 배경색에 대응하는 딥 뮤트(Deep Muted) 텍스트/강조 색상
  static const List<Color> deepMutedColors = [
    Color(0xFF8B4D55), // 핑크 -> 딥 로즈
    Color(0xFF8B6B4D), // 피치 -> 딥 브라운
    Color(0xFF8B8B4D), // 옐로우 -> 딥 올리브
    Color(0xFF4D8B6B), // 민트 -> 딥 포레스트
    Color(0xFF4D6B8B), // 블루 -> 딥 네이비
    Color(0xFF6B4D8B), // 라벤더 -> 딥 퍼플
    Color(0xFF8B4D6B), // 로즈 -> 딥 플럼
    Color(0xFF4D8B8B), // 시안 -> 딥 틸
  ];

  /// 마스킹 테이프 색상
  static const Color maskingTape = Color(0xFFFFD6A5);
  static const Color maskingTapeLight = Color(0xFFFFF0DB);

  /// 텍스트 색상 (완전한 블랙 금지)
  static const Color textPrimary = Color(0xFF2C2C2C); // 딥 차콜
  static const Color textSecondary = Color(0xFF5A5A5A); // 미디엄 차콜
  static const Color textTertiary = Color(0xFF8E8E8E); // 라이트 차콜

  /// 연필/경계선 색상
  static const Color pencilCharcoal = Color(0xFF333333); // 경계선용 진한 색
  static const Color pencilDash = Color(0xFFBBBBBB);

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
    fontSize: 30,
    fontWeight: FontWeight.w900, // 더 굵게 (Extra Bold)
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle headingMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w800, // 더 굵게 (Bold)
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle headingSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 19,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    height: 1.4,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium으로 상향
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
    fontWeight: FontWeight.w300, // 더 가늘게 (Light)
    color: textSecondary,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w300, // 더 가늘게 (Light)
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

  // ============ 그림자 (종이 레이어링 효과) ============

  /// 고체 오프셋 그림자 (Solid Offset Shadow)
  static List<BoxShadow> paperShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 0,
      offset: const Offset(2, 2),
    ),
  ];

  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 0,
      offset: const Offset(1, 1),
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
      // TextField 테마 고도화
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: bodyMedium.copyWith(color: textTertiary.withOpacity(0.6)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: textSecondary, width: 1.2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: textPrimary, width: 2.0),
        ),
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

  /// 딥 뮤트 컬러 선택 (인덱스 기반)
  static Color getDeepMutedColor(int index) {
    return deepMutedColors[index % deepMutedColors.length];
  }

  /// 테마 이름으로 인덱스 찾기 (예: color_0 -> 0)
  static int getThemeIndex(String theme) {
    try {
      return int.parse(theme.split('_').last);
    } catch (_) {
      return 0;
    }
  }

  /// 책갈피 컬러 선택 (인덱스 기반)
  static Color getBookmarkColor(int index) {
    return bookmarkColors[index % bookmarkColors.length];
  }
}
