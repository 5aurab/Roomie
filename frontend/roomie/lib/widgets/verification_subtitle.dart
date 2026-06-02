import 'package:flutter/material.dart';
import '../themes/colors.dart';

class VerificationSubtitle extends StatelessWidget {
  final String email;

  const VerificationSubtitle({
    super.key,
    required this.email,
  });

  String get _masked {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${name[0]}***@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w300,
          color: RColors.primaryMid,
          height: 1.6,
        ),
        children: [
          const TextSpan(text: 'we sent a 6-digit code to\n'),
          TextSpan(
            text: _masked,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: RColors.text,
            ),
          ),
        ],
      ),
    );
  }
}