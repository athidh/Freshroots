import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// An animated circular freshness gauge that smoothly transitions
/// both progress and color based on a 0.0–1.0 freshness percentage.
///
/// Green (>0.7) → Orange (0.4–0.7) → Red (<0.4)
class FreshnessGauge extends StatefulWidget {
  final double freshness; // 0.0 to 1.0
  final double size;
  final double strokeWidth;
  final String? label;

  const FreshnessGauge({
    super.key,
    required this.freshness,
    this.size = 120,
    this.strokeWidth = 10,
    this.label,
  });

  @override
  State<FreshnessGauge> createState() => _FreshnessGaugeState();
}

class _FreshnessGaugeState extends State<FreshnessGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _prevFreshness = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _prevFreshness = widget.freshness;
    _animation = Tween<double>(begin: 0, end: widget.freshness).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(FreshnessGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.freshness != widget.freshness) {
      _prevFreshness = _animation.value;
      _animation = Tween<double>(
        begin: _prevFreshness,
        end: widget.freshness,
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getColor(double value) {
    if (value > 0.7) {
      return Color.lerp(AppTheme.sunsetOrange, AppTheme.forestGreen,
          (value - 0.7) / 0.3)!;
    } else if (value > 0.4) {
      return Color.lerp(AppTheme.errorRed, AppTheme.sunsetOrange,
          (value - 0.4) / 0.3)!;
    } else {
      return AppTheme.errorRed;
    }
  }

  String _getStatusLabel(double value) {
    if (value > 0.85) return 'OPTIMAL';
    if (value > 0.7) return 'GOOD';
    if (value > 0.5) return 'FAIR';
    if (value > 0.3) return 'LOW';
    return 'CRITICAL';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = _animation.value;
        final color = _getColor(value);
        final percent = (value * 100).toInt();

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background track
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugeTrackPainter(
                  strokeWidth: widget.strokeWidth,
                  trackColor: color.withValues(alpha: 0.12),
                ),
              ),
              // Progress arc
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _GaugeProgressPainter(
                  progress: value,
                  strokeWidth: widget.strokeWidth,
                  color: color,
                ),
              ),
              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percent%',
                    style: TextStyle(
                      fontSize: widget.size * 0.22,
                      fontWeight: FontWeight.w800,
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.label ?? _getStatusLabel(value),
                    style: TextStyle(
                      fontSize: widget.size * 0.09,
                      fontWeight: FontWeight.w700,
                      color: color.withValues(alpha: 0.7),
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GaugeTrackPainter extends CustomPainter {
  final double strokeWidth;
  final Color trackColor;

  _GaugeTrackPainter({required this.strokeWidth, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = trackColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75, // Start from bottom-left
      pi * 1.5, // 270 degrees
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeTrackPainter oldDelegate) =>
      trackColor != oldDelegate.trackColor;
}

class _GaugeProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _GaugeProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Add glow shadow
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = strokeWidth + 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final sweepAngle = pi * 1.5 * progress;

    // Draw glow
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      sweepAngle,
      false,
      glowPaint,
    );

    // Draw arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi * 0.75,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugeProgressPainter oldDelegate) => true;
}
