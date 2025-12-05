import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'event_item_controller.dart';
import '../event_item_list/event_item_list_controller.dart';
import '../../models/event.dart';
import '../../controllers/event_controller.dart';
import '../../pages/edit_event/edit_event_page.dart';

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
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botón "Sí" para confirmar eliminación
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back(); // Cerrar el diálogo
                        
                        // Mostrar indicador de carga
                        Get.dialog(
                          const Center(
                            child: CircularProgressIndicator(color: Colors.black),
                          ),
                          barrierDismissible: false,
                        );

                        try {
                          // Llamar al servicio para eliminar el evento
                          await controller.deleteEvent();
                          
                          // Cerrar el indicador de carga
                          Get.back();

                          // Determina la lista correcta según tipo de evento
                          final typeTag = isCreatedEvent ? 'created' : 'public';
                          final listController = Get.find<EventItemListController>(
                            tag: 'event_list_$typeTag',
                          );
                          
                          // Elimina el evento de la lista
                          listController.removeEvent(event);

                          // Mostrar mensaje de éxito
                          Get.snackbar(
                            'Éxito',
                            'Evento eliminado correctamente',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                          );
                        } catch (e) {
                          // Cerrar el indicador de carga
                          Get.back();
                          
                          // Mostrar mensaje de error
                          Get.snackbar(
                            'Error',
                            e.toString().replaceAll('Exception: ', ''),
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            duration: const Duration(seconds: 4),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Eliminar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: controller.onEventTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              // Imagen del evento
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey.shade200,
                ),
                clipBehavior: Clip.antiAlias,
                child: EventController.buildImage(
                  event.image,
                  fit: BoxFit.cover,
                  width: 56,
                  height: 56,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(width: 12),
              // Información del evento
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            controller.formatDate(event.startDate),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            controller.formatTime(event.startDate),
                            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (event.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.location!.address,
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Botones de acción o flecha
              if (isCreatedEvent) ...[
                const SizedBox(width: 6),
                _buildActionButton(
                  icon: Icons.edit_outlined,
                  color: Colors.blue.shade700,
                  onPressed: () {
                    Get.to(() => EditEventPage(), arguments: event);
                  },
                ),
                const SizedBox(width: 4),
                _buildActionButton(
                  icon: Icons.delete_outline_rounded,
                  color: Colors.red.shade700,
                  onPressed: () {
                    _showDeleteConfirmation(context, controller, event);
                  },
                ),
              ] else ...[
                const SizedBox(width: 8),
                Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
