import 'dart:math' as math;

/// Parses a CIDR string (e.g. `104.16.0.0/13`) and generates random IPs within
/// the range.
class CidrRange {
  final String cidr;

  late final int _base;
  late final int _count;

  CidrRange(this.cidr) {
    final parts = cidr.split('/');
    final prefix = int.parse(parts[1]);
    _base = _ipToInt(parts[0]);
    _count = math.pow(2, 32 - prefix).toInt();
  }

  int get count => _count;

  /// Returns up to [n] unique random IPs from this range.
  List<String> randomIPs(int n, math.Random rng) {
    final cnt = math.min(n, _count);
    final chosen = <int>{};
    while (chosen.length < cnt) {
      chosen.add(_base + rng.nextInt(_count));
    }
    return chosen.map(_intToIp).toList()..shuffle(rng);
  }

  // ── Helpers ────────────────────────────────────────────────

  static int _ipToInt(String ip) {
    final p = ip.split('.').map(int.parse).toList();
    return (p[0] << 24) | (p[1] << 16) | (p[2] << 8) | p[3];
  }

  static String _intToIp(int n) =>
      '${(n >> 24) & 0xFF}.'
      '${(n >> 16) & 0xFF}.'
      '${(n >> 8)  & 0xFF}.'
      '${n         & 0xFF}';
}