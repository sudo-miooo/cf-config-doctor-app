import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/found_ip.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

enum _SortField { ip, latency, range }

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  String _search = '';
  _SortField _sortField = _SortField.latency;
  bool _sortAsc = true;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([scanService, appSettings]),
      builder: (_, __) {
        final c = appSettings.colors;
        final all = scanService.foundIPs;

        // Filter
        var filtered = all
            .where((ip) =>
                _search.isEmpty ||
                ip.ip.contains(_search) ||
                ip.range.contains(_search))
            .toList();

        // Sort
        filtered.sort((a, b) {
          int cmp;
          switch (_sortField) {
            case _SortField.ip:
              cmp = a.ip.compareTo(b.ip);
            case _SortField.latency:
              cmp = a.latencyMs.compareTo(b.latencyMs);
            case _SortField.range:
              cmp = a.range.compareTo(b.range);
          }
          return _sortAsc ? cmp : -cmp;
        });

        return Column(children: [
          // ── Summary badges ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(children: [
              _Badge('${all.length}',
                  appSettings.tr('total'), c.accent1, c),
              const SizedBox(width: 8),
              _Badge(
                  '${all.where((ip) => ip.tier == LatencyTier.excellent).length}',
                  appSettings.tr('excellent'),
                  c.green,
                  c),
              const SizedBox(width: 8),
              _Badge(
                  '${all.where((ip) => ip.tier == LatencyTier.good).length}',
                  appSettings.tr('good'),
                  c.yellow,
                  c),
              const SizedBox(width: 8),
              _Badge(
                  '${all.where((ip) => ip.tier == LatencyTier.fair).length}',
                  appSettings.tr('fair'),
                  c.orange,
                  c),
            ]),
          ),
          // ── Search ─────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              style: TextStyle(color: c.textPrimary, fontSize: 13),
              onChanged: (v) => setState(() => _search = v),
              decoration: InputDecoration(
                hintText: appSettings.tr('searchIps'),
                hintStyle:
                    TextStyle(color: c.textSecondary, fontSize: 13),
                prefixIcon:
                    Icon(Icons.search, color: c.textSecondary, size: 18),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1))),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: c.accent1)),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ),
          // ── Column headers ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _ColHeader(
                  appSettings.tr('ipAddress'), _SortField.ip, this, c, 5),
              _ColHeader(
                  appSettings.tr('latency'), _SortField.latency, this, c, 3),
              _ColHeader(
                  appSettings.tr('range'), _SortField.range, this, c, 4),
              const SizedBox(width: 48),
            ]),
          ),
          // ── IP list ────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.wifi_off_rounded,
                            size: 48,
                            color: c.textSecondary.withOpacity(0.4)),
                        const SizedBox(height: 12),
                        Text(appSettings.tr('noIpsFound'),
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 14)),
                        Text(appSettings.tr('startScanHint'),
                            style: TextStyle(
                                color: c.textSecondary, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => _IPRow(ip: filtered[i]),
                  ),
          ),
        ]);
      },
    );
  }

  void onSortTap(_SortField field) {
    setState(() {
      if (_sortField == field) {
        _sortAsc = !_sortAsc;
      } else {
        _sortField = field;
        _sortAsc = true;
      }
    });
  }

  bool get sortAsc => _sortAsc;
  _SortField get sortField => _sortField;
}

// ─────────────────────────────────────────────────────────────
// LOCAL HELPER WIDGETS
// ─────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String n, label;
  final Color color;
  final c;

  const _Badge(this.n, this.label, this.color, this.c);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(children: [
          Text(n,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          Text(label,
              style: TextStyle(color: c.textSecondary, fontSize: 10)),
        ]),
      ),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;
  final _SortField field;
  final _ResultsScreenState state;
  final c;
  final int flex;

  const _ColHeader(this.label, this.field, this.state, this.c, this.flex);

  @override
  Widget build(BuildContext context) {
    final active = state.sortField == field;
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () => state.onSortTap(field),
        child: Row(children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? c.accent1 : c.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (active)
            Icon(
              state.sortAsc
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              size: 12,
              color: c.accent1,
            ),
        ]),
      ),
    );
  }
}

class _IPRow extends StatelessWidget {
  final FoundIP ip;

  const _IPRow({required this.ip});

  @override
  Widget build(BuildContext context) {
    final c = appSettings.colors;
    final color = ip.tier.colorFor(c);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: GlassCard(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(children: [
          Expanded(
            flex: 5,
            child: Text(
              ip.ip,
              style: TextStyle(
                  color: c.textPrimary,
                  fontSize: 12,
                  fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.35)),
              ),
              child: Text(
                '${ip.latencyMs}ms',
                style: TextStyle(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'monospace'),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              ip.range,
              style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 10,
                  fontFamily: 'monospace'),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 48,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: ip.ip));
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(appSettings.tr('ipCopied')),
                  duration: const Duration(seconds: 1),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: c.surface,
                ));
              },
              child: Icon(Icons.copy_rounded,
                  size: 14, color: c.textSecondary),
            ),
          ),
        ]),
      ),
    );
  }
}