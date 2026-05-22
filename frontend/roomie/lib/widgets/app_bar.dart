import 'package:flutter/material.dart';
import '../screens/notification_screen.dart';
import '../screens/profile_screen.dart';

class RoomieAppBar extends StatelessWidget implements PreferredSizeWidget {
  final int currentIndex;

  const RoomieAppBar({
    super.key,
    required this.currentIndex,
  });

  static const List<IconData> _icons = [
    Icons.home,
    Icons.calendar_month,
    Icons.receipt_long,
    Icons.cleaning_services,
    Icons.star,
    Icons.celebration,
  ];

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icons[currentIndex], size: 22, color: color),
          const SizedBox(width: 15),
          Text(
            'ROOMIE',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NotificationScreen()),
          ),
          icon: Icon(Icons.notifications_outlined, color: color),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
            icon: Icon(Icons.person_outline, color: color),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}