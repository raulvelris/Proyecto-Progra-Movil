import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/notification_item/notification_item.dart';
import 'notifications_controller.dart';

// Página principal de notificaciones
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Instancia del controlador con GetX
    final NotificationsController controller = Get.put(NotificationsController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      // AppBar de la página
      appBar: AppBar(
        title: const Text('Avisos'), // Título
        automaticallyImplyLeading: false, // No muestra botón atrás automático
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      // Cuerpo principal
      body: Obx(() {
        // Mostrar cargando si isLoading es true
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Mostrar mensaje de error si existe
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.error.value,
              style: TextStyle(color: colorScheme.error),
            ),
          );
        }

        // Mostrar placeholder si no hay notificaciones
        if (controller.notifications.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No tienes notificaciones',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Lista de notificaciones con pull-to-refresh
        return RefreshIndicator(
          backgroundColor: colorScheme.surface,
          color: colorScheme.primary,
          onRefresh: () => controller.loadNotifications(),
          child: ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              // Cada notificación se renderiza con NotificationItem
              return NotificationItem(notification: notification);
            },
          ),
        );
      }),
    );
  }
}
