import 'package:flutter/material.dart';

class FadeInAnimation extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 800),
    this.offset = const Offset(0, 20),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: offset * (1.0 - value),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class GlitchText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const GlitchText(this.text, {super.key, this.style});

  @override
  State<GlitchText> createState() => _GlitchTextState();
}

class _GlitchTextState extends State<GlitchText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Text(
              widget.text,
              style: widget.style?.copyWith(
                color: Colors.red.withValues(alpha: 0.5),
              ),
            ),
            Transform.translate(
              offset: Offset(_controller.value * 2, 0),
              child: Text(
                widget.text,
                style: widget.style?.copyWith(
                  color: Colors.blue.withValues(alpha: 0.5),
                ),
              ),
            ),
            Text(
              widget.text,
              style: widget.style,
            ),
          ],
        );
      },
    );
  }
}

class PulseContainer extends StatefulWidget {
  final Widget child;
  final Color color;

  const PulseContainer({super.key, required this.child, required this.color});

  @override
  State<PulseContainer> createState() => _PulseContainerState();
}

class _PulseContainerState extends State<PulseContainer> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.2 * _controller.value),
                blurRadius: 10 * _controller.value,
                spreadRadius: 5 * _controller.value,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}
