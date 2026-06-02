import 'package:flutter/material.dart';
import '../themes/colors.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: RColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: Text(
          'R',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            color: RColors.logoText,
          ),
        ),
      ),
    );
  }
}