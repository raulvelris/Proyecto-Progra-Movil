import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/session_service.dart';

class ProfilePage extends StatelessWidget {
  final SessionService sessionService = SessionService();

  ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: colorScheme.primary,
              child: Icon(Icons.person, size: 50, color: colorScheme.onPrimary),
            ),
            const SizedBox(height: 20),
            Text(
              sessionService.userEmail ?? 'Usuario',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              sessionService.userEmail ?? 'correo@ejemplo.com',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _buildProfileItem(
                    icon: Icons.edit,
                    title: 'Editar Perfil',
                    onTap: () {},
                    context: context
                  ),
                  _buildProfileItem(
                    icon: Icons.settings,
                    title: 'Configuración',
                    onTap: () {},
                    context: context
                  ),
                  _buildProfileItem(
                    icon: Icons.help,
                    title: 'Ayuda y Soporte',
                    onTap: () {},
                    context: context
                  ),
                  _buildProfileItem(
                    icon: Icons.logout,
                    title: 'Cerrar Sesión',
                    onTap: () {
                      sessionService.logout();
                      Get.offAllNamed('/welcome');
                    },
                    context: context
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BuildContext context
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Theme.of(context).colorScheme.onSurface),
        onTap: onTap,
      ),
    );
  }
}