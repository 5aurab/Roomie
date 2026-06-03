import 'package:flutter/material.dart';
import '../themes/colors.dart';

class TermsText extends StatelessWidget {
  const TermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'by continuing you agree to our terms & privacy policy',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 10, color: RColors.primaryMid),
    );
  }
}