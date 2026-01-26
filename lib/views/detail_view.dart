import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/goal.dart';
import '../models/log.dart';
import '../theme/app_theme.dart';
import '../widgets/stamp_sheet.dart';
import '../widgets/analog_widgets.dart';
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
  final TextEditingController _logController = TextEditingController();
  bool _isSaving = false;

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
    _logController.dispose();
    super.dispose();
  }

  void _triggerCompletion() async {
    setState(() => _isStamped = true);
    await _stampController.forward();

    if (mounted) {
      await context.read<GoalProvider>().completeGoal(widget.goal.id);
      if (mounted) {
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _saveLog() async {
    if (_logController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await context.read<GoalProvider>().addLog(
        widget.goal.id,
        _logController.text.trim(),
      );
      _logController.clear();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('발걸음이 기록되었습니다.')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Look up the goal from provider to get latest count
    final allGoals = context.watch<GoalProvider>().goals;
    final currentGoal = allGoals.firstWhere(
      (g) => g.id == widget.goal.id,
      orElse: () => widget.goal,
    );

    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        title: Text(currentGoal.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (currentGoal.status == GoalStatus.active)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: GestureDetector(
                  onTap: _triggerCompletion,
                  child: const MaskingTape(
                    text: '완성',
                    width: 60,
                    height: 32,
                    rotation: 0.05,
                  ),
                ),
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
                    totalCount: currentGoal.totalCount,
                    theme: currentGoal.backgroundTheme,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingL),

                // Log Input Section (Only for active goals)
                if (currentGoal.status == GoalStatus.active)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingL,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(AppTheme.spacingM),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: AppTheme.paperShadow,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppTheme.pencilDash.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.water_drop,
                                color: AppTheme.getPastelColor(
                                  0,
                                ).withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _logController,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    hintText: '오늘의 발걸음을 기록해보세요.',
                                    hintStyle: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textTertiary.withOpacity(
                                        0.6,
                                      ),
                                    ),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                  ),
                                  style: AppTheme.bodyLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 1.5,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppTheme.textPrimary.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              GestureDetector(
                                onTap: _isSaving ? null : _saveLog,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.getAccentColor(
                                      0,
                                    ).withOpacity(_isSaving ? 0.6 : 1.0),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.getAccentColor(
                                          0,
                                        ).withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    _isSaving ? '기록중' : '작성완료',
                                    style: AppTheme.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: AppTheme.spacingL),
                _buildDashedDivider(),
                const SizedBox(height: AppTheme.spacingL),

                // Real Logs History
                FutureBuilder<List<Log>>(
                  future: context.read<GoalProvider>().getLogs(currentGoal.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Text(
                            '첫 발걸음을 기록해보세요!',
                            style: AppTheme.bodySmall,
                          ),
                        ),
                      );
                    }

                    final logs = snapshot.data!;
                    final Map<String, List<Log>> groupedLogs = {};
                    for (var log in logs) {
                      if (!groupedLogs.containsKey(log.dateKey)) {
                        groupedLogs[log.dateKey] = [];
                      }
                      groupedLogs[log.dateKey]!.add(log);
                    }
                    final List<String> sortedDates = groupedLogs.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: sortedDates.length,
                      itemBuilder: (context, dateIndex) {
                        final dateKey = sortedDates[dateIndex];
                        final logsForDate = groupedLogs[dateKey]!;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDateHeader(dateKey),
                            ...logsForDate
                                .map((log) => _buildLogItem(log))
                                .toList(),
                            const SizedBox(height: AppTheme.spacingL),
                          ],
                        );
                      },
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
