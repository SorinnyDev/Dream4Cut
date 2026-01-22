/// Log 모델 - 실천 기록 데이터 구조
///
/// 각 실천 기록의 상세 정보 관리
/// - 실제 실천일과 작성 시간 분리
/// - 누적 순번으로 "N번째 발걸음" 표시
class Log {
  final String id;
  final String goalId; // 연결된 Goal의 ID
  final String content; // 실천 내용
  final DateTime actionDate; // 실제 실천일 (날짜만, 시간 무시)
  final DateTime createdAt; // 작성 시간 (타임스탬프)
  final int index; // 누적 순번 (1-based)

  Log({
    required this.id,
    required this.goalId,
    required this.content,
    required this.actionDate,
    required this.createdAt,
    required this.index,
  });

  /// 이 로그가 속한 인화지 번호 (1-based)
  int get sheetNumber => ((index - 1) ~/ 200) + 1;

  /// 인화지 내 위치 (0-based, 0~199)
  int get positionInSheet => (index - 1) % 200;

  /// 날짜별 그룹화를 위한 키 (YYYY-MM-DD)
  String get dateKey {
    return '${actionDate.year}-${actionDate.month.toString().padLeft(2, '0')}-${actionDate.day.toString().padLeft(2, '0')}';
  }

  /// 연도별 그룹화를 위한 키
  int get yearKey => actionDate.year;

  Log copyWith({
    String? id,
    String? goalId,
    String? content,
    DateTime? actionDate,
    DateTime? createdAt,
    int? index,
  }) {
    return Log(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      content: content ?? this.content,
      actionDate: actionDate ?? this.actionDate,
      createdAt: createdAt ?? this.createdAt,
      index: index ?? this.index,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goalId': goalId,
      'content': content,
      'actionDate': actionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'index': index,
    };
  }

  factory Log.fromJson(Map<String, dynamic> json) {
    return Log(
      id: json['id'] as String,
      goalId: json['goalId'] as String,
      content: json['content'] as String,
      actionDate: DateTime.parse(json['actionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      index: json['index'] as int,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Log && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Log{id: $id, index: $index, content: $content, actionDate: $dateKey}';
  }
}
