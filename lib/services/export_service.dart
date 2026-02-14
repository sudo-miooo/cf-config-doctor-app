import 'dart:io';

/// Resolves the platform's Downloads folder and writes content to a file.
class ExportService {
  /// Returns the filename (with extension) for a given view index.
  static String getFileName(int view) {
    final ts = DateTime.now().millisecondsSinceEpoch;
    switch (view) {
      case 0:  return 'vless_$ts.txt';
      case 1:  return 'clash_$ts.yaml';
      case 2:  return 'ips_$ts.txt';
      default: return 'export_$ts.txt';
    }
  }

  /// Returns the platform-appropriate Downloads directory path.
  static Future<String> getDownloadsDir() async {
    if (Platform.isAndroid) {
      const androidDownloads = '/storage/emulated/0/Download';
      if (await Directory(androidDownloads).exists()) return androidDownloads;
      try {
        await Directory(androidDownloads).create(recursive: true);
        return androidDownloads;
      } catch (_) {}
      // Fallback: app-internal files dir (always writable)
      return '/data/data/com.example.app/files';
    }

    if (Platform.isWindows) {
      final home = Platform.environment['USERPROFILE'] ?? '.';
      final dl = '$home\\Downloads';
      if (await Directory(dl).exists()) return dl;
      return home;
    }

    // Linux / macOS
    final home = Platform.environment['HOME'] ?? '.';
    final dl = '$home/Downloads';
    if (await Directory(dl).exists()) return dl;
    return home;
  }

  /// Writes [content] to [fileName] in the Downloads folder.
  /// Returns the full path on success, or throws on failure.
  static Future<String> saveToDownloads(
    String content,
    String fileName,
  ) async {
    final dir = await getDownloadsDir();
    final filePath = '$dir${Platform.pathSeparator}$fileName';
    await File(filePath).writeAsString(content, flush: true);
    return filePath;
  }
}