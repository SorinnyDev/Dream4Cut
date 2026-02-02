import 'package:flutter/material.dart';
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
    this.height = 32,
    this.rotation = -0.05,
    this.textStyle,
    this.isTransparent = true,
    this.opacity = 0.5, // 가이드라인 반영 (40-60% 투명도)
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
              left: 2,
              top: 2,
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
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: text.isNotEmpty
                  ? Transform.rotate(
                      angle: 0.026, // 약 1.5도 기울기
                      child: Text(
                        text,
                        style:
                            textStyle ??
                            AppTheme.caption.copyWith(
                              color: Colors.black.withOpacity(0.7),
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              fontSize: 12,
                            ),
                        maxLines: 1,
                      ),
                    )
                  : const SizedBox(width: 40),
            ),
          ),
          // 미세한 종이 질감(Noise) 오버레이
          IgnorePointer(
            child: ClipPath(
              clipper: JaggedTapeClipper(),
              child: CustomPaint(
                size: Size(width ?? 120, height),
                painter: TexturePainter(opacity: 0.05),
              ),
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
    for (int i = 0; i < 100; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), 0.4, paint);
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
    var random = math.Random(42);

    // 왼쪽 시작점 (거친 질감)
    path.moveTo(random.nextDouble() * 4, 0);

    // 상단 라인 (미세한 떨림)
    for (var i = 1; i <= 10; i++) {
      path.lineTo(size.width / 10 * i, random.nextDouble() * 2);
    }

    // 오른쪽 끝 (손으로 찢은 질감)
    path.lineTo(size.width - random.nextDouble() * 5, size.height / 2);
    path.lineTo(size.width - random.nextDouble() * 3, size.height);

    // 하단 라인 (미세한 떨림)
    for (var i = 9; i >= 0; i--) {
      path.lineTo(size.width / 10 * i, size.height - random.nextDouble() * 2);
    }

    // 왼쪽 끝 마무리
    path.lineTo(random.nextDouble() * 5, size.height / 2);
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
    this.borderRadius = 2.0,
    this.useTexture = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor =
        borderColor ?? AppTheme.pencilCharcoal.withOpacity(0.5);

    return Stack(
      children: [
        if (showOffsetLayer)
          Positioned(
            left: 3,
            top: 3,
            right: -3,
            bottom: -3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.04), // 어긋난 단색 레이어
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
                  useTexture: false, // Stack에서 따로 처리
                ),
                child: Padding(padding: padding, child: child),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 오래된 종이 질감을 표현하는 페인터
class PaperTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(10);
    final paint = Paint();

    // 미세한 노이즈
    for (int i = 0; i < 200; i++) {
      paint.color = Colors.black.withOpacity(random.nextDouble() * 0.02);
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 0.8,
        paint,
      );
    }

    // 미세한 얼룩/질감
    final spotPaint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 5; i++) {
      spotPaint.color = const Color(0xFFD2B48C).withOpacity(0.03); // Sepia spot
      canvas.drawCircle(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
        random.nextDouble() * 20 + 10,
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

    final random = math.Random(123);

    // 종이 결/노이즈 질감 표현
    if (useTexture) {
      final noisePaint = Paint()..color = Colors.black.withOpacity(0.02);
      for (int i = 0; i < 50; i++) {
        double x = random.nextDouble() * size.width;
        double y = random.nextDouble() * size.height;
        canvas.drawCircle(Offset(x, y), 0.5, noisePaint);
      }
    }

    void drawSkewedLine(Offset start, Offset end) {
      final path = Path();
      path.moveTo(start.dx, start.dy);

      int segments = 10;
      for (int i = 1; i <= segments; i++) {
        double t = i / segments;
        double x = start.dx + (end.dx - start.dx) * t;
        double y = start.dy + (end.dy - start.dy) * t;

        // 미세하게 떨리는 연필 선 느낌
        x += (random.nextDouble() - 0.5) * 0.7;
        y += (random.nextDouble() - 0.5) * 0.7;

        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    // 외곽선 그리기
    drawSkewedLine(Offset.zero, Offset(size.width, 0));
    drawSkewedLine(Offset(size.width, 0), Offset(size.width, size.height));
    drawSkewedLine(Offset(size.width, size.height), Offset(0, size.height));
    drawSkewedLine(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 클릭 시 콩콩 뛰는 효과
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
      end: 0.96,
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
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
