import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../models/log.dart';
import '../theme/app_theme.dart';
import '../widgets/stamp_sheet.dart';

/// 상세 화면 - 인화지 스택 및 실천 히스토리
class DetailView extends StatelessWidget {
  final Goal goal;

  const DetailView({Key? key, required this.goal}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 임시 로그 데이터
    final List<Log> mockLogs = List.generate(10, (index) {
      return Log(
        id: 'log_$index',
        goalId: goal.id,
        content: '${goal.title} 실천 완료! 발걸음을 계속 이어가자.',
        actionDate: DateTime.now().subtract(Duration(days: index ~/ 2)),
        createdAt: DateTime.now(),
        index: goal.totalCount - index,
      );
    });

    // 날짜별 그룹화
    final Map<String, List<Log>> groupedLogs = {};
    for (var log in mockLogs) {
      if (!groupedLogs.containsKey(log.dateKey)) {
        groupedLogs[log.dateKey] = [];
      }
      groupedLogs[log.dateKey]!.add(log);
    }

    final List<String> sortedDates = groupedLogs.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        title: Text(goal.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: AppTheme.spacingM),

            // 상단: 인화지 스택 영역
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingL,
              ),
              child: StampSheetStack(
                totalCount: goal.totalCount,
                theme: goal.backgroundTheme,
              ),
            ),

            const SizedBox(height: AppTheme.spacingL),

            // 구분선 (연필 점선 느낌)
            _buildDashedDivider(),

            const SizedBox(height: AppTheme.spacingL),

            // 하단: 히스토리 리스트
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedDates.length,
              itemBuilder: (context, dateIndex) {
                final dateKey = sortedDates[dateIndex];
                final logs = groupedLogs[dateKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 마스킹 테이프 날짜 헤더
                    _buildDateHeader(dateKey),

                    ...logs.map((log) => _buildLogItem(log)).toList(),

                    const SizedBox(height: AppTheme.spacingL),
                  ],
                );
              },
            ),

            const SizedBox(height: AppTheme.spacingXxl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // 기록 기록 로직
        backgroundColor: AppTheme.getPastelColor(0),
        child: const Icon(Icons.edit_note_rounded, color: Colors.white),
      ),
    );
  }

  /// 연필 점선 구분선
  Widget _buildDashedDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Row(
        children: List.generate(
          30,
          (index) => Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              color: AppTheme.pencilDash.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }

  /// 날짜 헤더 (마스킹 테이프 질감)
  Widget _buildDateHeader(String dateKey) {
    return Container(
      margin: const EdgeInsets.only(
        left: AppTheme.spacingL,
        bottom: AppTheme.spacingM,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      transform: Matrix4.rotationZ(-0.02),
      decoration: BoxDecoration(
        color: AppTheme.maskingTape.withOpacity(0.7),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(1, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Text(
        dateKey.replaceAll('-', ' . '),
        style: AppTheme.bodyMedium.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.brown[800],
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  /// 개별 기록 아이템
  Widget _buildLogItem(Log log) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL + 8,
        vertical: AppTheme.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 불렛 아이콘
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.draw_outlined,
              size: 14,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),

          // 기록 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${log.index}번째 발걸음',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(log.content, style: AppTheme.bodyMedium),
                const SizedBox(height: 8),
                // 연한 밑줄
                Container(
                  height: 0.5,
                  color: AppTheme.pencilDash.withOpacity(0.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
