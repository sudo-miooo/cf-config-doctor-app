import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LogoWidget extends StatelessWidget {
  const LogoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo.svg',
      width: 240,
      height: 80,
    );
  }
}

class LogoWidgetWithoutText extends StatelessWidget {
  const LogoWidgetWithoutText({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/logo_no_text.svg',
      width: 240,
      height: 80,
    );
  }
}