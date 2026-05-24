import 'package:flutter/material.dart';
import '../themes/colors.dart';

class RoomieResendText extends StatelessWidget {
  final bool canResend;
  final int countdown;
  final VoidCallback onResend;

  const RoomieResendText({
    super.key,
    required this.canResend,
    required this.countdown,
    required this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: canResend ? onResend : null,
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 13,
            color: RoomieColors.primaryMid,
          ),
          children: [
            const TextSpan(text: "didn't get it? "),
            TextSpan(
              text: canResend
                  ? 'resend code'
                  : 'resend in ${countdown}s',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: canResend
                    ? RoomieColors.primary
                    : RoomieColors.primaryMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}