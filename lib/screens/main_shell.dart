import 'package:flutter/material.dart';

import '../main.dart';
import '../theme/app_theme.dart';
import '../utils/extensions.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/pulse_dot.dart';
import '../widgets/widgets.dart';
import 'export_screen.dart';
import 'results_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _tab = 0;
  late final AnimationController _bgAnim;

  @override
  void initState() {
    super.initState();
    _bgAnim = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (_, __) {
        final c = appSettings.colors;
        return Scaffold(
          backgroundColor: c.bg,
          body: Stack(
            children: [
              AnimatedBackground(animation: _bgAnim),
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(c),
                    Expanded(
                      child: IndexedStack(
                        index: _tab,
                        children: const [
                          ScanScreen(),
                          ResultsScreen(),
                          ExportScreen(),
                          SettingsScreen(),
                        ],
                      ),
                    ),
                    _buildTabBar(c),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Top bar ────────────────────────────────────────────────

  Widget _buildTopBar(c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 200,
            height: 80,
            decoration: BoxDecoration(

              borderRadius: BorderRadius.circular(10),
            ),
            child: LogoWidget(),
          ),
          const SizedBox(width: 52),

          const Spacer(),
          ListenableBuilder(
            listenable: scanService,
            builder: (_, __) => scanService.stats.isRunning
                ? PulseDot(colors: c)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────

  Widget _buildTabBar(c) {
    final tabs = [
      (Icons.radar_rounded,            appSettings.tr('scan')),
      (Icons.list_alt_rounded,         appSettings.tr('results')),
      (Icons.file_download_rounded,    appSettings.tr('export')),
      (Icons.settings_rounded,         appSettings.tr('settings')),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: GlassCard(
        padding: const EdgeInsets.all(4),
        borderRadius: 28,
        child: Row(
          children: tabs.mapIndexed((i, t) {
            final active = i == _tab;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: active
                        ? LinearGradient(colors: [c.accent1, c.accent2])
                        : null,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        t.$1,
                        size: 16,
                        color: active ? Colors.white : c.textSecondary,
                      ),
                      if (active) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            t.$2,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}