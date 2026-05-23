import 'package:flutter/material.dart';
import '../themes/colors.dart';

class RoomieLogo extends StatelessWidget {
  const RoomieLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: RoomieColors.primary,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: Text(
          'R',
          style: TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w600,
            color: RoomieColors.logoText,
          ),
        ),
      ),
    );
  }
}