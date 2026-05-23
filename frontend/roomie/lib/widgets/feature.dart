import 'package:flutter/material.dart';
import 'colors.dart';

class RoomieFeaturePills extends StatelessWidget {
  const RoomieFeaturePills({super.key});

  static const _pills = [
    (Icons.cleaning_services_outlined, 'chores'),
    (Icons.receipt_outlined, 'bills'),
    (Icons.shopping_cart_outlined, 'groceries'),
    (Icons.calendar_today_outlined, 'schedules'),
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: _pills
          .map(
            (p) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: RoomieColors.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(p.$1, size: 13, color: RoomieColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    p.$2,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: RoomieColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}