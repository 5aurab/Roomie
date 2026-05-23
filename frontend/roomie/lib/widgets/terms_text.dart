import 'package:flutter/material.dart';
import 'colors.dart';

class RoomieTermsText extends StatelessWidget {
  const RoomieTermsText({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      'by continuing you agree to our terms & privacy policy',
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 10, color: RoomieColors.primaryMid),
    );
  }
}