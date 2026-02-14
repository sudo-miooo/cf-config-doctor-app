import 'package:flutter/material.dart';

import '../main.dart';
import '../l10n/l10n.dart';
import '../theme/app_settings.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/section_title.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appSettings,
      builder: (_, __) {
        final c = appSettings.colors;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Language picker ────────────────────────────
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(appSettings.tr('language'), c),
                  const SizedBox(height: 12),
                  ...AppLanguage.values.map((lang) {
                    final active = appSettings.language == lang;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: GestureDetector(
                        onTap: () => appSettings.language = lang,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: active
                                ? c.accent1.withOpacity(0.12)
                                : Colors.white.withOpacity(0.03),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active
                                  ? c.accent1.withOpacity(0.4)
                                  : Colors.white.withOpacity(0.06),
                            ),
                          ),
                          child: Row(children: [
                            Icon(
                              active
                                  ? Icons.check_circle_rounded
                                  : Icons.circle_outlined,
                              size: 18,
                              color:
                                  active ? c.accent1 : c.textSecondary,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              lang.displayName,
                              style: TextStyle(
                                color: active
                                    ? c.textPrimary
                                    : c.textSecondary,
                                fontSize: 14,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                          ]),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Theme picker ───────────────────────────────
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(appSettings.tr('theme'), c),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppThemeType.values.map((theme) {
                      final active = appSettings.themeType == theme;
                      final tc = AppThemeColors.fromType(theme);
                      return GestureDetector(
                        onTap: () => appSettings.themeType = theme,
                        child: Container(
                          width:
                              (MediaQuery.of(context).size.width - 64) / 2,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tc.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active
                                  ? tc.accent1
                                  : Colors.white.withOpacity(0.08),
                              width: active ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Colour swatches
                              Row(children: [
                                for (final col in [
                                  tc.accent1,
                                  tc.accent2,
                                  tc.green,
                                  tc.bg,
                                ])
                                  Container(
                                    width: 14,
                                    height: 14,
                                    margin:
                                        const EdgeInsets.only(right: 4),
                                    decoration: BoxDecoration(
                                      color: col,
                                      shape: BoxShape.circle,
                                      border: col == tc.bg
                                          ? Border.all(
                                              color: Colors.white24)
                                          : null,
                                    ),
                                  ),
                              ]),
                              const SizedBox(height: 8),
                              Text(
                                theme.displayName,
                                style: TextStyle(
                                    color: tc.textPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}