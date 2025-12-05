import 'package:flutter/material.dart';

import '../created_events/created_events_page.dart';
import '../attended_events/attended_events_page.dart';
import '../public_events/public_events_page.dart';
import '../inbox/notifications_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialIndex = 2});

  final int initialIndex;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _currentIndex;

  final List<Widget> _pages = [
    const CreatedEventsPage(),
    AttendedEventsPage(),
    PublicEventsPage(),
    const NotificationsPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(
            child: _buildNavItem(0, 'Creados', Icons.edit_calendar_rounded),
          ),
          Flexible(
            child: _buildNavItem(1, 'Asistidos', Icons.event_available_rounded),
          ),
          Flexible(child: _buildNavItem(2, 'Públicos', Icons.public_rounded)),
          Flexible(
            child: _buildNavItem(3, 'Avisos', Icons.notifications_rounded),
          ),
          Flexible(child: _buildNavItem(4, 'Perfil', Icons.person_rounded)),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 26,
            color: isSelected ? Colors.black : Colors.grey.shade400,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.black : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
