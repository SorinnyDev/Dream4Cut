import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

/// 마스킹 테이프 위젯 - 가변형(Intrinsic Width) 및 거친 질감 구현
class MaskingTape extends StatelessWidget {
  final String text;
  final Color color;
  final double? width;
  final double height;
  final double rotation;
  final TextStyle? textStyle;
  final bool isTransparent;
  final double opacity;

  const MaskingTape({
    super.key,
    this.text = '',
    required this.color,
    this.width,
    this.height = 30,
    this.rotation = -0.05,
    this.textStyle,
    this.isTransparent = true,
    this.opacity = 0.85,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: IntrinsicWidth(
        child: Stack(
          children: [
            // 레이어 그림자 (약간 어긋난 단색 레이어)
            Positioned(
              left: 1.5,
              top: 1.5,
              child: Opacity(opacity: 0.1, child: _buildBody(Colors.black)),
            ),
            _buildBody(color.withOpacity(isTransparent ? opacity : 0.95)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Color tapeColor) {
    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // Multiply 블렌딩 모드를 적용한 배경
          Positioned.fill(
            child: CustomPaint(
              painter: _MultiplyTapePainter(
                color: tapeColor,
                clipper: JaggedTapeClipper(),
              ),
            ),
          ),

          // 테두리 (1.0px 딥 브라운)
          Positioned.fill(
            child: CustomPaint(
              painter: _TapeBorderPainter(
                borderColor: AppTheme.deepBrownBorder.withOpacity(0.2),
                clipper: JaggedTapeClipper(),
              ),
            ),
          ),

          // 텍스트 영역
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: text.isNotEmpty
                  ? Transform.rotate(
                      angle: 0.026,
                      child: Text(
                        text,
                        style:
                            textStyle ??
                            AppTheme.handwritingSmall.copyWith(
                              color: Colors.black.withOpacity(0.7),
                              fontSize: 13,
                            ),
                        maxLines: 1,
                      ),
                    )
                  : const SizedBox(width: 30),
            ),
          ),

          // 미세한 종이 질감(Noise) 오버레이
          IgnorePointer(
            child: ClipPath(
              clipper: JaggedTapeClipper(),
              child: CustomPaint(painter: TexturePainter(opacity: 0.08)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Multiply 블렌딩을 적용한 테이프 배경 페인터
class _MultiplyTapePainter extends CustomPainter {
  final Color color;
  final CustomClipper<Path> clipper;

  _MultiplyTapePainter({required this.color, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..blendMode = BlendMode.multiply;

    final path = clipper.getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 테이프 테두리 페인터
class _TapeBorderPainter extends CustomPainter {
  final Color borderColor;
  final CustomClipper<Path> clipper;

  _TapeBorderPainter({required this.borderColor, required this.clipper});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = clipper.getClip(size);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 질감/노이즈를 그려주는 페인터
class TexturePainter extends CustomPainter {
  final double opacity;
  TexturePainter({this.opacity = 0.03});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final paint = Paint()..color = Colors.black.withOpacity(opacity);
    for (int i = 0; i < 120; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.3, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 프리미엄 노이즈 텍스처 페인터 (Multiply 블렌딩)
class NoiseTexturePainter extends CustomPainter {
  final double opacity;

  NoiseTexturePainter({this.opacity = 0.03});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12345);
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity)
      ..blendMode = BlendMode.multiply;

    // 더 조밀한 노이즈 그레인
    for (int i = 0; i < 300; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      double dotSize = random.nextDouble() * 0.8 + 0.2;
      canvas.drawCircle(Offset(x, y), dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 양 끝이 손으로 찢은 듯 거친 질감을 표현하는 클리퍼
class JaggedTapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var random = math.Random(123);

    path.moveTo(random.nextDouble() * 3, 0);

    for (var i = 1; i <= 12; i++) {
      path.lineTo(size.width / 12 * i, random.nextDouble() * 1.5);
    }

    path.lineTo(size.width - random.nextDouble() * 4, size.height / 2);
    path.lineTo(size.width - random.nextDouble() * 3, size.height);

    for (var i = 11; i >= 0; i--) {
      path.lineTo(size.width / 12 * i, size.height - random.nextDouble() * 1.5);
    }

    path.lineTo(random.nextDouble() * 4, size.height / 2);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// 손글씨/연필 느낌의 테두리와 '어긋난 레이어', '종이 질감'을 가진 컨테이너
class HandDrawnContainer extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final EdgeInsets padding;
  final double strokeWidth;
  final bool showOffsetLayer;
  final bool showStackEffect;
  final double borderRadius;
  final bool useTexture;
  final bool useMultiply;

  const HandDrawnContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.strokeWidth = 1.2,
    this.showOffsetLayer = false,
    this.showStackEffect = false,
    this.borderRadius = 8.0,
    this.useTexture = true,
    this.useMultiply = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ??
        AppTheme.getSmartBorderColor(backgroundColor ?? Colors.white);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (showStackEffect) ...[
          Positioned(
            left: -3,
            top: 3,
            right: 3,
            bottom: -3,
            child: _buildBackground(Colors.black.withOpacity(0.04), 0.8),
          ),
        ],
        Container(
          decoration: BoxDecoration(
            color: useMultiply ? Colors.transparent : backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              if (useMultiply && backgroundColor != null)
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MultiplyBackgroundPainter(
                      color: backgroundColor!,
                      borderRadius: borderRadius,
                    ),
                  ),
                ),
              if (useTexture)
                Positioned.fill(
                  child: CustomPaint(painter: PaperTexturePainter()),
                ),
              CustomPaint(
                painter: HandDrawnPainter(
                  color: effectiveBorderColor,
                  strokeWidth: strokeWidth,
                  borderRadius: borderRadius,
                ),
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackground(Color color, double rotation) {
    return Transform.rotate(
      angle: rotation * 0.015,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppTheme.pencilCharcoal.withOpacity(0.08)),
        ),
      ),
    );
  }
}

/// Multiply 배경 페인터
class _MultiplyBackgroundPainter extends CustomPainter {
  final Color color;
  final double borderRadius;

  _MultiplyBackgroundPainter({required this.color, required this.borderRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..blendMode = BlendMode.multiply;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(borderRadius),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 오래된 종이 질감을 표현하는 페인터
class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(10);
    final paint = Paint();

    // 밝은 점들 (Paper fiber 느낌)
    for (int i = 0; i < 300; i++) {
      paint.color = Colors.black.withOpacity(random.nextDouble() * 0.008);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 0.5,
        paint,
      );
    }

    // 빈티지 얼룩 (Mottled effect)
    final spotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 6; i++) {
      // 인화지/종이 특유의 미세한 변색
      spotPaint.color = const Color(0xFFD2B48C).withOpacity(0.012);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 50 + 20,
        spotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class HandDrawnPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double borderRadius;

  HandDrawnPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final random = math.Random(456);

    // 약간의 떨림을 주기 위해 직선별로 그림
    void drawSkewedLine(Offset start, Offset end) {
      final path = Path();
      path.moveTo(start.dx, start.dy);

      int segments = 10;
      for (int i = 1; i <= segments; i++) {
        double t = i / segments;
        double x = start.dx + (end.dx - start.dx) * t;
        double y = start.dy + (end.dy - start.dy) * t;

        // 아주 미세한 떨림 (다이어리 손그림 감성)
        x += (random.nextDouble() - 0.5) * 0.4;
        y += (random.nextDouble() - 0.5) * 0.4;

        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    // 테두리 실선 그리기 (RRect를 따르되 약간의 수작업 느낌)
    // 상단
    drawSkewedLine(
      Offset(borderRadius, 0),
      Offset(size.width - borderRadius, 0),
    );
    // 우측
    drawSkewedLine(
      Offset(size.width, borderRadius),
      Offset(size.width, size.height - borderRadius),
    );
    // 하단
    drawSkewedLine(
      Offset(size.width - borderRadius, size.height),
      Offset(borderRadius, size.height),
    );
    // 좌측
    drawSkewedLine(
      Offset(0, size.height - borderRadius),
      Offset(0, borderRadius),
    );

    // 코너 아치 (간단하게 그려주거나 생략 가능하지만, 완성도를 위해 drawArc)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, borderRadius * 2, borderRadius * 2),
      math.pi,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - borderRadius * 2,
        0,
        borderRadius * 2,
        borderRadius * 2,
      ),
      -math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width - borderRadius * 2,
        size.height - borderRadius * 2,
        borderRadius * 2,
        borderRadius * 2,
      ),
      0,
      math.pi / 2,
      false,
      paint,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        0,
        size.height - borderRadius * 2,
        borderRadius * 2,
        borderRadius * 2,
      ),
      math.pi / 2,
      math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 클릭 시 콩콩 뛰는 효과 + 햅틱 피드백
class Bounceable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const Bounceable({super.key, required this.child, this.onTap});

  @override
  State<Bounceable> createState() => _BounceableState();
}

class _BounceableState extends State<Bounceable>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
