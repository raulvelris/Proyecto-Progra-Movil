import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/event_controller.dart';
import '../event_details/event_details_page.dart';

class PublicEventsPage extends StatefulWidget {
  const PublicEventsPage({super.key});

  @override
  State<PublicEventsPage> createState() => _PublicEventsPageState();
}

class _PublicEventsPageState extends State<PublicEventsPage> {
  final controller = Get.find<EventController>();

  @override
  void initState() {
    super.initState();
    controller.ensureSeeded(); // carga una sola vez
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = controller.publicEvents;
      return ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final e = items[i];
          return ListTile(
            leading: const Icon(Icons.event),
            title: Text(e.title),
            subtitle: Text(e.location?.address ?? ''),
            trailing: TextButton(
              onPressed: () => controller.confirm(e.eventId),
              child: const Text('Confirmar'),
            ),
            onTap: () => Get.to(() => EventDetailsPage(eventId: e.eventId)),
          );
        },
      );
    });
  }
}
