import 'package:flutter/material.dart';
import '../themes/colors.dart';

class RoomieErrorBanner extends StatelessWidget {
  final String message;
  const RoomieErrorBanner({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: RoomieColors.error.withValues(alpha: 0.08),
        border: Border.all(color: RoomieColors.error.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 14, color: RoomieColors.errorText),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12, color: RoomieColors.errorText),
            ),
          ),
        ],
      ),
    );
  }
}