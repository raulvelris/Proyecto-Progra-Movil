import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../event_details/event_details_page.dart';

class AttendedEventsPage extends StatelessWidget {
  AttendedEventsPage({super.key});

  final controller = Get.find<EventController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.attendedEvents;
      if (items.isEmpty) {
        return const Center(child: Text('Aún no asistes a eventos'));
      }
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final e = items[i];
          return ListTile(
            leading: const Icon(Icons.event_available),
            title: Text(e.title),
            subtitle: Text(e.location?.address ?? ''),
            trailing: TextButton(
              onPressed: () => controller.cancel(e.eventId),
              child: const Text('Cancelar'),
            ),
            onTap: () => Get.to(() => EventDetailsPage(eventId: e.eventId)),
          );
        },
      );
    });
  }
}
