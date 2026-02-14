import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../main.dart';
import '../theme/app_theme.dart';

/// Full-screen animated blob/orb background that reacts to the active theme.
class AnimatedBackground extends AnimatedWidget {
  const AnimatedBackground({super.key, required Animation<double> animation})
      : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final t = (listenable as Animation<double>).value;
    final c = appSettings.colors;
    return CustomPaint(
      size: MediaQuery.of(context).size,
      painter: _OrbPainter(t, c),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// PAINTER
// ─────────────────────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  final double t;
  final AppThemeColors c;

  _OrbPainter(this.t, this.c);

  @override
  void paint(Canvas canvas, Size size) {
    final orbs = [
      _Orb(
        x: 0.15 + math.sin(t * math.pi) * 0.08,
        y: 0.25 + math.cos(t * math.pi * 0.7) * 0.10,
        radius: size.width * 0.38,
        color: Color.lerp(c.accent1, c.bg, 0.5)!.withOpacity(0.35),
      ),
      _Orb(
        x: 0.80 + math.sin(t * math.pi * 1.1) * 0.06,
        y: 0.55 + math.cos(t * math.pi * 0.9) * 0.08,
        radius: size.width * 0.32,
        color: Color.lerp(c.accent2, c.bg, 0.5)!.withOpacity(0.30),
      ),
      _Orb(
        x: 0.50 + math.sin(t * math.pi * 0.8) * 0.07,
        y: 0.80 + math.cos(t * math.pi * 1.2) * 0.06,
        radius: size.width * 0.28,
        color: Color.lerp(c.green, c.bg, 0.6)!.withOpacity(0.25),
      ),
    ];

    for (final orb in orbs) {
      final center = Offset(size.width * orb.x, size.height * orb.y);
      canvas.drawCircle(
        center,
        orb.radius,
        Paint()
          ..shader = RadialGradient(
            colors: [orb.color, Colors.transparent],
          ).createShader(Rect.fromCircle(center: center, radius: orb.radius))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 60),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbPainter old) => true;
}

class _Orb {
  final double x, y, radius;
  final Color color;
  const _Orb({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
  });
}