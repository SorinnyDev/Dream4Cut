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
          '새 수집 목표',
          style: AppTheme.headingSmall.copyWith(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: [
              const MaskingTape(text: 'DREAM MEMO', width: 140),
              const SizedBox(height: 20),

              HandDrawnContainer(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나의 새로운 발걸음은\n무엇인가요?',
                      style: AppTheme.headingSmall.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '목표를 입력하세요 (예: 매일 만보 걷기)',
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textTertiary.withOpacity(0.4),
                        ),
                        // AppTheme의 InputTheme을 사용하도록 간소화
                      ),
                      style: AppTheme.headingMedium.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 48),
                    Text(
                      '수집 테마',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(AppTheme.pastelColors.length, (
                        index,
                      ) {
                        final isSelected = _selectedThemeIndex == index;
                        final deepColor = AppTheme.getDeepMutedColor(index);
                        return Bounceable(
                          onTap: () =>
                              setState(() => _selectedThemeIndex = index),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.pastelColors[index].withOpacity(
                                0.8,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected
                                    ? deepColor
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: deepColor.withOpacity(0.2),
                                        offset: const Offset(2, 2),
                                        blurRadius: 0,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? Icon(Icons.check, color: deepColor, size: 20)
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 60),
                    Center(
                      child: Bounceable(
                        onTap: _isSaving ? null : _saveGoal,
                        child: Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.getDeepMutedColor(
                              _selectedThemeIndex,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: _isSaving
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    '목표 정하기',
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveGoal() async {
    if (_titleController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);
    try {
      await context.read<GoalProvider>().addGoal(
        _titleController.text.trim(),
        'theme_$_selectedThemeIndex',
        widget.frameIndex,
        widget.slotIndex,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}
