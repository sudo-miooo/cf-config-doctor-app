import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../models/found_ip.dart';
import '../models/scan_config.dart';
import '../models/scan_stats.dart';
import '../utils/extensions.dart';
import 'cidr_range.dart';

class _ProbeResult {
  final String ip;
  final int latencyMs;
  final bool success;
  _ProbeResult({required this.ip, required this.latencyMs, required this.success});
}

class _FutureResult {
  final Future<_ProbeResult> future;
  final _ProbeResult result;
  _FutureResult({required this.future, required this.result});
}

class ScanService extends ChangeNotifier {
  ScanStats stats = const ScanStats();
  List<FoundIP> foundIPs = [];
  ScanConfig config = ScanConfig();
  bool _stopRequested = false;
  DateTime? _scanStart;

  void updateConfig(ScanConfig c) {
    config = c;
    notifyListeners();
  }

  Future<void> startScan() async {
    if (stats.isRunning) return;
    _stopRequested = false;
    foundIPs = [];
    _scanStart = DateTime.now();
    final ranges = config.ranges.map(CidrRange.new).toList();
    stats = ScanStats(isRunning: true, totalRanges: ranges.length);
    notifyListeners();
    final rng = math.Random();
    int totalScanned = 0;
    int totalFound = 0;

    for (int ri = 0; ri < ranges.length; ri++) {
      if (_stopRequested) break;
      final range = ranges[ri];
      final cidrStr = config.ranges[ri];
      final ips = range.randomIPs(math.min(2000, range.count), rng);
      int rangeFound = 0;
      int rangeScanned = 0;
      stats = stats.copyWith(currentRange: cidrStr, currentRangeIndex: ri, currentRangeTotal: ips.length, currentRangeScanned: 0);
      notifyListeners();
      int cursor = 0;
      final active = <Future<_ProbeResult>>[];
      final maxConcurrent = math.min(config.threads, 50);
      while (cursor < ips.length && active.length < maxConcurrent && rangeFound < config.maxPerRange) {
        active.add(_probe(ips[cursor++]));
      }
      while (active.isNotEmpty && !_stopRequested) {
        final result = await Future.any(active.map((f) async {
          final r = await f;
          return _FutureResult(future: f, result: r);
        }));
        active.remove(result.future);
        rangeScanned++;
        totalScanned++;
        final elapsed = DateTime.now().difference(_scanStart!).inSeconds;
        final scanRate = totalScanned / math.max(1, elapsed);
        if (result.result.success) {
          rangeFound++;
          totalFound++;
          foundIPs.add(FoundIP(ip: result.result.ip, latencyMs: result.result.latencyMs, range: cidrStr, foundAt: DateTime.now()));
        }
        stats = stats.copyWith(totalFound: totalFound, totalScanned: totalScanned, currentRangeScanned: rangeScanned, ipsPerSecond: scanRate);
        notifyListeners();
        if (cursor < ips.length && rangeFound < config.maxPerRange && !_stopRequested) {
          active.add(_probe(ips[cursor++]));
        }
      }
      if (_stopRequested) break;
    }
    stats = stats.copyWith(isRunning: false);
    notifyListeners();
  }

  void stop() => _stopRequested = true;

  void importIPs(List<FoundIP> ips) {
    foundIPs = [...foundIPs, ...ips];
    stats = stats.copyWith(totalFound: foundIPs.length);
    notifyListeners();
  }

  void clearResults() {
    foundIPs = [];
    stats = const ScanStats();
    notifyListeners();
  }

  String buildVlessLinks() {
    if (foundIPs.isEmpty) return '# No IPs found yet.';
    if (config.uuid.isEmpty && config.wsPath.isEmpty) return foundIPs.map((ip) => ip.ip).join('\n');
    return foundIPs.map((ip) {
      final uuid = config.uuid.isNotEmpty ? config.uuid : '00000000-0000-0000-0000-000000000000';
      final path = config.wsPath.isNotEmpty ? config.wsPath : '/ws';
      return 'vless://$uuid@${ip.ip}:443?encryption=none&security=tls&sni=${config.domain}&type=ws&host=${config.domain}&path=${Uri.encodeComponent(path)}#CF-${ip.ip}-${ip.latencyMs}ms';
    }).join('\n');
  }

  String buildClashYaml() {
    if (foundIPs.isEmpty) return '# No IPs found yet.';
    final uuid = config.uuid.isNotEmpty ? config.uuid : '00000000-0000-0000-0000-000000000000';
    final path = config.wsPath.isNotEmpty ? config.wsPath : '/ws';
    final proxies = foundIPs.mapIndexed((i, ip) => '  - name: CF-${ip.ip}\n    type: vless\n    server: ${ip.ip}\n    port: 443\n    uuid: $uuid\n    tls: true\n    skip-cert-verify: true\n    servername: ${config.domain}\n    network: ws\n    ws-opts:\n      path: $path\n      headers:\n        Host: ${config.domain}').join('\n');
    final names = foundIPs.map((ip) => '    - CF-${ip.ip}').join('\n');
    return 'mixed-port: 7890\nallow-lan: false\nmode: rule\nlog-level: info\nproxies:\n$proxies\n\nproxy-groups:\n  - name: Auto\n    type: url-test\n    url: http://www.gstatic.com/generate_204\n    interval: 300\n    proxies:\n$names\n\n  - name: Select\n    type: select\n    proxies:\n      - Auto\n$names\n\nrules:\n  - MATCH,Select\n';
  }

  String buildPlainList() {
    if (foundIPs.isEmpty) return '# No IPs found yet.';
    return foundIPs.map((ip) => '${ip.ip}\t${ip.latencyMs}ms\t${ip.range}').join('\n');
  }

  Future<_ProbeResult> _probe(String ip) async {
    final sw = Stopwatch()..start();
    try {
      final client = HttpClient()
        ..connectionTimeout = Duration(milliseconds: config.latencyLimitMs)
        ..badCertificateCallback = (_, __, ___) => true;
      final request = await client.headUrl(Uri.parse('https://$ip/')).timeout(Duration(milliseconds: config.latencyLimitMs));
      request.headers.set('Host', config.domain);
      final response = await request.close().timeout(Duration(milliseconds: config.latencyLimitMs));
      await response.drain<void>();
      client.close(force: true);
      sw.stop();
      final ms = sw.elapsedMilliseconds;
      if (ms <= config.latencyLimitMs) return _ProbeResult(ip: ip, latencyMs: ms, success: true);
    } catch (_) {}
    sw.stop();
    return _ProbeResult(ip: ip, latencyMs: sw.elapsedMilliseconds, success: false);
  }
}