import 'package:flutter/material.dart';
import '../themes/colors.dart';
import '../widgets/logo_mark.dart';
import 'create_home.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(),

              const Logo(),
              const SizedBox(height: 14),
              const Text(
                'roomie',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: RColors.text,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Let\'s get your home set up',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: RColors.primaryMid,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              _SetupButton(
                icon: Icons.home_outlined,
                label: 'create a home',
                sublabel: 'start fresh and invite your roommates',
                filled: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => CreateHomeScreen()),
                  );
                },
              ),
              const SizedBox(height: 14),

              _SetupButton(
                icon: Icons.link_rounded,
                label: 'join with invitation link',
                sublabel: 'paste a link shared by your roommate',
                filled: false,
                onTap: () {
                  _showJoinSheet(context);
                },
              ),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  void _showJoinSheet(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: RColors.bg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            28,
            28,
            28,
            MediaQuery.of(context).viewInsets.bottom + 36,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: RColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'paste your invite link',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: RColors.text,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'ask your roommate to share their invite link with you',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: RColors.primaryMid,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(fontSize: 13, color: RColors.text),
                decoration: InputDecoration(
                  hintText: 'roomie.app/join/xxxxxx',
                  hintStyle: const TextStyle(fontSize: 13, color: RColors.hint),
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(
                    Icons.link_rounded,
                    size: 18,
                    color: RColors.primaryMid,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 13,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: RColors.border,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: RColors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // todo: validate and join home with controller.text
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RColors.primary,
                    foregroundColor: RColors.buttonText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'join home →',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SetupButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final bool filled;
  final VoidCallback onTap;

  const _SetupButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: filled ? RColors.primary : Colors.white,
          border: Border.all(
            color: filled ? RColors.primary : RColors.border,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: filled
                    ? Colors.white.withValues(alpha: 0.15)
                    : RColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: filled ? Colors.white : RColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: filled ? Colors.white : RColors.text,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    sublabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: filled
                          ? Colors.white.withValues(alpha: 0.75)
                          : RColors.primaryMid,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: filled
                  ? Colors.white.withValues(alpha: 0.7)
                  : RColors.primaryMid,
            ),
          ],
        ),
      ),
    );
  }
}
