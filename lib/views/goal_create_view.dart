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
  int _selectedThemeIndex = 0;
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        title: Text(
          '나의 새로운 시작',
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
                MaskingTape(
                  text: 'DREAM MEMO',
                  rotation: -0.02,
                  color: AppTheme.maskingTape,
                  textStyle: AppTheme.bodyBold.copyWith(
                    color: AppTheme.textPrimary.withOpacity(0.7),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                HandDrawnContainer(
                  padding: const EdgeInsets.all(AppTheme.spacingL),
                  backgroundColor: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '나의 새로운 발걸음은\n무엇인가요?',
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
                      const SizedBox(height: 48),
                      Text(
                        '기록의 분위기',
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
                            onTap: () =>
                                setState(() => _selectedThemeIndex = index),
                            child: Container(
                              width: 50,
                              height: 50,
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
                                      size: 24,
                                    )
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 60),
                      Center(
                        child: Bounceable(
                          onTap: _isSaving ? null : _saveGoal,
                          child: HandDrawnContainer(
                            backgroundColor: AppTheme.getGoalTheme(
                              _selectedThemeIndex,
                            ).point,
                            borderColor: AppTheme.getGoalTheme(
                              _selectedThemeIndex,
                            ).text.withOpacity(0.2),
                            padding: EdgeInsets.zero,
                            child: Container(
                              height: 56,
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
                                      '기록장 첫 장 시작하기',
                                      style: AppTheme.bodyBold.copyWith(
                                        color: Colors.white,
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
  }

  Future<void> _saveGoal() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('무엇을 수집할지 이름을 알려주세요!'),
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
