import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../main.dart';
import '../models/found_ip.dart';
import '../services/export_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/gradient_button.dart';
import '../widgets/section_title.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  int _view = 0;
  final _importCtrl = TextEditingController();

  @override
  void dispose() {
    _importCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────

  String _getContent() {
    switch (_view) {
      case 0:  return scanService.buildVlessLinks();
      case 1:  return scanService.buildClashYaml();
      case 2:  return scanService.buildPlainList();
      default: return '';
    }
  }

  Future<void> _saveFile(BuildContext context) async {
    final content = _getContent();
    final c = appSettings.colors;

    // Nothing to save yet


    try {
      final fileName = ExportService.getFileName(_view);
      final filePath = await ExportService.saveToDownloads(content, fileName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [
            Icon(Icons.check_circle_rounded, color: c.green, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${appSettings.tr('downloadedTo')}\n$filePath',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ]),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
        ));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${appSettings.tr('saveFailed')}: $e'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
        ));
      }
    }
  }

  // ── Build ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = appSettings.colors;
    return ListenableBuilder(
      listenable: Listenable.merge([scanService, appSettings]),
      builder: (_, __) {
        final content = _getContent();
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── View switcher ──────────────────────────────
            GlassCard(
              padding: const EdgeInsets.all(4),
              borderRadius: 14,
              child: Row(children: [
                _ViewButton(0, Icons.link_rounded, 'VLESS', _view, c,
                    () => setState(() => _view = 0)),
                _ViewButton(1, Icons.settings_ethernet_rounded, 'Clash',
                    _view, c, () => setState(() => _view = 1)),
                _ViewButton(
                    2,
                    Icons.format_list_bulleted_rounded,
                    appSettings.tr('plain'),
                    _view,
                    c,
                    () => setState(() => _view = 2)),
              ]),
            ),
            const SizedBox(height: 12),
            // ── Preview card ───────────────────────────────
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                        child:
                            SectionTitle(appSettings.tr('preview'), c)),
                    // Copy
                    _IconBtn(
                      icon: Icons.copy_rounded,
                      tooltip: appSettings.tr('copiedClipboard'),
                      c: c,
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: content));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text(appSettings.tr('copiedClipboard')),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ));
                      },
                    ),
                    const SizedBox(width: 6),
                    // Download (header icon)
                    _IconBtn(
                      icon: Icons.download_rounded,
                      tooltip: appSettings.tr('download'),
                      accentColor: c.accent1,
                      c: c,
                      onTap: () => _saveFile(context),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  // Text preview
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 320),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.08)),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        content,
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 11,
                            fontFamily: 'monospace',
                            height: 1.6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Full-width download bar
                  _DownloadBar(
                    view: _view,
                    onTap: () => _saveFile(context),
                    colors: c,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Import card ────────────────────────────────
            GlassCard(
              borderColor: c.accent2.withOpacity(0.3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(appSettings.tr('importIps'), c),
                  const SizedBox(height: 8),
                  Text(
                    appSettings.tr('importHint'),
                    style:
                        TextStyle(color: c.textSecondary, fontSize: 11),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _importCtrl,
                    maxLines: 6,
                    style: TextStyle(
                        color: c.textPrimary,
                        fontSize: 12,
                        fontFamily: 'monospace'),
                    decoration: InputDecoration(
                      hintText: '1.2.3.4\n5.6.7.8\t150ms\t104.16.0.0/13',
                      hintStyle: TextStyle(
                          color: c.textSecondary, fontSize: 11),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.04),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                              color: Colors.white.withOpacity(0.1))),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: c.accent2)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                      child: GradientButton(
                        label: appSettings.tr('import'),
                        icon: Icons.download_rounded,
                        colors: [c.accent1, c.accent2],
                        onTap: () => _handleImport(context),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GradientButton(
                        label: appSettings.tr('clearAll'),
                        icon: Icons.delete_outline_rounded,
                        colors: [
                          c.orange.withOpacity(0.7),
                          const Color(0xFFDC2626).withOpacity(0.7),
                        ],
                        onTap: scanService.clearResults,
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Import logic ───────────────────────────────────────────

  void _handleImport(BuildContext context) {
    final text = _importCtrl.text.trim();
    if (text.isEmpty) return;

    final ips = <FoundIP>[];
    for (final line in text.split('\n')) {
      final l = line.trim();
      if (l.isEmpty) continue;
      final parts = l.split('\t');
      final ip = parts[0].trim();
      if (!RegExp(r'^\d+\.\d+\.\d+\.\d+$').hasMatch(ip)) continue;
      int lat = 0;
      if (parts.length > 1) {
        lat = int.tryParse(parts[1].trim().replaceAll('ms', '')) ?? 0;
      }
      ips.add(FoundIP(
        ip: ip,
        latencyMs: lat,
        range: parts.length > 2 ? parts[2].trim() : 'imported',
        foundAt: DateTime.now(),
      ));
    }

    if (ips.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(appSettings.tr('noValidIps'))));
      return;
    }

    scanService.importIPs(ips);
    _importCtrl.clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              '${appSettings.tr('imported')} ${ips.length} ${appSettings.tr('ips')}')));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// LOCAL HELPER WIDGETS
// ─────────────────────────────────────────────────────────────

class _ViewButton extends StatelessWidget {
  final int index, activeIndex;
  final IconData icon;
  final String label;
  final c;
  final VoidCallback onTap;

  const _ViewButton(this.index, this.icon, this.label, this.activeIndex, this.c,
      this.onTap);

  @override
  Widget build(BuildContext context) {
    final active = index == activeIndex;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: active
                ? LinearGradient(colors: [c.accent1, c.accent2])
                : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                size: 15,
                color: active ? Colors.white : c.textSecondary),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : c.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final c;
  final Color? accentColor;
  final String? tooltip;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    required this.c,
    this.accentColor,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final bg = accentColor != null
        ? accentColor!.withOpacity(0.12)
        : Colors.white.withOpacity(0.06);
    final iconColor = accentColor ?? c.textSecondary;

    final btn = GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: accentColor != null
              ? Border.all(color: accentColor!.withOpacity(0.35))
              : null,
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
    );

    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

class _DownloadBar extends StatelessWidget {
  final int view;
  final VoidCallback onTap;
  final colors;

  const _DownloadBar({
    required this.view,
    required this.onTap,
    required this.colors,
  });

  String get _label {
    switch (view) {
      case 0:  return 'vless_config.txt';
      case 1:  return 'clash_config.yaml';
      case 2:  return 'ip_list.txt';
      default: return 'export.txt';
    }
  }

  IconData get _icon {
    switch (view) {
      case 0:  return Icons.link_rounded;
      case 1:  return Icons.settings_ethernet_rounded;
      default: return Icons.format_list_bulleted_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = colors;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            c.accent1.withOpacity(0.15),
            c.accent2.withOpacity(0.10),
          ]),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.accent1.withOpacity(0.30)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.download_rounded, size: 16, color: c.accent1),
            const SizedBox(width: 8),
            Text(
              '${appSettings.tr('download')}  ',
              style: TextStyle(
                  color: c.accent1,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
            Icon(_icon, size: 13, color: c.textSecondary),
            const SizedBox(width: 4),
            Text(
              _label,
              style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 12,
                  fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}