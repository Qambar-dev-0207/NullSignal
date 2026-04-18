import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:null_signal/core/services/feedback_service.dart';
import 'package:null_signal/core/theme/app_theme.dart';

class BiologicalPulseTrigger extends StatefulWidget {
  final VoidCallback onTrigger;
  final bool isLoading;
  final String label;

  const BiologicalPulseTrigger({
    super.key,
    required this.onTrigger,
    this.isLoading = false,
    this.label = 'TRIGGER SOS',
  });

  @override
  State<BiologicalPulseTrigger> createState() => _BiologicalPulseTriggerState();
}

class _BiologicalPulseTriggerState extends State<BiologicalPulseTrigger> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _scaleController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
      lowerBound: 0.95,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    return GestureDetector(
      onTapDown: (_) => _scaleController.reverse(),
      onTapUp: (_) => _scaleController.forward(),
      onTapCancel: () => _scaleController.forward(),
      onTap: () {
        FeedbackService.triggerSosHaptics();
        widget.onTrigger();
      },
      child: ScaleTransition(
        scale: _scaleController,
        child: SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer Pulse Rings
              ...List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    double progress = (_pulseController.value + (index * 0.33)) % 1.0;
                    return Container(
                      width: 120 + (progress * 160),
                      height: 120 + (progress * 160),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.error.withValues(alpha: (1.0 - progress) * 0.3),
                          width: 2,
                        ),
                      ),
                    );
                  },
                );
              }),

              // Rotating Technical Ring
              RotationTransition(
                turns: _rotationController,
                child: CustomPaint(
                  size: const Size(220, 220),
                  painter: TechnicalRingPainter(color: colors.error.withValues(alpha: 0.2)),
                ),
              ),

              // Core Button
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.error,
                  boxShadow: [
                    BoxShadow(
                      color: colors.error.withValues(alpha: 0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                    else ...[
                      const Icon(Icons.emergency, color: Colors.white, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        widget.label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
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

class TechnicalRingPainter extends CustomPainter {
  final Color color;
  TechnicalRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw broken segments
    for (int i = 0; i < 8; i++) {
      double startAngle = (i * math.pi / 4) + 0.2;
      double sweepAngle = (math.pi / 4) - 0.4;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    // Draw outer dots
    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 24; i++) {
      double angle = i * 2 * math.pi / 24;
      double x = center.dx + (radius + 15) * math.cos(angle);
      double y = center.dy + (radius + 15) * math.sin(angle);
      canvas.drawCircle(Offset(x, y), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
