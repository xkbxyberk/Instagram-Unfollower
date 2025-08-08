import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/dark_theme_colors.dart';

class ProgressRing extends StatefulWidget {
  final double progress; // 0.0 - 1.0
  final Color color;
  final double size;
  final double strokeWidth;
  final Widget? child;

  const ProgressRing({
    super.key,
    required this.progress,
    required this.color,
    this.size = 80,
    this.strokeWidth = 8,
    this.child,
  });

  @override
  State<ProgressRing> createState() => _ProgressRingState();
}

class _ProgressRingState extends State<ProgressRing>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: 1.0,
                  color: isDark
                      ? DarkThemeColors.dividerColor
                      : Colors.grey.shade200,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
              // Progress circle
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _ProgressRingPainter(
                  progress: widget.progress * _animation.value,
                  color: widget.color,
                  strokeWidth: widget.strokeWidth,
                  isDark: isDark,
                ),
              ),
              // Child widget
              if (widget.child != null) widget.child!,
            ],
          ),
        );
      },
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool isDark;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.isDark = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Add subtle shadow for dark theme
    if (isDark && progress > 0) {
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..strokeWidth = strokeWidth + 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

      final center = Offset(size.width / 2, size.height / 2);
      final radius = (size.width - strokeWidth) / 2;
      final startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        shadowPaint,
      );
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final startAngle = -math.pi / 2; // Top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
