import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/analog_widgets.dart';

class ThemeSettingsView extends StatelessWidget {
  const ThemeSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.ivoryPaper,
      appBar: AppBar(
        title: Text('테마 설정', style: AppTheme.handwritingMedium),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.spacingL),
                Text(
                  '홈 화면 배경 선택',
                  style: AppTheme.bodyBold.copyWith(fontSize: 16),
                ),
                const SizedBox(height: AppTheme.spacingL),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppTheme.spacingL,
                    crossAxisSpacing: AppTheme.spacingL,
                    childAspectRatio: 0.8,
                    children: [
                      _buildBackgroundOption(
                        context,
                        settings,
                        0,
                        '기본 (Eggshell)',
                        null,
                      ),
                      _buildBackgroundOption(
                        context,
                        settings,
                        1,
                        '그리드 (Grid)',
                        CustomPaint(painter: GridPaperPainter(gridSize: 15)),
                      ),
                      _buildBackgroundOption(
                        context,
                        settings,
                        2,
                        '유선 (Lined)',
                        CustomPaint(painter: LinedPaperPainter(lineHeight: 18)),
                      ),
                      _buildBackgroundOption(
                        context,
                        settings,
                        3,
                        '리뉴얼 (Legal Pad)',
                        SvgPicture.asset(
                          'assets/backgrounds/legal_pad.svg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBackgroundOption(
    BuildContext context,
    SettingsProvider settings,
    int index,
    String title,
    Widget? preview,
  ) {
    final isSelected = settings.homeBackgroundIndex == index;

    return Bounceable(
      onTap: () => settings.setHomeBackgroundIndex(index),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.warmBrown
                      : Colors.black.withOpacity(
                          0.5,
                        ), // Clearly visible dark border
                  width: isSelected ? 3.0 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppTheme.warmBrown.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(2, 4),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: index == 0 ? AppTheme.ivoryPaper : Colors.white,
                    ),
                  ),
                  if (preview != null) Positioned.fill(child: preview),
                  if (isSelected)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppTheme.warmBrown,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(painter: PaperTexturePainter()),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: AppTheme.bodySmall.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.warmBrown : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
