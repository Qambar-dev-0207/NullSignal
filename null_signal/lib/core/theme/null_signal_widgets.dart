import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:null_signal/core/theme/app_theme.dart';
import 'package:null_signal/core/utils/animations.dart';

class NullSignalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final bool animate;
  final int delay;

  const NullSignalCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.animate = true,
    this.delay = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: color ?? colors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.1)),
      ),
      child: child,
    );

    if (animate) {
      return FadeInAnimation(
        delay: Duration(milliseconds: delay * 100),
        child: content,
      );
    }
    return content;
  }
}

class NullSignalScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool showMeshBackground;

  const NullSignalScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.showMeshBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    return Scaffold(
      backgroundColor: colors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: GlitchText(title.toUpperCase(), style: Theme.of(context).appBarTheme.titleTextStyle),
        actions: actions,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          if (showMeshBackground) const MeshBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: body,
            ),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}

class MeshBackground extends StatefulWidget {
  const MeshBackground({super.key});

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size.infinite,
          painter: _MeshBackgroundPainter(
            progress: _controller.value,
            color: colors.primaryContainer.withValues(alpha: 0.03),
          ),
        );
      },
    );
  }
}

class BaryonLoader extends StatefulWidget {
  final double size;
  final Color? color;

  const BaryonLoader({super.key, this.size = 24, this.color});

  @override
  State<BaryonLoader> createState() => _BaryonLoaderState();
}

class _BaryonLoaderState extends State<BaryonLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    final color = widget.color ?? colors.primaryContainer;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final double progress = (_controller.value + (index * 0.2)) % 1.0;
            final double scale = 0.5 + (0.5 * math.sin(progress * math.pi));
            return Container(
              width: widget.size * 0.4,
              height: widget.size * 0.4,
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: scale),
                border: Border.all(color: color, width: 1),
              ),
            );
          },
        );
      }),
    );
  }
}

class _MeshBackgroundPainter extends CustomPainter {
  final double progress;
  final Color color;

  _MeshBackgroundPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const int rows = 15;
    const int cols = 15;
    final cellWidth = size.width / cols;
    final cellHeight = size.height / rows;

    for (int i = 0; i <= rows; i++) {
      for (int j = 0; j <= cols; j++) {
        final double offset = math.sin((progress * 2 * math.pi) + (i * 0.5) + (j * 0.5)) * 10;
        if (i < rows) {
          canvas.drawLine(
            Offset(j * cellWidth + offset, i * cellHeight),
            Offset(j * cellWidth + offset, (i + 1) * cellHeight),
            paint,
          );
        }
        if (j < cols) {
          canvas.drawLine(
            Offset(j * cellWidth, i * cellHeight + offset),
            Offset((j + 1) * cellWidth, i * cellHeight + offset),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
