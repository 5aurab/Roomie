import 'package:flutter/material.dart';
import '../themes/colors.dart';

class FieldError extends StatelessWidget {
  final String message;
  const FieldError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        message,
        style: const TextStyle(fontSize: 11, color: RColors.errorText),
      ),
    );
  }
}