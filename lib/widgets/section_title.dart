import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Small all-caps section label used throughout the app.
class SectionTitle extends StatelessWidget {
  final String text;
  final AppThemeColors c;

  const SectionTitle(this.text, this.c, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: c.textSecondary,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}