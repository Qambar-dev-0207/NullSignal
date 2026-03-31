import 'package:flutter/material.dart';
import 'package:null_signal/core/services/feedback_service.dart';

class PanicButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final Color? color;
  final Color? textColor;

  const PanicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Panic Action: $label',
      hint: 'Large tap area, triggers immediately',
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Theme.of(context).colorScheme.primary,
          foregroundColor: textColor ?? Theme.of(context).colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 96),
        ),
        onPressed: () {
          FeedbackService.triggerConfirmation();
          onPressed();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 48),
              const SizedBox(width: 16),
            ],
            Text(label, style: const TextStyle(fontSize: 32)),
          ],
        ),
      ),
    );
  }
}
