import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/session_service.dart';

class ProfilePage extends StatelessWidget {
  final SessionService sessionService = SessionService();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Extraer las iniciales del email o usar "DT" por defecto
    String getInitials(String? email) {
      if (email == null || email.isEmpty) return 'DT';
      final parts = email.split('@')[0].split('.');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return email.substring(0, 2).toUpperCase();
    }

    String formatName(String? email) {
      if (email == null || email.isEmpty) return 'Dylan Thomas';
      final namePart = email.split('@')[0];
      final parts = namePart.split('.');
      if (parts.length >= 2) {
        return '${parts[0][0].toUpperCase()}${parts[0].substring(1)} ${parts[1][0].toUpperCase()}${parts[1].substring(1)}';
      }
      return namePart[0].toUpperCase() + namePart.substring(1);
    }

    final initials = getInitials(sessionService.userEmail);
    final userName = formatName(sessionService.userEmail);
    final userEmail = sessionService.userEmail ?? 'dylanthomas@server.com';

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Avatar section
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                initials,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onPrimaryContainer,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Name
            Text(
              userName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            // Email
            Text(
              userEmail,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            // Menu items
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildMenuItem(
                    title: 'Editar Perfil',
                    onTap: () {
                      Get.toNamed('/edit-profile-options');
                    },
                    showDivider: true,
                    colorScheme: colorScheme,
                  ),
                  _buildMenuItem(
                    title: 'Cerrar sesión',
                    onTap: () {
                      sessionService.logout();
                      Get.offAllNamed('/welcome');
                    },
                    showDivider: true,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}