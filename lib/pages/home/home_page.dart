import 'package:flutter/material.dart';

import '../created_events/created_events_page.dart';
import '../attended_events/attended_events_page.dart';
import '../public_events/public_events_page.dart';
import '../notifications/notifications_page.dart';
import '../profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 2; // Pestaña "Públicos" por defecto

  final List<Widget> _pages = [
    const CreatedEventsPage(),
    AttendedEventsPage(),
    PublicEventsPage(),
    const NotificationsPage(),
    ProfilePage(),
  ];

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
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Flexible(child: _buildNavItem(0, 'Creados', Icons.create)),
          Flexible(child: _buildNavItem(1, 'Asistidos', Icons.event_available)),
          Flexible(child: _buildNavItem(2, 'Públicos', Icons.public)),
          Flexible(child: _buildNavItem(3, 'Avisos', Icons.notifications)),
          Flexible(child: _buildNavItem(4, 'Perfil', Icons.person)),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, String label, IconData icon) {
    final isSelected = _currentIndex == index;
    final colors = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 24,
            color: isSelected ? colors.primary : colors.onSurface.withOpacity(0.6),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? colors.primary : colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
