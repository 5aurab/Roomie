import 'package:flutter/material.dart';
import '../themes/colors.dart';

class AuthTabs extends StatelessWidget {
  final String activeTab;
  final VoidCallback onInactiveTap;

  const AuthTabs({
    super.key,
    required this.activeTab,
    required this.onInactiveTap,
  });

  @override
  Widget build(BuildContext context) {
    final loginActive = activeTab == 'login';
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: RColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Tab(
              label: 'log in',
              active: loginActive,
              onTap: loginActive ? () {} : onInactiveTap,
            ),
          ),
          Expanded(
            child: _Tab(
              label: 'sign up',
              active: !loginActive,
              onTap: loginActive ? onInactiveTap : () {},
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: active ? RColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: active
                ? RColors.buttonText
                : RColors.primaryMid,
          ),
        ),
      ),
    );
  }
}