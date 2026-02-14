/// Immutable snapshot of live scan progress.
class ScanStats {
  final int totalScanned;
  final int totalFound;
  final int currentRangeScanned;
  final int currentRangeTotal;
  final int currentRangeIndex;
  final int totalRanges;
  final double ipsPerSecond;
  final String? currentRange;
  final bool isRunning;

  const ScanStats({
    this.totalScanned = 0,
    this.totalFound = 0,
    this.currentRangeScanned = 0,
    this.currentRangeTotal = 0,
    this.currentRangeIndex = 0,
    this.totalRanges = 0,
    this.ipsPerSecond = 0,
    this.currentRange,
    this.isRunning = false,
  });

  ScanStats copyWith({
    int? totalScanned,
    int? totalFound,
    int? currentRangeScanned,
    int? currentRangeTotal,
    int? currentRangeIndex,
    int? totalRanges,
    double? ipsPerSecond,
    String? currentRange,
    bool? isRunning,
  }) =>
      ScanStats(
        totalScanned: totalScanned ?? this.totalScanned,
        totalFound: totalFound ?? this.totalFound,
        currentRangeScanned: currentRangeScanned ?? this.currentRangeScanned,
        currentRangeTotal: currentRangeTotal ?? this.currentRangeTotal,
        currentRangeIndex: currentRangeIndex ?? this.currentRangeIndex,
        totalRanges: totalRanges ?? this.totalRanges,
        ipsPerSecond: ipsPerSecond ?? this.ipsPerSecond,
        currentRange: currentRange ?? this.currentRange,
        isRunning: isRunning ?? this.isRunning,
      );
}