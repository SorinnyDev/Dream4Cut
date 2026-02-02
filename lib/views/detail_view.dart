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
  final TextEditingController _logController = TextEditingController();
  bool _isSaving = false;
  bool _showCompletionOverlay = false;

  @override
  void dispose() {
    _logController.dispose();
    super.dispose();
  }

  void _triggerCompletion() async {
    // Show overlay first for emotional payoff
    setState(() => _showCompletionOverlay = true);

    // Process completion in background
    await context.read<GoalProvider>().completeGoal(widget.goal.id);
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
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('기록이 안전하게 보관되었습니다.')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGoals = context.watch<GoalProvider>().goals;
    final currentGoal = allGoals.firstWhere(
      (g) => g.id == widget.goal.id,
      orElse: () => widget.goal,
    );

    final themeIndex = AppTheme.getThemeIndex(currentGoal.backgroundTheme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          currentGoal.title,
          style: AppTheme.headingSmall.copyWith(
            fontWeight: FontWeight.w900,
            color: themeSet.text,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: themeSet.text,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (currentGoal.status == GoalStatus.active)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: Bounceable(
                  onTap: _triggerCompletion,
                  child: MaskingTape(
                    text: '완성하기',
                    rotation: 0.05,
                    color: themeSet.point,
                    textStyle: AppTheme.caption.copyWith(
                      color: themeSet.text.withOpacity(0.8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // 전체 배경 종이 질감 오버레이
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: PaperTexturePainter()),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
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

                        // Log Input Section (Sketchy Diary Input)
                        if (currentGoal.status == GoalStatus.active)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingL,
                            ),
                            child: HandDrawnContainer(
                              backgroundColor: Colors.white.withOpacity(0.8),
                              borderColor: themeSet.point.withOpacity(0.4),
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.edit_note_rounded,
                                        color: themeSet.point,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: TextField(
                                          controller: _logController,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                            hintText: '오늘의 조각을 기록하세요...',
                                            hintStyle: AppTheme.bodyMedium
                                                .copyWith(
                                                  color: themeSet.text
                                                      .withOpacity(0.3),
                                                ),
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                          style: AppTheme.bodyLarge.copyWith(
                                            color: themeSet.text,
                                            height: 1.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  // Underline effect
                                  Container(
                                    height: 1,
                                    width: double.infinity,
                                    color: themeSet.point.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: AppTheme.spacingL),
                        _buildDashedDivider(),
                        const SizedBox(height: AppTheme.spacingL),

                        // Logs Timeline
                        _buildLogsHistory(currentGoal, themeSet),
                        const SizedBox(height: 120), // Space for bottom button
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Fixed Bottom Button
            if (currentGoal.status == GoalStatus.active)
              Positioned(
                left: 20,
                right: 20,
                bottom: 20 + MediaQuery.of(context).padding.bottom,
                child: Bounceable(
                  onTap: _isSaving ? null : _saveLog,
                  child: HandDrawnContainer(
                    backgroundColor: themeSet.point,
                    borderColor: themeSet.text.withOpacity(0.2),
                    padding: EdgeInsets.zero,
                    child: Container(
                      height: 60,
                      alignment: Alignment.center,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              '기록 저장하기',
                              style: AppTheme.headingSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 2.0,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.1),
                                    offset: const Offset(1, 1),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),

            if (_showCompletionOverlay)
              _CompletionOverlay(
                goal: currentGoal,
                onClose: () => Navigator.pop(context, true),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      child: Row(
        children: List.generate(
          40,
          (index) => Expanded(
            child: Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              color: AppTheme.pencilCharcoal.withOpacity(0.1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogsHistory(Goal currentGoal, GoalThemeSet themeSet) {
    return FutureBuilder<List<Log>>(
      future: context.read<GoalProvider>().getLogs(currentGoal.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty)
          return const SizedBox();

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
                _buildDateHeader(dateKey, themeSet),
                ...logsForDate
                    .map((log) => _buildLogItem(log, themeSet))
                    .toList(),
                const SizedBox(height: AppTheme.spacingL),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(String dateKey, GoalThemeSet themeSet) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Text(
        dateKey.replaceAll('-', ' . '),
        style: AppTheme.caption.copyWith(
          fontWeight: FontWeight.w900,
          color: themeSet.text.withOpacity(0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogItem(Log log, GoalThemeSet themeSet) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: themeSet.text.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: themeSet.point,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${log.index}번째 기록',
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: themeSet.text.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            log.content,
            style: AppTheme.bodyMedium.copyWith(
              color: themeSet.text,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionOverlay extends StatelessWidget {
  final Goal goal;
  final VoidCallback onClose;

  const _CompletionOverlay({required this.goal, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final themeIndex = int.tryParse(goal.backgroundTheme.split('_').last) ?? 0;

    return Material(
      color: Colors.black.withOpacity(0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, color: Colors.amber, size: 80),
            const SizedBox(height: 16),
            Text(
              'G O A L    I N',
              style: AppTheme.headingLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 8.0,
              ),
            ),
            const SizedBox(height: 48),

            // Show the 1x4 Frame mockup
            Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (index) {
                  final isTarget = index == goal.slotIndex;
                  return Container(
                    height: 60,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isTarget
                          ? AppTheme.getPastelColor(themeIndex).withOpacity(0.5)
                          : AppTheme.ivoryPaper,
                      border: Border.all(
                        color: isTarget
                            ? AppTheme.pencilCharcoal
                            : AppTheme.pencilDash.withOpacity(0.3),
                      ),
                    ),
                    child: Center(
                      child: isTarget
                          ? Text(
                              goal.title,
                              style: AppTheme.bodyMedium.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : Icon(
                              Icons.photo,
                              color: AppTheme.pencilDash.withOpacity(0.5),
                              size: 20,
                            ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 60),
            Bounceable(
              onTap: onClose,
              child: MaskingTape(
                text: '수집 보관함으로',
                height: 48,
                color: AppTheme.getGoalTheme(themeIndex).point,
                textStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.getGoalTheme(
                    themeIndex,
                  ).text.withOpacity(0.8),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
