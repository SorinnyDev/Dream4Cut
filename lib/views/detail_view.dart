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
  late Future<List<Log>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _refreshLogs();
  }

  void _refreshLogs() {
    _logsFuture = context.read<GoalProvider>().getLogs(widget.goal.id);
  }

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

      // 로그 추가 후 리스트 갱신
      setState(() {
        _refreshLogs();
      });

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

  void _showEditGoalDialog(
    BuildContext context,
    Goal goal,
    GoalThemeSet themeSet,
  ) {
    final titleController = TextEditingController(text: goal.title);
    int selectedThemeIndex = AppTheme.getThemeIndex(goal.backgroundTheme);
    String selectedEmoji = goal.emojiTag;

    // 사용 가능한 이모지 목록
    const availableEmojis = [
      '🌟',
      '✨',
      '💫',
      '🌈',
      '🌺',
      '🌸',
      '🌼',
      '🌻',
      '🌹',
      '🌷',
      '🌵',
      '🌱',
      '🍀',
      '🌿',
      '☘️',
      '🍁',
      '🍂',
      '🍃',
      '🍄',
      '🌾',
      '🐞',
      '🦋',
      '🦟',
      '🐝',
      '🐚',
      '🐛',
      '🐙',
      '🐌',
      '🌏',
      '🌎',
      '🌍',
      '🌐',
      '💪',
      '👏',
      '✌️',
      '✊',
      '🤝',
      '👍',
      '❤️',
      '💖',
      '💛',
      '💚',
      '💙',
      '💜',
      '🧡',
      '💓',
      '💗',
      '💕',
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: AppTheme.creamWhite,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: const Offset(0, 10),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '꿈 수정하기',
                    style: AppTheme.titleSmall.copyWith(
                      fontWeight: FontWeight.w900,
                      color: themeSet.text,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 제목 입력
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: '꿈의 이름',
                      labelStyle: AppTheme.bodyRegular.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: themeSet.point, width: 2),
                      ),
                    ),
                    style: AppTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 이모지 선택
                  Text(
                    '스티커',
                    style: AppTheme.bodyBold.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 70,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: availableEmojis.length,
                      itemBuilder: (context, index) {
                        final emoji = availableEmojis[index];
                        final isSelected = selectedEmoji == emoji;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: Bounceable(
                            onTap: () =>
                                setDialogState(() => selectedEmoji = emoji),
                            child: Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.getGoalTheme(
                                        selectedThemeIndex,
                                      ).background
                                    : AppTheme.ivoryPaper.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.getGoalTheme(
                                          selectedThemeIndex,
                                        ).point
                                      : AppTheme.pencilDash.withOpacity(0.3),
                                  width: isSelected ? 2.5 : 1.0,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 36),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 테마 색상 선택
                  Text(
                    '테마 컬러',
                    style: AppTheme.bodyBold.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: List.generate(AppTheme.goalThemes.length, (
                      index,
                    ) {
                      final isSelected = selectedThemeIndex == index;
                      final theme = AppTheme.getGoalTheme(index);
                      return Bounceable(
                        onTap: () =>
                            setDialogState(() => selectedThemeIndex = index),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: theme.background,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? theme.text
                                  : theme.text.withOpacity(0.1),
                              width: isSelected ? 2.5 : 1.2,
                            ),
                          ),
                          child: isSelected
                              ? Icon(Icons.check, color: theme.text, size: 20)
                              : null,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // 버튼
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            '취소',
                            style: AppTheme.bodyBold.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final newTitle = titleController.text.trim();
                            if (newTitle.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('제목을 입력해주세요')),
                              );
                              return;
                            }

                            final updatedGoal = goal.copyWith(
                              title: newTitle,
                              backgroundTheme: 'theme_$selectedThemeIndex',
                              emojiTag: selectedEmoji,
                              updatedAt: DateTime.now(),
                            );

                            await context.read<GoalProvider>().updateGoal(
                              updatedGoal,
                            );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('수정되었습니다'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: themeSet.point,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            '저장',
                            style: AppTheme.bodyBold.copyWith(
                              color: AppTheme.creamWhite,
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
        ),
      ),
    );
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

    // 배경색에 따른 적응형 텍스트 색상
    final adaptiveTextColor = AppTheme.getAdaptiveTextColor(
      themeSet.scaffoldBg,
    );
    // 버튼 색상에 따른 버튼 텍스트 색상
    final buttonTextColor = AppTheme.getAdaptiveTextColor(themeSet.point);

    return Scaffold(
      backgroundColor: themeSet.scaffoldBg, // 스마트 팔레트 배경색 적용
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          currentGoal.title,
          style: AppTheme.titleSmall.copyWith(
            fontWeight: FontWeight.w900,
            color: adaptiveTextColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: adaptiveTextColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // 수정 버튼 (원형 스티커 디자인)
          if (currentGoal.status == GoalStatus.active) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Bounceable(
                onTap: () {
                  _showEditGoalDialog(context, currentGoal, themeSet);
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: themeSet.point,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Center(
                    child: HandDrawnContainer(
                      padding: EdgeInsets.zero,
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.white.withOpacity(0.5),
                      borderRadius: 19,
                      useTexture: false,
                      child: const Center(
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 타임캡슐 아이콘 (봉인된 편지)
          if (currentGoal.timeCapsuleMessage != null &&
              currentGoal.status == GoalStatus.active) ...[
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(
                  Icons.markunread_mailbox_outlined,
                  color: adaptiveTextColor.withOpacity(0.8),
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
          ],

          if (currentGoal.status == GoalStatus.active) ...[
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
                      color: buttonTextColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // 전체 배경 노이즈 텍스처 (Multiply)
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: NoiseTexturePainter(opacity: 0.04)),
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
                          child: RepaintBoundary(
                            child: StampSheetStack(
                              totalCount: currentGoal.totalCount,
                              theme: currentGoal.backgroundTheme,
                            ),
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
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                      child: Bounceable(
                        onTap: _isSaving ? null : _saveLog,
                        child: Container(
                          height: 64,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                themeSet.point,
                                themeSet.point.withOpacity(0.85),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: themeSet.point.withOpacity(0.3),
                                offset: const Offset(0, 8),
                                blurRadius: 20,
                                spreadRadius: -4,
                              ),
                              BoxShadow(
                                color: themeSet.point.withOpacity(0.2),
                                offset: const Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _isSaving ? null : _saveLog,
                              child: Container(
                                alignment: Alignment.center,
                                child: _isSaving
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: buttonTextColor,
                                          strokeWidth: 3,
                                        ),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.auto_awesome_rounded,
                                            color: buttonTextColor,
                                            size: 22,
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            '오늘의 발걸음 남기기',
                                            style: AppTheme.handwritingMedium
                                                .copyWith(
                                                  color: buttonTextColor,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w700,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                        ],
                                      ),
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
      future: _logsFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox();
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
                _buildDateHeader(dateKey, themeSet),
                ...List.generate(logsForDate.length, (index) {
                  final log = logsForDate[index];
                  // 로그마다 고유한 랜덤 값 생성
                  final random = math.Random(log.id.hashCode);
                  final rotation = (random.nextDouble() - 0.5) * 0.08;
                  final xOffset = (random.nextDouble() - 0.5) * 20.0;
                  final topOverlap = index == 0 ? 0.0 : -15.0; // 미세하게 겹치게

                  return Transform.translate(
                    offset: Offset(xOffset, topOverlap),
                    child: _buildLogItem(log, themeSet, random, rotation),
                  );
                }),
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
          color: AppTheme.getAdaptiveTextColor(
            themeSet.scaffoldBg,
          ).withOpacity(0.5),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildLogItem(
    Log log,
    GoalThemeSet themeSet,
    math.Random random,
    double rotation,
  ) {
    // 5가지 텍스처 중 랜덤하게 선택
    final textures = MemoTexture.values;
    final texture = textures[random.nextInt(textures.length)];

    // 마스킹 테이프 설정 (위치 다르게)
    final tapePositions = [
      Alignment.topCenter,
      Alignment.topLeft,
      Alignment.topRight,
    ];
    final tapeAlignment = tapePositions[random.nextInt(tapePositions.length)];
    final tapeRotation = (random.nextDouble() - 0.5) * 0.3;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            MemoSticker(
              texture: texture,
              rotation: rotation,
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
                          color: AppTheme.pencilCharcoal.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    log.content,
                    style: AppTheme.bodyRegular.copyWith(
                      color: AppTheme.pencilCharcoal,
                      height: 1.6,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Positioned.fill(
              child: Align(
                alignment: tapeAlignment,
                child: Transform.translate(
                  offset: const Offset(0, -12),
                  child: MaskingTape(
                    rotation: tapeRotation,
                    color: themeSet.point,
                    opacity: 0.6,
                    height: 24,
                    width: 60,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionOverlay extends StatefulWidget {
  final Goal goal;
  final VoidCallback onClose;

  const _CompletionOverlay({required this.goal, required this.onClose});

  @override
  State<_CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<_CompletionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _showContent = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _showContent = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goal = widget.goal;
    final themeIndex = AppTheme.getThemeIndex(goal.backgroundTheme);
    final themeSet = AppTheme.getGoalTheme(themeIndex);

    return Material(
      color: Colors.black.withOpacity(0.92),
      child: InkWell(
        onTap: widget.onClose,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Center(
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
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
                      '꿈의 매듭을 지었습니다.',
                      style: AppTheme.bodyLight.copyWith(
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 60),
                    if (goal.timeCapsuleMessage != null) ...[
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.fastOutSlowIn,
                        width: 300,
                        padding: EdgeInsets.only(top: _showContent ? 0 : 100),
                        child: HandDrawnContainer(
                          backgroundColor: const Color(0xFFFFFBEB),
                          borderColor: themeSet.point,
                          padding: const EdgeInsets.all(28),
                          borderRadius: 2,
                          child: Column(
                            children: [
                              const Icon(
                                Icons.mail_rounded,
                                color: Color(0xFFD97706),
                                size: 36,
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '과거의 나로부터 도착한 응원',
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.warmBrown.withOpacity(0.4),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                '"${goal.timeCapsuleMessage}"',
                                style: AppTheme.handwritingMedium.copyWith(
                                  color: AppTheme.warmBrown,
                                  fontSize: 18,
                                  height: 1.6,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                    Text(
                      '화면을 터치하여 닫기',
                      style: AppTheme.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.3),
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
