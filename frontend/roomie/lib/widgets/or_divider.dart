import 'package:flutter/material.dart';
import 'colors.dart';

class RoomieOrDivider extends StatelessWidget {
  const RoomieOrDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(color: RoomieColors.border, thickness: 0.5),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            'or continue with',
            style: TextStyle(fontSize: 11, color: RoomieColors.orText),
          ),
        ),
        Expanded(
          child: Divider(color: RoomieColors.border, thickness: 0.5),
        ),
      ],
    );
  }
}