import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';
import '../models/found_ip.dart';
import '../models/scan_config.dart';
import '../models/scan_stats.dart';
import '../theme/app_theme.dart';
import '../utils/constants.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_title.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  // Controllers
  TextEditingController? _domainCtrl, _uuidCtrl, _pathCtrl;
  TextEditingController? _threadsCtrl, _latencyCtrl, _maxPerRangeCtrl;
  final _customRangeCtrl = TextEditingController();

  // State
  List<String> _ranges = [];
  Set<String> _enabledRanges = {};
  bool _showVless = false;
  bool _showClash = false;
  SharedPreferences? _prefs;
  bool _loaded = false;

  // ── Lifecycle ──────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();

    _domainCtrl = TextEditingController(
        text: _prefs!.getString('cfg_domain') ?? 'speed.cloudflare.com');
    _uuidCtrl = TextEditingController(
        text: _prefs!.getString('cfg_uuid') ?? '');
    _pathCtrl = TextEditingController(
        text: _prefs!.getString('cfg_wsPath') ?? '/ws');
    _threadsCtrl = TextEditingController(
        text: '${_prefs!.getInt('cfg_threads') ?? 100}');
    _latencyCtrl = TextEditingController(
        text: '${_prefs!.getInt('cfg_latency') ?? 1000}');
    _maxPerRangeCtrl = TextEditingController(
        text: '${_prefs!.getInt('cfg_maxPerRange') ?? 10}');

    _ranges = _prefs!.getStringList('cfg_ranges') ??
        List<String>.from(kDefaultRanges);
    _enabledRanges = Set<String>.from(
        _prefs!.getStringList('cfg_enabledRanges') ?? _ranges);
    _showVless = _prefs!.getBool('cfg_showVless') ?? false;
    _showClash = _prefs!.getBool('cfg_showClash') ?? false;

    for (final c in [
      _domainCtrl!,
      _uuidCtrl!,
      _pathCtrl!,
      _threadsCtrl!,
      _latencyCtrl!,
      _maxPerRangeCtrl!,
    ]) {
      c.addListener(_saveConfig);
    }

    if (mounted) setState(() => _loaded = true);
  }

  void _saveConfig() {
    if (_prefs == null) return;
    _prefs!
      ..setString('cfg_domain', _domainCtrl!.text.trim())
      ..setString('cfg_uuid', _uuidCtrl!.text.trim())
      ..setString('cfg_wsPath', _pathCtrl!.text.trim())
      ..setInt('cfg_threads', int.tryParse(_threadsCtrl!.text) ?? 100)
      ..setInt('cfg_latency', int.tryParse(_latencyCtrl!.text) ?? 1000)
      ..setInt('cfg_maxPerRange', int.tryParse(_maxPerRangeCtrl!.text) ?? 10)
      ..setStringList('cfg_ranges', _ranges)
      ..setStringList('cfg_enabledRanges', _enabledRanges.toList())
      ..setBool('cfg_showVless', _showVless)
      ..setBool('cfg_showClash', _showClash);
  }

  void _syncConfig() {
    scanService.updateConfig(ScanConfig(
      domain: _domainCtrl!.text.trim(),
      uuid: _uuidCtrl!.text.trim(),
      wsPath: _pathCtrl!.text.trim(),
      threads: int.tryParse(_threadsCtrl!.text) ?? 100,
      latencyLimitMs: int.tryParse(_latencyCtrl!.text) ?? 1000,
      maxPerRange: int.tryParse(_maxPerRangeCtrl!.text) ?? 10,
      ranges: _enabledRanges.toList(),
    ));
    _saveConfig();
  }

  @override
  void dispose() {
    if (_loaded) {
      for (final c in [
        _domainCtrl!,
        _uuidCtrl!,
        _pathCtrl!,
        _threadsCtrl!,
        _latencyCtrl!,
        _maxPerRangeCtrl!,
      ]) {
        c.removeListener(_saveConfig);
        c.dispose();
      }
    }
    _customRangeCtrl.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Center(child: CircularProgressIndicator());
    }
    final c = appSettings.colors;

    return ListenableBuilder(
      listenable: scanService,
      builder: (_, __) {
        final stats = scanService.stats;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (stats.isRunning) _buildDashboard(stats, c),
            if (!stats.isRunning) ...[
              _buildConfig(c),
              const SizedBox(height: 12),
              _buildOutputOptions(c),
              const SizedBox(height: 12),
              _buildRanges(c),
              const SizedBox(height: 12),
            ],
            _buildActionButton(stats, c),
          ],
        );
      },
    );
  }

  // ── Dashboard (shown while scanning) ──────────────────────

  Widget _buildDashboard(ScanStats stats, c) {
    final progress = stats.currentRangeTotal > 0
        ? stats.currentRangeScanned / stats.currentRangeTotal
        : 0.0;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stat chips
          Row(children: [
            _StatChip(
              label: appSettings.tr('found'),
              value: '${stats.totalFound}',
              color: c.accent1,
              c: c,
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: appSettings.tr('scanned'),
              value: '${stats.totalScanned}',
              color: c.accent2,
              c: c,
            ),
            const SizedBox(width: 8),
            _StatChip(
              label: appSettings.tr('speed'),
              value: '${stats.ipsPerSecond.toStringAsFixed(1)}/s',
              color: c.green,
              c: c,
            ),
          ]),
          const SizedBox(height: 16),
          // Range info
          Text(
            '${appSettings.tr('range')} ${stats.currentRangeIndex + 1}/${stats.totalRanges}',
            style: TextStyle(color: c.textSecondary, fontSize: 12),
          ),
          if (stats.currentRange != null)
            Text(
              stats.currentRange!,
              style: TextStyle(
                color: c.textPrimary,
                fontSize: 13,
                fontFamily: 'monospace',
              ),
            ),
          const SizedBox(height: 10),
          // Progress bar
          Stack(children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 8,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.accent1, c.accent2]),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                        color: c.accent1.withOpacity(0.4), blurRadius: 6),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 6),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
              '${stats.currentRangeScanned}/${stats.currentRangeTotal}',
              style: TextStyle(color: c.textSecondary, fontSize: 11),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(1)}%',
              style: TextStyle(color: c.accent1, fontSize: 11),
            ),
          ]),
        ],
      ),
    );
  }

  // ── Configuration card ─────────────────────────────────────

  Widget _buildConfig(c) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(appSettings.tr('configuration'), c),
          const SizedBox(height: 12),
          _LabeledTextField(
              label: appSettings.tr('domainSni'), ctrl: _domainCtrl!, c: c),
          const SizedBox(height: 10),
          _LabeledTextField(
            label: appSettings.tr('uuidOptional'),
            ctrl: _uuidCtrl!,
            c: c,
            hint: appSettings.tr('uuidHint'),
          ),
          const SizedBox(height: 10),
          _LabeledTextField(
              label: appSettings.tr('wsPathOptional'), ctrl: _pathCtrl!, c: c),
          const SizedBox(height: 16),
          SectionTitle(appSettings.tr('tuning'), c),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _LabeledTextField(
                    label: appSettings.tr('threads'),
                    ctrl: _threadsCtrl!,
                    c: c,
                    kb: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(
                child: _LabeledTextField(
                    label: appSettings.tr('latencyMs'),
                    ctrl: _latencyCtrl!,
                    c: c,
                    kb: TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(
                child: _LabeledTextField(
                    label: appSettings.tr('maxRange'),
                    ctrl: _maxPerRangeCtrl!,
                    c: c,
                    kb: TextInputType.number)),
          ]),
        ],
      ),
    );
  }

  // ── Output format toggles ──────────────────────────────────

  Widget _buildOutputOptions(c) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(appSettings.tr('outputFormats'), c),
          const SizedBox(height: 12),
          _ToggleRow(
            icon: Icons.link_rounded,
            label: appSettings.tr('vlessLinks'),
            subtitle: appSettings.tr('requiresUuid'),
            value: _showVless,
            color: c.accent1,
            c: c,
            onChanged: (v) {
              setState(() => _showVless = v);
              _saveConfig();
            },
          ),
          Divider(color: c.divider, height: 20),
          _ToggleRow(
            icon: Icons.settings_ethernet_rounded,
            label: appSettings.tr('clashConfig'),
            subtitle: appSettings.tr('fullYaml'),
            value: _showClash,
            color: c.accent2,
            c: c,
            onChanged: (v) {
              setState(() => _showClash = v);
              _saveConfig();
            },
          ),
        ],
      ),
    );
  }

  // ── IP Ranges ──────────────────────────────────────────────

  Widget _buildRanges(c) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: SectionTitle(appSettings.tr('ipRanges'), c)),
            TextButton(
              onPressed: () {
                setState(() => _enabledRanges = Set.from(_ranges));
                _saveConfig();
              },
              child: Text(appSettings.tr('all'),
                  style: TextStyle(color: c.accent1, fontSize: 12)),
            ),
            TextButton(
              onPressed: () {
                setState(() => _enabledRanges.clear());
                _saveConfig();
              },
              child: Text(appSettings.tr('none'),
                  style: TextStyle(color: c.textSecondary, fontSize: 12)),
            ),
          ]),
          const SizedBox(height: 8),
          ..._ranges.map((r) {
            final on = _enabledRanges.contains(r);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (on) {
                    _enabledRanges.remove(r);
                  } else {
                    _enabledRanges.add(r);
                  }
                });
                _saveConfig();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: on ? c.accent1 : Colors.transparent,
                      border: Border.all(
                          color: on
                              ? c.accent1
                              : c.textSecondary.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: on
                        ? const Icon(Icons.check, size: 12, color: Colors.black)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    r,
                    style: TextStyle(
                      color: on ? c.textPrimary : c.textSecondary,
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ]),
              ),
            );
          }),
          const SizedBox(height: 12),
          // Add custom range
          Row(children: [
            Expanded(
              child: TextField(
                controller: _customRangeCtrl,
                style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 13,
                    fontFamily: 'monospace'),
                decoration: _inputDecoration('1.2.3.0/24', c),
              ),
            ),
            const SizedBox(width: 8),
            GradientButton(
              label: appSettings.tr('add'),
              icon: Icons.add_rounded,
              colors: [c.accent1, c.accent2],
              mini: true,
              onTap: () {
                final r = _customRangeCtrl.text.trim();
                if (r.isEmpty) return;
                if (!RegExp(r'^\d+\.\d+\.\d+\.\d+/\d+$').hasMatch(r)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(appSettings.tr('invalidCidr'))));
                  return;
                }
                setState(() {
                  _ranges.add(r);
                  _enabledRanges.add(r);
                });
                _customRangeCtrl.clear();
                _saveConfig();
              },
            ),
          ]),
        ],
      ),
    );
  }

  // ── Start / Stop button ────────────────────────────────────

  Widget _buildActionButton(ScanStats stats, c) {
    if (stats.isRunning) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: GradientButton(
          label: appSettings.tr('stopScan'),
          icon: Icons.stop_rounded,
          colors: [c.orange, const Color(0xFFDC2626)],
          onTap: scanService.stop,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: GradientButton(
        label: appSettings.tr('startScan'),
        icon: Icons.play_arrow_rounded,
        colors: [c.accent1, c.accent2],
        onTap: () {
          _syncConfig();
          scanService.startScan();
        },
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────

  InputDecoration _inputDecoration(String hint, c) => InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: c.textSecondary, fontSize: 13),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.1))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide:
                BorderSide(color: Colors.white.withOpacity(0.1))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: c.accent1)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );
}

// ─────────────────────────────────────────────────────────────
// LOCAL HELPER WIDGETS
// ─────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final c;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.c,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label,
              style: TextStyle(color: c.textSecondary, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final c;
  final String? hint;
  final TextInputType? kb;

  const _LabeledTextField({
    required this.label,
    required this.ctrl,
    required this.c,
    this.hint,
    this.kb,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(color: c.textSecondary, fontSize: 11)),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          keyboardType: kb,
          style: TextStyle(
              color: c.textPrimary, fontSize: 13, fontFamily: 'monospace'),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: c.textSecondary, fontSize: 12),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1))),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Colors.white.withOpacity(0.1))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: c.accent1)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label, subtitle;
  final bool value;
  final Color color;
  final c;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.color,
    required this.c,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
            Text(subtitle,
                style: TextStyle(color: c.textSecondary, fontSize: 11)),
          ],
        ),
      ),
      Switch(
          value: value,
          onChanged: onChanged,
          activeColor: color,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap),
    ]);
  }
}