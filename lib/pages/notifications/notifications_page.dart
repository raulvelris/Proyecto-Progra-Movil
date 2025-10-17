import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/notification_item/notification_item.dart';
import 'notifications_controller.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final NotificationsController controller = Get.put(NotificationsController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avisos'),
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Text(
              controller.error.value,
              style: TextStyle(color: colorScheme.error),
            ),
          );
        }

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

        return RefreshIndicator(
          backgroundColor: colorScheme.surface,
          color: colorScheme.primary,
          onRefresh: () => controller.loadNotifications(),
          child: ListView.builder(
            itemCount: controller.notifications.length,
            itemBuilder: (context, index) {
              final notification = controller.notifications[index];
              return NotificationItem(notification: notification);
            },
          ),
        );
      }),
    );
  }
}