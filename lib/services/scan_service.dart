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
    final proxies = foundIPs.mapIndexed((i, ip) => '''
  - name: CF-${ip.ip}
    packet-encoding: ''
    udp: false
    tfo: false
    client-fingerprint: chrome
    type: vless
    alpn:
      - http/1.1
    server: ${ip.ip}
    port: 443
    uuid: $uuid
    tls: true
    skip-cert-verify: false
    servername: ${config.domain}
    network: ws
    ws-opts:
      max-early-data: 2560
      early-data-header-name: Sec-WebSocket-Protocol
      path: $path
      headers:
        Host: ${config.domain}
''').join('\n');
    final names = foundIPs
        .map((ip) => '      - CF-${ip.ip}')
        .join('\n');

    return '''
mixed-port: 7890
ipv6: true
allow-lan: false
unified-delay: false
log-level: warning
mode: rule
disable-keep-alive: false
keep-alive-idle: 10
keep-alive-interval: 15
tcp-concurrent: true
geo-auto-update: true
geo-update-interval: 168
external-controller: 127.0.0.1:9090
external-controller-cors:
  allow-origins:
    - '*'
  allow-private-network: true
external-ui: ui
external-ui-url: 'https://github.com/MetaCubeX/metacubexd/archive/refs/heads/gh-pages.zip'
profile:
  store-selected: true
  store-fake-ip: true
dns:
  enable: true
  respect-rules: true
  use-system-hosts: false
  listen: 127.0.0.1:1053
  ipv6: true
  nameserver:
    - 'https://8.8.8.8/dns-query#✅ Selector'
  proxy-server-nameserver:
    - '8.8.8.8#DIRECT'
  direct-nameserver:
    - '8.8.8.8#DIRECT'
  direct-nameserver-follow-policy: true
  nameserver-policy:
    'rule-set:ir': '8.8.8.8#DIRECT'
  enhanced-mode: redir-host
tun:
  enable: true
  stack: mixed
  auto-route: true
  strict-route: true
  auto-detect-interface: true
  dns-hijack:
    - any:53
    - tcp://any:53
  mtu: 9000
sniffer:
  enable: true
  force-dns-mapping: true
  parse-pure-ip: true
  override-destination: true
  sniff:
    HTTP:
      ports: [80, 8080, 8880, 2052, 2082, 2086, 2095]
    TLS:
      ports: [443, 8443, 2053, 2083, 2087, 2096]
proxies:
$proxies

proxy-groups:
  - name: Auto
    type: url-test
    url: http://www.gstatic.com/generate_204
    interval: 300
    proxies:
$names

  - name: Select
    type: select
    proxies:
      - Auto
$names
rule-providers:
  ir:
    type: http
    format: text
    behavior: domain
    path: './ruleset/ir.txt'
    interval: 86400
    url: 'https://raw.githubusercontent.com/Chocolate4U/Iran-clash-rules/release/ir.txt'
  ir-cidr:
    type: http
    format: text
    behavior: ipcidr
    path: './ruleset/ir-cidr.txt'
    interval: 86400
    url: 'https://raw.githubusercontent.com/Chocolate4U/Iran-clash-rules/release/ircidr.txt'
rules:
  - GEOIP,lan,DIRECT,no-resolve
  - NETWORK,udp,REJECT
  - RULE-SET,ir,DIRECT
  - RULE-SET,ir-cidr,DIRECT
  - MATCH,Select
ntp:
  enable: true
  server: time.cloudflare.com
  port: 123
  interval: 30

''';}


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