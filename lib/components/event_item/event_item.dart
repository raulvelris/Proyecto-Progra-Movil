import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'event_item_controller.dart';
import '../event_item_list/event_item_list_controller.dart';
import '../../models/event.dart';
import '../../controllers/event_controller.dart';

/// Widget que representa un ítem de evento en la lista.
/// Puede ser un evento público o creado por el usuario.
class EventItem extends StatelessWidget {
  // Evento que se mostrará en este ítem
  final Event event;

  // Controlador asociado al ítem para manejar acciones
  final EventItemController controller;

  // Indica si el evento fue creado por el usuario (para mostrar botones de edición/eliminación)
  final bool isCreatedEvent;

  EventItem({
    super.key,
    required this.event,
    this.isCreatedEvent = false,
  }) : controller = EventItemController(event: event);

  /// Muestra un diálogo de confirmación para eliminar el evento
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
              const Text(
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
                  // Botón "No" para cancelar
                  OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red, width: 1.5),
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('No', style: TextStyle(fontSize: 16)),
                  ),
                  // Botón "Sí" para confirmar eliminación
                  ElevatedButton(
                    onPressed: () {
                      // Determina la lista correcta según tipo de evento
                      final typeTag = isCreatedEvent ? 'created' : 'public';
                      final listController = Get.find<EventItemListController>(
                        tag: 'event_list_$typeTag',
                      );
                      // Elimina el evento de la lista
                      listController.removeEvent(event);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
        // Imagen o ícono del evento
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.primaryContainer,
          ),
          child: EventController.buildImage(
            event.image,
            fit: BoxFit.cover,
            width: 40,
            height: 40,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        // Título del evento
        title: Text(
          event.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        // Subtítulo con fecha, hora y dirección
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.formatDate(event.startDate)} • ${controller.formatTime(event.startDate)}',
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
            if (event.location != null)
              Text(
                event.location!.address,
                style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        // Botones de acción: editar/eliminar si es creado por el usuario
        trailing: isCreatedEvent
            ? SizedBox(
                width: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Botón de editar
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.edit, size: 30, color: colorScheme.primary),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Get.snackbar('Editar', 'Funcionalidad de editar pendiente');
                        },
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Botón de eliminar
                    Expanded(
                      child: IconButton(
                        icon: Icon(Icons.delete, size: 30, color: colorScheme.error),
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          _showDeleteConfirmation(context, controller, event);
                        },
                      ),
                    ),
                  ],
                ),
              )
            : Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface),
        // Acción al tocar el ítem (navegación a detalles)
        onTap: controller.onEventTap,
      ),
    );
  }
}
