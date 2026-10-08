import 'package:flutter/material.dart';

class BackToMenuButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const BackToMenuButton({
    super.key,
    required this.onPressed,
    this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? Colors.tealAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: buttonColor.withValues(alpha: 0.2),
        highlightColor: buttonColor.withValues(alpha: 0.1),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: buttonColor.withValues(alpha: 0.5), width: 1.5),
            color: buttonColor.withValues(alpha: 0.1),
          ),
          child: Icon(
            Icons.arrow_back,
            color: buttonColor,
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}

// Versión con texto para uso en menús
class BackToMenuTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final IconData icon;
  final Color color;

  const BackToMenuTextButton({
    super.key,
    required this.onPressed,
    this.label = 'MENÚ PRINCIPAL',
    this.icon = Icons.home,
    this.color = Colors.tealAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
            color: color.withValues(alpha: 0.1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'monospace',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}