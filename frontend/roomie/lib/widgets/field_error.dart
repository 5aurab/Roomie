import 'package:flutter/material.dart';
import '../themes/colors.dart';

class RoomieFieldError extends StatelessWidget {
  final String message;
  const RoomieFieldError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: const TextStyle(fontSize: 11, color: RoomieColors.errorText),
      ),
    );
  }
}