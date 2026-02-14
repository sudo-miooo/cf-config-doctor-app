import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';

/// Animated pulsing dot + "SCANNING" label shown while a scan is active.
class PulseDot extends StatefulWidget {
  final AppThemeColors colors;

  const PulseDot({super.key, required this.colors});

  @override
  State<PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.colors;
    return FadeTransition(
      opacity: Tween(begin: 0.3, end: 1.0).animate(_ctrl),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: c.accent1,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            appSettings.tr('scanning'),
            style: TextStyle(
              color: c.accent1,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}