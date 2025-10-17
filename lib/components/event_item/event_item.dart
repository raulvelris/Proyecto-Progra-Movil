import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'event_item_controller.dart';
import '../event_item_list/event_item_list_controller.dart';
import '../../models/event.dart';

class EventItem extends StatelessWidget {
  final Event event;
  final EventItemController controller;
  final bool isCreatedEvent;

  EventItem({super.key, required this.event, this.isCreatedEvent = false})
    : controller = EventItemController(event: event);

  void _showDeleteConfirmation(
    BuildContext context,
    EventItemController controller,
    Event event,
  ) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¿Estás seguro de eliminar este evento?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción es irreversible.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('No', style: TextStyle(fontSize: 16)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Llamar al controlador de la lista para eliminar el evento
                      final listController = Get.find<EventItemListController>(
                        tag: 'event_list_created',
                      );
                      listController.removeEvent(event);
                      Get.back();
                      Get.snackbar(
                        'Eliminar',
                        'Evento eliminado correctamente',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 45,
                        vertical: 9,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sí', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 40, // Ancho reducido para evitar overflow
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.primaryContainer,
          ),
          child: event.image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    event.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.event,
                        color: colorScheme.onPrimaryContainer,
                      );
                    },
                  ),
                )
              : Icon(Icons.event, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.formatDate(event.startDate)} • ${controller.formatTime(event.startDate)}',
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (event.location != null)
              Text(
                event.location!.address,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: isCreatedEvent
            ? SizedBox(
                width: 50, // Ancho fijo
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.edit,
                          size: 30,
                          color: colorScheme.primary,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.snackbar(
                            'Editar',
                            'Funcionalidad de editar pendiente',
                          );
                        },
                      ),
                    ),
                    const SizedBox(
                      height: 15,
                    ), // Separación vertical entre botones
                    Expanded(
                      child: IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 30,
                          color: colorScheme.error,
                        ),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _showDeleteConfirmation(context, controller, event);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: colorScheme.onSurface,
              ),
        onTap: controller.onEventTap,
      ),
    );
  }
}
