import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../models/log.dart';
import '../theme/app_theme.dart';
import '../widgets/stamp_sheet.dart';
import '../providers/goal_provider.dart';

class DetailView extends StatefulWidget {
  final Goal goal;

  const DetailView({Key? key, required this.goal}) : super(key: key);

  @override
  State<DetailView> createState() => _DetailViewState();
}

class _DetailViewState extends State<DetailView>
    with SingleTickerProviderStateMixin {
  late AnimationController _stampController;
  late Animation<double> _stampAnimation;
  bool _isStamped = false;

  @override
  void initState() {
    super.initState();
    _stampController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _stampAnimation = CurvedAnimation(
      parent: _stampController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _stampController.dispose();
    super.dispose();
  }

  void _triggerCompletion() async {
    setState(() => _isStamped = true);
    await _stampController.forward();

    // Update goal status
    if (mounted) {
      await context.read<GoalProvider>().completeGoal(widget.goal.id);

      // Navigate to Footsteps tab (index 1)
      // This requires the MainScaffold to change its state.
      // We'll use a simple pop with a result or just pop and the user can switch manually,
      // but the prompt says "[발걸음] 탭으로 이동".
      // Usually, this is handled by a state manager or by popping back to main and updating index.
      // For now, let's pop back.
      if (mounted) {
        Navigator.pop(context, true); // true indicates "Go to Footsteps"
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 임시 로그 데이터
    final List<Log> mockLogs = List.generate(10, (index) {
      return Log(
        id: 'log_$index',
        goalId: widget.goal.id,
        content: '${widget.goal.title} 실천 완료! 발걸음을 계속 이어가자.',
        actionDate: DateTime.now().subtract(Duration(days: index ~/ 2)),
        createdAt: DateTime.now(),
        index: widget.goal.totalCount - index,
      );
    });

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
        title: Text(widget.goal.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.goal.status == GoalStatus.active)
            TextButton(
              onPressed: _triggerCompletion,
              child: const Text(
                '완성',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: AppTheme.spacingM),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingL,
                  ),
                  child: StampSheetStack(
                    totalCount: widget.goal.totalCount,
                    theme: widget.goal.backgroundTheme,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),
                _buildDashedDivider(),
                const SizedBox(height: AppTheme.spacingL),
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
          if (_isStamped)
            Center(
              child: ScaleTransition(
                scale: _stampAnimation,
                child: RotationTransition(
                  turns: const AlwaysStoppedAnimation(-10 / 360),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.red.withOpacity(0.7),
                        width: 4,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'ACHIEVED',
                      style: AppTheme.headingLarge.copyWith(
                        color: Colors.red.withOpacity(0.7),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4.0,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: widget.goal.status == GoalStatus.active
          ? FloatingActionButton(
              onPressed: () {}, // 기록 기록 로직
              backgroundColor: AppTheme.getPastelColor(0),
              child: const Icon(Icons.edit_note_rounded, color: Colors.white),
            )
          : null,
    );
  }

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

  Widget _buildLogItem(Log log) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingL + 8,
        vertical: AppTheme.spacingS,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Icon(
              Icons.draw_outlined,
              size: 14,
              color: AppTheme.textTertiary,
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
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
