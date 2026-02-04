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
    return Container(
      width: width,
      height: height,
      child: Stack(
        children: [
          ClipPath(
            clipper: JaggedTapeClipper(),
            child: Container(
              color: tapeColor,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: text.isNotEmpty
                  ? Transform.rotate(
                      angle: 0.026, // 약 1.5도 기울기 - 손글씨 감성 추가
                      child: Text(
                        text,
                        style:
                            textStyle ??
                            AppTheme.labelSmall.copyWith(
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                              fontSize: 12,
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

  const HandDrawnContainer({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor = Colors.white,
    this.padding = const EdgeInsets.all(16),
    this.strokeWidth = 1.0,
    this.showOffsetLayer = true,
    this.showStackEffect = false,
    this.borderRadius = 2.0,
    this.useTexture = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ?? AppTheme.pencilCharcoal.withOpacity(0.4);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (showStackEffect) ...[
          // 뒤쪽 겹친 종이 1
          Positioned(
            left: -2,
            top: 2,
            right: 2,
            bottom: -2,
            child: _buildBackground(Colors.black.withOpacity(0.03), 1.0),
          ),
          // 뒤쪽 겹친 종이 2
          Positioned(
            left: 2,
            top: -2,
            right: -2,
            bottom: 2,
            child: _buildBackground(
              backgroundColor?.withOpacity(0.5) ??
                  Colors.white.withOpacity(0.5),
              -1.0,
            ),
          ),
        ],
        if (showOffsetLayer)
          Positioned(
            left: 3,
            top: 3,
            right: -3,
            bottom: -3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Stack(
            children: [
              if (useTexture)
                Positioned.fill(
                  child: CustomPaint(painter: PaperTexturePainter()),
                ),
              CustomPaint(
                painter: HandDrawnPainter(
                  color: effectiveBorderColor,
                  strokeWidth: strokeWidth,
                  borderRadius: borderRadius,
                  useTexture: false,
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
          border: Border.all(color: AppTheme.pencilCharcoal.withOpacity(0.05)),
        ),
      ),
    );
  }
}

/// 오래된 종이 질감을 표현하는 페인터
class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(10);
    final paint = Paint();

    for (int i = 0; i < 200; i++) {
      paint.color = Colors.black.withOpacity(random.nextDouble() * 0.015);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 0.6,
        paint,
      );
    }

    final spotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 4; i++) {
      spotPaint.color = const Color(0xFFD2B48C).withOpacity(0.02);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 30 + 10,
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
  final bool useTexture;

  HandDrawnPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    this.useTexture = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final random = math.Random(456);

    void drawSkewedLine(Offset start, Offset end) {
      final path = Path();
      path.moveTo(start.dx, start.dy);

      int segments = 8;
      for (int i = 1; i <= segments; i++) {
        double t = i / segments;
        double x = start.dx + (end.dx - start.dx) * t;
        double y = start.dy + (end.dy - start.dy) * t;

        x += (random.nextDouble() - 0.5) * 0.6;
        y += (random.nextDouble() - 0.5) * 0.6;

        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    // 외곽선
    drawSkewedLine(Offset.zero, Offset(size.width, 0));
    drawSkewedLine(Offset(size.width, 0), Offset(size.width, size.height));
    drawSkewedLine(Offset(size.width, size.height), Offset(0, size.height));
    drawSkewedLine(Offset(0, size.height), Offset.zero);
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
