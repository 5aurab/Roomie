import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/bills_screen.dart';
import '../screens/chores_screen.dart';
import '../screens/plans_screen.dart';
import '../screens/surprise_screen.dart';
import '../widgets/app_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _showMore = false;
  bool _navVisible = true;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const BillsScreen(),
    const ChoresScreen(),
    const PlansScreen(),
    const SurpriseScreen(),
  ];

  final List<(IconData, String)> _navItems = [
    (Icons.home, 'Home'),
    (Icons.calendar_month, 'Calendar'),
    (Icons.receipt_long, 'Bills'),
    (Icons.cleaning_services, 'Chores'),
    (Icons.more_horiz, 'More'),
  ];

  void _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 2 && _navVisible) {
        setState(() {
          _navVisible = false;
          _showMore = false;
        });
      } else if (delta < -2 && !_navVisible) {
        setState(() => _navVisible = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final navColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: RoomieAppBar(currentIndex: _currentIndex),
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          _onScroll(notification);
          return false;
        },
        child: Stack(
          children: [
            _screens[_currentIndex],
            if (_showMore) ...[
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showMore = false),
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: navColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                    ),
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildMoreItem(
                          icon: Icons.star,
                          navColor: navColor,
                          isSelected: _currentIndex == 4,
                          onTap: () => setState(() {
                            _currentIndex = 4;
                            _showMore = false;
                          }),
                        ),
                        _buildMoreItem(
                          icon: Icons.celebration,
                          navColor: navColor,
                          isSelected: _currentIndex == 5,
                          onTap: () => setState(() {
                            _currentIndex = 5;
                            _showMore = false;
                          }),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 80,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            // Nav bar inside Stack so AnimatedSlide works
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                offset: _navVisible ? Offset.zero : const Offset(0, 1.5),
                child: _buildCustomNavBar(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomNavBar(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final isSelected = index == (_currentIndex < 4 ? _currentIndex : 4);
              final (icon, _) = _navItems[index];

              return GestureDetector(
                onTap: () {
                  if (index == 4) {
                    setState(() => _showMore = !_showMore);
                  } else {
                    setState(() {
                      _currentIndex = index;
                      _showMore = false;
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Icon(
                    icon,
                    size: 22,
                    color: isSelected
                        ? Theme.of(context).colorScheme.onSurface
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildMoreItem({
    required IconData icon,
    required Color navColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: navColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
          child: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }
}