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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        title: const Text('새 수집 목표'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Column(
            children: [
              const MaskingTape(text: 'DREAM MEMO', width: 140),
              const SizedBox(height: 20),

              // Diary Page Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: AppTheme.paperShadow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('나의 새로운 발자국은 무엇인가요?', style: AppTheme.headingSmall),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '목표를 입력하세요 (예: 물 2L 마시기)',
                        hintStyle: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textTertiary,
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppTheme.pencilDash),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: AppTheme.textSecondary,
                            width: 2,
                          ),
                        ),
                      ),
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      '색상 선택',
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(AppTheme.pastelColors.length, (
                        index,
                      ) {
                        return GestureDetector(
                          onTap: () =>
                              setState(() => _selectedThemeIndex = index),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: AppTheme.pastelColors[index],
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedThemeIndex == index
                                    ? AppTheme.textPrimary
                                    : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: _selectedThemeIndex == index
                                  ? [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: _selectedThemeIndex == index
                                ? const Icon(
                                    Icons.check,
                                    color: AppTheme.textPrimary,
                                  )
                                : null,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 50),
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          if (_titleController.text.isNotEmpty) {
                            await context.read<GoalProvider>().addGoal(
                              _titleController.text,
                              'theme_$_selectedThemeIndex',
                              widget.frameIndex,
                              widget.slotIndex,
                            );
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.textPrimary,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            '수집 시작하기',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white,
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
}
