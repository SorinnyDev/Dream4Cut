import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/goal_provider.dart';
import '../widgets/analog_widgets.dart';

class GoalCreateView extends StatefulWidget {
  final int frameIndex;
  final int slotIndex;

  const GoalCreateView({
    super.key,
    required this.frameIndex,
    required this.slotIndex,
  });

  @override
  State<GoalCreateView> createState() => _GoalCreateViewState();
}

class _GoalCreateViewState extends State<GoalCreateView> {
  final _titleController = TextEditingController();
  final _timeCapsuleController = TextEditingController();
  int _selectedThemeIndex = 0;
  String _selectedEmoji = '🌟'; // 기본 이모지
  bool _isSaving = false;

  // 사용 가능한 이모지 목록
  static const List<String> _availableEmojis = [
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

  @override
  void dispose() {
    _titleController.dispose();
    _timeCapsuleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stopwatch = Stopwatch()..start();
    final result = Scaffold(
      backgroundColor: AppTheme.oatSilk,
      appBar: AppBar(
        title: Text(
          '나의 새로운 발걸음',
          style: AppTheme.titleSmall.copyWith(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(
              children: [
                HandDrawnContainer(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  backgroundColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '나의 꿈은 무엇인가요?',
                        style: AppTheme.titleSmall.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: '꿈의 이름을 알려주세요',
                          hintStyle: AppTheme.bodyRegular.copyWith(
                            color: AppTheme.textTertiary.withOpacity(0.4),
                          ),
                        ),
                        style: AppTheme.titleMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '미래의 나에게 보낼 응원 한마디',
                        style: AppTheme.bodyBold.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '* 이 메세지는 꿈을 이룬 날에 공개됩니다.',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.textTertiary,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _timeCapsuleController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: '꿈을 향한 여정을 시작하며...',
                          hintStyle: AppTheme.bodyRegular.copyWith(
                            color: AppTheme.textTertiary.withOpacity(0.4),
                          ),
                          filled: true,
                          fillColor: AppTheme.oatSilk.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        '이 꿈의 조각을 대표하는 스티커',
                        style: AppTheme.bodyBold.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _availableEmojis.length,
                          itemBuilder: (context, index) {
                            final emoji = _availableEmojis[index];
                            final isSelected = _selectedEmoji == emoji;
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: Bounceable(
                                onTap: () {
                                  setState(() {
                                    _selectedEmoji = emoji;
                                  });
                                },
                                child: Container(
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.getGoalTheme(
                                            _selectedThemeIndex,
                                          ).background
                                        : AppTheme.ivoryPaper.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.getGoalTheme(
                                              _selectedThemeIndex,
                                            ).point
                                          : AppTheme.pencilDash.withOpacity(
                                              0.3,
                                            ),
                                      width: isSelected ? 2.5 : 1.0,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: AppTheme.getGoalTheme(
                                                _selectedThemeIndex,
                                              ).point.withOpacity(0.2),
                                              offset: const Offset(0, 4),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
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
                      const SizedBox(height: 40),
                      Text(
                        '기록의 조각 컬러',
                        style: AppTheme.bodyBold.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: List.generate(AppTheme.goalThemes.length, (
                          index,
                        ) {
                          final isSelected = _selectedThemeIndex == index;
                          final themeSet = AppTheme.getGoalTheme(index);
                          return Bounceable(
                            onTap: () {
                              setState(() {
                                _selectedThemeIndex = index;
                              });
                            },
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: themeSet.background,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? themeSet.text
                                      : themeSet.text.withOpacity(0.1),
                                  width: isSelected ? 2.5 : 1.2,
                                ),
                              ),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: themeSet.text,
                                      size: 20,
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 60),
                      Center(
                        child: Bounceable(
                          onTap: _isSaving
                              ? null
                              : () {
                                  _saveGoal();
                                },
                          child: HandDrawnContainer(
                            backgroundColor: AppTheme.getGoalTheme(
                              _selectedThemeIndex,
                            ).point,
                            borderColor: AppTheme.getSmartBorderColor(
                              AppTheme.getGoalTheme(_selectedThemeIndex).point,
                            ),
                            padding: EdgeInsets.zero,
                            borderRadius: 12,
                            useMultiply: true,
                            child: Container(
                              height: 56,
                              width: double.infinity,
                              alignment: Alignment.center,
                              child: _isSaving
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppTheme.getAdaptiveTextColor(
                                          AppTheme.getGoalTheme(
                                            _selectedThemeIndex,
                                          ).point,
                                        ),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      '꿈의 기록장 시작하기',
                                      style: AppTheme.bodyBold.copyWith(
                                        color: AppTheme.getAdaptiveTextColor(
                                          AppTheme.getGoalTheme(
                                            _selectedThemeIndex,
                                          ).point,
                                        ),
                                        letterSpacing: 2.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final elapsed = stopwatch.elapsedMilliseconds;
    if (elapsed > 16) {
      debugPrint(
        "[Performance Warning] GoalCreateView Build Time: ${elapsed}ms",
      );
    }
    return result;
  }

  Future<void> _saveGoal() async {
    final title = _titleController.text.trim();
    final timeCapsule = _timeCapsuleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('꿈의 이름을 알려주세요!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await context.read<GoalProvider>().addGoal(
        title,
        'theme_$_selectedThemeIndex',
        widget.frameIndex,
        widget.slotIndex,
        timeCapsuleMessage: timeCapsule.isNotEmpty ? timeCapsule : null,
        emojiTag: _selectedEmoji,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('기록 시작 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
