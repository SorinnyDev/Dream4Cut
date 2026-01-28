import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';

class MaskingTape extends StatelessWidget {
  final String text;
  final Color color;
  final double width;
  final double height;
  final double rotation;
  final TextStyle? textStyle;

  const MaskingTape({
    super.key,
    this.text = '',
    this.color = AppTheme.maskingTape,
    this.width = 100,
    this.height = 30,
    this.rotation = -0.05,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: color.withOpacity(0.95), // 투명도를 95% 이상으로 높임
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 0,
              offset: const Offset(1, 1),
            ),
          ],
        ),
        child: ClipPath(
          clipper: TapeClipper(),
          child: Container(
            color: color,
            alignment: Alignment.center,
            child: text.isNotEmpty
                ? Text(
                    text,
                    style:
                        textStyle ??
                        AppTheme.caption.copyWith(
                          color: AppTheme.textPrimary.withOpacity(0.8),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          fontSize: 10,
                        ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}

class TapeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height);

    // Bottom jagged edge
    for (var i = 0; i <= 10; i++) {
      path.lineTo(size.width / 10 * i, size.height - (i % 2 == 0 ? 2 : 0));
    }

    path.lineTo(size.width, 0);

    // Top jagged edge
    for (var i = 10; i >= 0; i--) {
      path.lineTo(size.width / 10 * i, (i % 2 == 0 ? 2 : 0));
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// 손글씨/연필 느낌의 테두리를 가진 컨테이너
class HandDrawnContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsets padding;
  final double strokeWidth;
  final bool showShadow;
  final Color? backgroundColor;

  const HandDrawnContainer({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(16),
    this.strokeWidth = 1.0,
    this.showShadow = true,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        boxShadow: showShadow ? AppTheme.paperShadow : null,
      ),
      child: CustomPaint(
        painter: HandDrawnPainter(
          color: color ?? AppTheme.pencilCharcoal,
          strokeWidth: strokeWidth,
        ),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class HandDrawnPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  HandDrawnPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final random = math.Random(42);

    void drawSkewedLine(Offset start, Offset end) {
      final path = Path();
      path.moveTo(start.dx, start.dy);

      int segments = 8;
      for (int i = 1; i <= segments; i++) {
        double t = i / segments;
        double x = start.dx + (end.dx - start.dx) * t;
        double y = start.dy + (end.dy - start.dy) * t;

        x += (random.nextDouble() - 0.5) * 1.5;
        y += (random.nextDouble() - 0.5) * 1.5;

        path.lineTo(x, y);
      }
      canvas.drawPath(path, paint);
    }

    drawSkewedLine(Offset.zero, Offset(size.width, 0));
    drawSkewedLine(Offset(size.width, 0), Offset(size.width, size.height));
    drawSkewedLine(Offset(size.width, size.height), Offset(0, size.height));
    drawSkewedLine(Offset(0, size.height), Offset.zero);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

/// 클릭 시 콩콩 뛰는 효과 (Scale Animation)
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
