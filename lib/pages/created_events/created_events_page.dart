import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/event_item_list/event_item_list.dart';
import '../../components/event_item_list/event_item_list_controller.dart';
import '../create_event/create_event_page.dart';

class CreatedEventsPage extends StatelessWidget {
  const CreatedEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Eventos Creados'),
        automaticallyImplyLeading: false,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: FloatingActionButton(
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
                    );
                  }
                },
                backgroundColor: colorScheme.primary,
                child: const Icon(Icons.add),
              ),
            ),
          ),
          Expanded(child: EventItemList(eventType: 'created')),
        ],
      ),
    );
  }
}
