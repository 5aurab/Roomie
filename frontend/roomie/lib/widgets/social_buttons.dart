import 'package:flutter/material.dart';
import '../themes/colors.dart';

class RoomieSocialButtons extends StatelessWidget {
  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;

  const RoomieSocialButtons({
    super.key,
    required this.onGoogleTap,
    required this.onAppleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            label: 'Google',
            icon: Icons.g_mobiledata_rounded,
            onTap: onGoogleTap,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SocialButton(
            label: 'Apple',
            icon: Icons.apple,
            onTap: onAppleTap,
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: RoomieColors.border, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: RoomieColors.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: RoomieColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}