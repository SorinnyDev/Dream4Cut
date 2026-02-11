import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
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
    HapticFeedback.mediumImpact();
    setState(() => _showCompletionOverlay = true);

    // Process completion in background
    await context.read<GoalProvider>().completeGoal(widget.goal.id);
  }

  final List<String> _successMessages = [
    "오늘도 한 걸음 나아갔어요!",
    "꿈의 조각이 하나 더 채워졌네요",
    "소중한 발걸음이 기록되었습니다",
    "당신의 노력이 조각으로 남았어요",
    "한 칸 한 칸 꿈에 가까워지고 있어요",
  ];

  Future<void> _saveLog() async {
    final content = _logController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await context.read<GoalProvider>().addLog(widget.goal.id, content);

      final random = math.Random();
      final message = _successMessages[random.nextInt(_successMessages.length)];

      if (mounted) {
        HapticFeedback.heavyImpact(); // 저장 시 강한 햅틱 피드백
        _logController.clear();
        FocusScope.of(context).unfocus();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            backgroundColor: AppTheme.pencilCharcoal.withOpacity(0.9),
          ),
        );
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
      backgroundColor: AppTheme.oatSilk,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          currentGoal.title,
          style: AppTheme.titleSmall.copyWith(
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
          // 타임캡슐 아이콘 (봉인된 편지)
          if (currentGoal.timeCapsuleMessage != null &&
              currentGoal.status == GoalStatus.active)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: const Icon(
                  Icons.markunread_mailbox_outlined,
                  color: AppTheme.textSecondary,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('꿈을 이룬 날에 공개됩니다!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ),

          if (currentGoal.status == GoalStatus.active)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Center(
                child: Bounceable(
                  onTap: _triggerCompletion,
                  child: MaskingTape(
                    text: '꿈의 매듭 짓기',
                    rotation: 0.05,
                    color: themeSet.point,
                    textStyle: AppTheme.handwritingMedium.copyWith(
                      color: AppTheme.creamWhite,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
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
                        const SizedBox(height: AppTheme.spacingL + 10),

                        // Log Input Section (Sketchy Diary Input)
                        if (currentGoal.status == GoalStatus.active)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingL,
                            ),
                            child: HandDrawnContainer(
                              backgroundColor: Colors.white,
                              borderColor: AppTheme.getSmartBorderColor(
                                themeSet.point,
                              ),
                              padding: const EdgeInsets.all(AppTheme.spacingM),
                              showOffsetLayer: false,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Icon(
                                          Icons.edit_note_rounded,
                                          color: themeSet.point,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextField(
                                          controller: _logController,
                                          maxLines: null,
                                          keyboardType: TextInputType.multiline,
                                          decoration: InputDecoration(
                                            hintText: '오늘의 조각을 기록하세요...',
                                            hintStyle: AppTheme.bodyRegular
                                                .copyWith(
                                                  color: themeSet.text
                                                      .withOpacity(0.3),
                                                ),
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            isDense: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: AppTheme.bodyRegular.copyWith(
                                            color: themeSet.text,
                                            height: 1.6,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  // Underline effect (Pencil line)
                                  Container(
                                    height: 1.2,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: AppTheme.getSmartBorderColor(
                                        themeSet.point,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        const SizedBox(height: AppTheme.spacingXl),
                        _buildDashedDivider(),
                        const SizedBox(height: AppTheme.spacingL),

                        // Logs Timeline
                        _buildLogsHistory(currentGoal, themeSet),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
                // 하단 고정 버튼 (SafeArea 적용, 5px 여백)
                if (currentGoal.status == GoalStatus.active)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 5),
                      child: Bounceable(
                        onTap: _isSaving ? null : _saveLog,
                        child: HandDrawnContainer(
                          backgroundColor: const Color(0xFF8B7355), // 따뜻한 브라운 톤
                          borderColor: AppTheme.getSmartBorderColor(
                            const Color(0xFF8B7355),
                          ),
                          padding: EdgeInsets.zero,
                          borderRadius: 16,
                          useMultiply: true,
                          child: Container(
                            height: 60,
                            alignment: Alignment.center,
                            child: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: AppTheme.creamWhite,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Text(
                                    '오늘의 발걸음 남기기',
                                    style: AppTheme.bodyBold.copyWith(
                                      color: AppTheme.creamWhite,
                                      fontSize: 16,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
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
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL + 12),
      child: Row(
        children: List.generate(
          30,
          (index) => Expanded(
            child: Container(
              height: 1.2,
              margin: const EdgeInsets.symmetric(horizontal: 2),
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
      padding: const EdgeInsets.only(left: 32, bottom: 12),
      child: Text(
        '# ${dateKey.replaceAll('-', ' . ')}',
        style: AppTheme.labelSmall.copyWith(
          fontWeight: FontWeight.w900,
          color: themeSet.text.withOpacity(0.5),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildLogItem(Log log, GoalThemeSet themeSet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: HandDrawnContainer(
        showOffsetLayer: false,
        backgroundColor: Colors.white,
        borderColor: themeSet.text.withOpacity(0.08),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: themeSet.point.withOpacity(0.8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${log.index}번째 꿈의 조각',
                  style: AppTheme.labelSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    color: themeSet.text.withOpacity(0.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              log.content,
              style: AppTheme.bodyRegular.copyWith(
                color: themeSet.text,
                height: 1.6,
              ),
            ),
          ],
        ),
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
    final themeIndex = AppTheme.getThemeIndex(goal.backgroundTheme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    return Material(
      color: Colors.black.withOpacity(0.88),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.amber,
              size: 80,
            ),
            const SizedBox(height: 24),
            Text(
              'G O A L    I N',
              style: AppTheme.titleLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 10.0,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '꿈의 한 마디를 매듭지었습니다.',
              style: AppTheme.bodyLight.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),

            if (goal.timeCapsuleMessage != null) ...[
              HandDrawnContainer(
                backgroundColor: AppTheme.oatSilk,
                borderColor: AppTheme.getSmartBorderColor(themeSet.point),
                padding: const EdgeInsets.all(AppTheme.spacingL),
                borderRadius: 4,
                child: Column(
                  children: [
                    const Icon(
                      Icons.mail_outline,
                      color: AppTheme.textSecondary,
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '미래의 나에게서 온 편지',
                      style: AppTheme.labelSmall.copyWith(
                        color: AppTheme.textTertiary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '"${goal.timeCapsuleMessage}"',
                      style: AppTheme.titleSmall.copyWith(
                        color: AppTheme.textPrimary,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],

            Container(
              width: 280,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 30,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (index) {
                  final isTarget = index == goal.slotIndex;
                  return Container(
                    height: 64,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: isTarget
                          ? themeSet.background.withOpacity(0.6)
                          : AppTheme.ivoryPaper.withOpacity(0.3),
                      border: Border.all(
                        color: isTarget
                            ? themeSet.text
                            : AppTheme.pencilDash.withOpacity(0.2),
                        width: isTarget ? 1.5 : 0.8,
                      ),
                    ),
                    child: Center(
                      child: isTarget
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                goal.title,
                                style: AppTheme.bodyBold.copyWith(
                                  color: themeSet.text,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Icon(
                              Icons.photo_outlined,
                              color: AppTheme.pencilDash.withOpacity(0.5),
                              size: 24,
                            ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 80),
            Bounceable(
              onTap: onClose,
              child: MaskingTape(
                text: '우리의 조각 앨범으로',
                height: 52,
                color: themeSet.point,
                textStyle: AppTheme.bodyBold.copyWith(
                  color: AppTheme.creamWhite,
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
