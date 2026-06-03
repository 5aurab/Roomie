import 'package:flutter/material.dart';
import '../themes/colors.dart';
import 'logo_mark.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Logo(),
        SizedBox(height: 12),
        Text(
          'ROOMIE',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w600,
            color: RColors.text,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'chores, bills, groceries —\nsplit everything, stress nothing',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            color: RColors.primaryMid,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}