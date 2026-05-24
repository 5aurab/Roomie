import 'package:flutter/material.dart';
import '../themes/colors.dart';

// ── Field label ───────────────────────────────────────────────────────────────

class RoomieFieldLabel extends StatelessWidget {
  final String text;
  const RoomieFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: RoomieColors.primarySoft,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}

// ── Input decoration helper ───────────────────────────────────────────────────
// Use as a static method so any screen can call RoomieInputDecoration.of(hint).

class RoomieInputDecoration {
  static InputDecoration of(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: RoomieColors.hint),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: RoomieColors.border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: RoomieColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: RoomieColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: RoomieColors.error, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11, color: RoomieColors.errorText),
    );
  }
}