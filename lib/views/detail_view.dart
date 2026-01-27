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

    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        title: Text(
          currentGoal.title,
          style: AppTheme.headingSmall.copyWith(fontWeight: FontWeight.w900),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (currentGoal.status == GoalStatus.active)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: Bounceable(
                  onTap: _triggerCompletion,
                  child: const MaskingTape(
                    text: '완성하기',
                    width: 70,
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

                      // Log Input Section
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
                                color: AppTheme.pencilCharcoal.withOpacity(0.1),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.edit_note,
                                      color: AppTheme.pencilCharcoal
                                          .withOpacity(0.5),
                                      size: 22,
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
                                                color: AppTheme.textTertiary
                                                    .withOpacity(0.4),
                                              ),
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        style: AppTheme.bodyLarge.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  height: 1,
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(top: 4),
                                  color: AppTheme.pencilCharcoal.withOpacity(
                                    0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: AppTheme.spacingL),
                      _buildDashedDivider(),
                      const SizedBox(height: AppTheme.spacingL),

                      // Logs Timeline
                      _buildLogsHistory(currentGoal),
                      const SizedBox(height: 100), // Space for bottom button
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
              bottom: 30,
              child: Bounceable(
                onTap: _isSaving ? null : _saveLog,
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.pencilCharcoal,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
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
                            '기록하기',
                            style: AppTheme.headingSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2.0,
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

  Widget _buildLogsHistory(Goal currentGoal) {
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
                _buildDateHeader(dateKey),
                ...logsForDate.map((log) => _buildLogItem(log)).toList(),
                const SizedBox(height: AppTheme.spacingL),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDateHeader(String dateKey) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 8),
      child: Text(
        dateKey.replaceAll('-', ' . '),
        style: AppTheme.caption.copyWith(
          fontWeight: FontWeight.w900,
          color: AppTheme.pencilCharcoal.withOpacity(0.5),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildLogItem(Log log) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppTheme.pencilCharcoal.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppTheme.pencilCharcoal,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${log.index}번째 기록',
                style: AppTheme.caption.copyWith(
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            log.content,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textPrimary,
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
              child: const MaskingTape(
                text: '수집 보관함으로',
                width: 140,
                height: 44,
                color: AppTheme.maskingTape,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
