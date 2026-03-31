import 'package:flutter/material.dart';
import 'package:null_signal/core/theme/app_theme.dart';

/// A consistent card following the NullSignal design principles:
/// 12px rounded corners, black background, and generous padding.
class NullSignalCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  const NullSignalCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    return Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: color ?? colors.surfaceLowest,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors.onSurface.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// The base scaffold for NullSignal screens, ensuring maximum whitespace
/// and the consistent Inter semibold typography for headers.
class NullSignalScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  const NullSignalScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<NullSignalColors>()!;
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(title.toUpperCase()),
        actions: actions,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: body,
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
