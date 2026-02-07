enum GoalStatus { active, completed, archived }

/// Goal 모델 - 목표 데이터 구조
///
/// 횟수 중심의 누적형 목표 관리
class Goal {
  final String id;
  final String title;
  final String backgroundTheme; // 배경 테마 (파스텔 컬러 등)
  final int totalCount; // 전체 누적 횟수
  final DateTime createdAt;
  final DateTime updatedAt;
  final GoalStatus status;
  final int frameIndex; // 0, 1, 2... (PageView의 페이지 인덱스)
  final int slotIndex; // 0, 1, 2, 3 (1x4 프레임 내 위치)
  final DateTime? completedAt;
  final String? timeCapsuleMessage; // 미래의 나에게 보내는 응원 메세지

  Goal({
    required this.id,
    required this.title,
    required this.backgroundTheme,
    required this.totalCount,
    required this.createdAt,
    required this.updatedAt,
    this.status = GoalStatus.active,
    this.frameIndex = 0,
    this.slotIndex = 0,
    this.completedAt,
    this.timeCapsuleMessage,
  });

  /// 현재 인화지 번호 (1-based)
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
    GoalStatus? status,
    int? frameIndex,
    int? slotIndex,
    DateTime? completedAt,
    String? timeCapsuleMessage,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      backgroundTheme: backgroundTheme ?? this.backgroundTheme,
      totalCount: totalCount ?? this.totalCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      frameIndex: frameIndex ?? this.frameIndex,
      slotIndex: slotIndex ?? this.slotIndex,
      completedAt: completedAt ?? this.completedAt,
      timeCapsuleMessage: timeCapsuleMessage ?? this.timeCapsuleMessage,
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
      'status': status.name,
      'frameIndex': frameIndex,
      'slotIndex': slotIndex,
      'completedAt': completedAt?.toIso8601String(),
      'timeCapsuleMessage': timeCapsuleMessage,
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
      status: GoalStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? 'active'),
        orElse: () => GoalStatus.active,
      ),
      frameIndex: json['frameIndex'] as int? ?? 0,
      slotIndex: json['slotIndex'] as int? ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      timeCapsuleMessage: json['timeCapsuleMessage'] as String?,
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
    return 'Goal{id: $id, title: $title, totalCount: $totalCount, status: $status}';
  }
}
