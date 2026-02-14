import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/l10n.dart';
import 'app_theme.dart';

export '../l10n/l10n.dart';
export 'app_theme.dart';

class AppSettings extends ChangeNotifier {
  final SharedPreferences _prefs;

  late AppLanguage _language;
  late AppThemeType _themeType;
  late AppThemeColors _colors;

  AppSettings(this._prefs) {
    final langCode = _prefs.getString('language') ?? 'en';
    _language = AppLanguage.values.firstWhere(
          (l) => l.code == langCode,
      orElse: () => AppLanguage.english,
    );
    final themeIdx = _prefs.getInt('theme') ?? 0;
    _themeType = AppThemeType.values[themeIdx.clamp(0, AppThemeType.values.length - 1)];
    _colors = AppThemeColors.fromType(_themeType);
  }

  AppLanguage get language => _language;
  AppThemeType get themeType => _themeType;
  AppThemeColors get colors => _colors;
  String tr(String key) => L10n.tr(key, _language);

  set language(AppLanguage lang) {
    _language = lang;
    _prefs.setString('language', lang.code);
    notifyListeners();
  }

  set themeType(AppThemeType type) {
    _themeType = type;
    _colors = AppThemeColors.fromType(type);
    _prefs.setInt('theme', type.index);
    notifyListeners();
  }
}