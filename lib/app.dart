import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'widgets/widgets.dart';
import 'models/scan_config.dart';
import 'screens/main_shell.dart';
import 'services/scan_service.dart';
import 'theme/app_settings.dart';
import 'theme/app_theme.dart';
const List<String> kDefaultRanges = [
  '103.21.244.0/22', '103.22.200.0/22', '103.31.4.0/22',
  '104.16.0.0/13', '104.24.0.0/14', '108.162.192.0/18',
  '131.0.72.0/22', '141.101.64.0/18', '162.158.0.0/15',
  '172.64.0.0/13', '173.245.48.0/20', '188.114.96.0/20',
  '190.93.240.0/20', '197.234.240.0/22', '198.41.128.0/17',
];
class CFScannerApp extends StatefulWidget {
  final SharedPreferences prefs;
  const CFScannerApp({super.key, required this.prefs});

  @override
  State<CFScannerApp> createState() => _CFScannerAppState();
}

class _CFScannerAppState extends State<CFScannerApp> {
  @override
  void initState() {
    super.initState();
    scanService = ScanService();
    appSettings = AppSettings(widget.prefs);
    scanService.updateConfig(ScanConfig(
      domain: widget.prefs.getString('cfg_domain') ?? 'speed.cloudflare.com',
      uuid: widget.prefs.getString('cfg_uuid') ?? '',
      wsPath: widget.prefs.getString('cfg_wsPath') ?? '/ws',
      threads: widget.prefs.getInt('cfg_threads') ?? 100,
      latencyLimitMs: widget.prefs.getInt('cfg_latency') ?? 1000,
      maxPerRange: widget.prefs.getInt('cfg_maxPerRange') ?? 10,
      ranges: widget.prefs.getStringList('cfg_ranges') ??
          List<String>.from(kDefaultRanges),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([scanService, appSettings]),
      builder: (ctx, _) {
        final colors = appSettings.colors;
        return Directionality(
          textDirection: appSettings.language.isRtl
              ? TextDirection.rtl
              : TextDirection.ltr,
          child: MaterialApp(
            title: 'Cf Config Doctor',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: scaffoldKey,
            theme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: colors.bg,
              fontFamily: 'monospace',
              colorScheme: ColorScheme.dark(
                primary: colors.accent1,
                secondary: colors.accent2,
                surface: colors.surface,
              ),
            ),
            home: const MainShell(),
          ),
        );
      },
    );
  }
}