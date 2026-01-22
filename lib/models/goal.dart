/// Goal 모델 - 목표 데이터 구조
///
/// 횟수 중심의 누적형 목표 관리
/// - 연도/월 단위 리셋 없음
/// - 태어나서 지금까지의 누적 시행 횟수 추적
class Goal {
  final String id;
  final String title;
  final String backgroundTheme; // 배경 테마 (파스텔 컬러 등)
  final int totalCount; // 전체 누적 횟수
  final DateTime createdAt;
  final DateTime updatedAt;

  Goal({
    required this.id,
    required this.title,
    required this.backgroundTheme,
    required this.totalCount,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 현재 인화지 번호 (1-based)
  /// 예: 0~199회 = 1번, 200~399회 = 2번
  int get currentSheetNumber => (totalCount ~/ 200) + 1;

  /// 현재 인화지 내 진행률 (0~200)
  int get currentSheetProgress => totalCount % 200;

  /// 완성된 인화지 개수
  int get completedSheets => totalCount ~/ 200;

  /// 현재 인화지의 진행률 퍼센트 (0.0 ~ 1.0)
  double get currentSheetProgressPercent => currentSheetProgress / 200.0;

  Goal copyWith({
    String? id,
    String? title,
    String? backgroundTheme,
    int? totalCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      totalCount: totalCount ?? this.totalCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'backgroundTheme': backgroundTheme,
      'totalCount': totalCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      title: json['title'] as String,
      backgroundTheme: json['backgroundTheme'] as String,
      totalCount: json['totalCount'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Goal && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Goal{id: $id, title: $title, totalCount: $totalCount, currentSheet: $currentSheetNumber}';
  }
}
