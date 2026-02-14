import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─────────────────────────────────────────────────────────────
// LATENCY TIER
// ─────────────────────────────────────────────────────────────
enum LatencyTier { excellent, good, fair }

extension LatencyTierExt on LatencyTier {
  Color colorFor(AppThemeColors c) {
    switch (this) {
      case LatencyTier.excellent: return c.green;
      case LatencyTier.good:      return c.yellow;
      case LatencyTier.fair:      return c.orange;
    }
  }
}

// ─────────────────────────────────────────────────────────────
// FOUND IP
// ─────────────────────────────────────────────────────────────
class FoundIP {
  final String ip;
  final int latencyMs;
  final String range;
  final DateTime foundAt;

  const FoundIP({
    required this.ip,
    required this.latencyMs,
    required this.range,
    required this.foundAt,
  });

  LatencyTier get tier {
    if (latencyMs < 200) return LatencyTier.excellent;
    if (latencyMs < 500) return LatencyTier.good;
    return LatencyTier.fair;
  }
}