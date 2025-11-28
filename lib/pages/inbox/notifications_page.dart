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

    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar de la página
      appBar: AppBar(
        title: const Text(
          'Avisos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ), // Título
        centerTitle: false,
        automaticallyImplyLeading: false, // No muestra botón atrás automático
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      // Cuerpo principal
      body: Obx(() {
        // Mostrar cargando si isLoading es true
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        // Mostrar mensaje de error si existe
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.error.value,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // Mostrar placeholder si no hay notificaciones
        if (controller.notifications.isEmpty) {
          return RefreshIndicator(
            backgroundColor: Colors.white,
            color: Colors.black,
            onRefresh: () => controller.loadNotifications(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No tienes notificaciones',
                        style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }

        // Lista de notificaciones con pull-to-refresh
        return RefreshIndicator(
          backgroundColor: Colors.white,
          color: Colors.black,
          onRefresh: () => controller.loadNotifications(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
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
