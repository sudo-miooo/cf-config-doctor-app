import '../utils/constants.dart';

/// Holds all user-configurable scan parameters.
class ScanConfig {
  String domain;
  String uuid;
  String wsPath;
  int threads;
  int latencyLimitMs;
  int maxPerRange;
  List<String> ranges;

  ScanConfig({
    this.domain = 'speed.cloudflare.com',
    this.uuid = '',
    this.wsPath = '/ws',
    this.threads = 100,
    this.latencyLimitMs = 1000,
    this.maxPerRange = 10,
    List<String>? ranges,
  }) : ranges = ranges ?? List<String>.from(kDefaultRanges);
}