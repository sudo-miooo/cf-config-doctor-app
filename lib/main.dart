import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'services/scan_service.dart';
import 'theme/app_settings.dart';

late ScanService scanService;
late AppSettings appSettings;

// Global key — lets ANY widget show a SnackBar without needing a Scaffold context
final scaffoldKey = GlobalKey<ScaffoldMessengerState>();

void showSnack(String message, {Color? color, int seconds = 2}) {
  scaffoldKey.currentState
    ?..removeCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: color ?? appSettings.colors.surface,
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: seconds),
    ));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(CFScannerApp(prefs: prefs));
}