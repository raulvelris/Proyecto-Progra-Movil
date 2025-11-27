import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/event_item_list/event_item_list.dart';
import '../../components/event_item_list/event_item_list_controller.dart';
import '../create_event/create_event_page.dart';

class CreatedEventsPage extends StatelessWidget {
  const CreatedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Mis Eventos',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Get.to(() => CreateEventPage());
                  if (result != null) {
                    final controller = Get.find<EventItemListController>(
                      tag: 'event_list_created',
                    );
                    controller.addEvent(result);
                    await controller.refreshEvents();
                    Get.snackbar(
                      'Éxito',
                      'Evento creado y agregado a la lista',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.black,
                      colorText: Colors.white,
                      margin: const EdgeInsets.all(16),
                      borderRadius: 12,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text(
                  'Crear Nuevo Evento',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: EventItemList(eventType: 'created')),
        ],
      ),
    );
  }
}
