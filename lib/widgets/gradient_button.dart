import 'package:flutter/material.dart';

/// Full-width (or inline) gradient button used throughout the app.
class GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> colors;
  final bool mini;

  const GradientButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
    required this.colors,
    this.mini = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: mini ? 10 : 14,
          horizontal: mini ? 16 : 0,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(mini ? 10 : 14),
          boxShadow: [
            BoxShadow(
              color: colors.first.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: mini ? 16 : 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: mini ? 13 : 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}