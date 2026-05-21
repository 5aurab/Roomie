import 'package:flutter/material.dart';
import '../screens/home_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/bills_screen.dart';
import '../screens/chores_screen.dart';
import '../screens/plans_screen.dart';
import '../screens/surprise_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  bool _showMore = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const BillsScreen(),
    const ChoresScreen(),
    const PlansScreen(),
    const SurpriseScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final navColor = Theme.of(context).navigationBarTheme.backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainer;

    return Scaffold(
      body: Stack(
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
                        icon: Icons.event_note,
                        label: 'Plans',
                        navColor: navColor,
                        onTap: () => setState(() {
                          _currentIndex = 4;
                          _showMore = false;
                        }),
                      ),
                      _buildMoreItem(
                        icon: Icons.celebration,
                        label: 'Surprise',
                        navColor: navColor,
                        onTap: () => setState(() {
                          _currentIndex = 5;
                          _showMore = false;
                        }),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex < 4 ? _currentIndex : 4,
        animationDuration: Duration.zero,
        indicatorColor: Colors.grey.withValues(alpha: 0.2),
        onDestinationSelected: (index) {
          if (index == 4) {
            setState(() => _showMore = !_showMore);
          } else {
            setState(() {
              _currentIndex = index;
              _showMore = false;
            });
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.calendar_month), label: 'Calendar'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Bills'),
          NavigationDestination(icon: Icon(Icons.cleaning_services), label: 'Chores'),
          NavigationDestination(icon: Icon(Icons.more_horiz), label: 'More'),
        ],
      ),
    );
  }

  Widget _buildMoreItem({
    required IconData icon,
    required String label,
    required Color navColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: navColor,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}