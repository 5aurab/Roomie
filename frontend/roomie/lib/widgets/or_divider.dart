import 'package:flutter/material.dart';
import '../themes/colors.dart';

class OrDivider extends StatelessWidget {
  const OrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(color: RColors.border, thickness: 0.5),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'or continue with',
            style: TextStyle(fontSize: 11, color: RColors.orText),
          ),
        ),
        Expanded(
          child: Divider(color: RColors.border, thickness: 0.5),
        ),
      ],
    );
  }
}