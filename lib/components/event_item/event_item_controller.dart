import 'package:get/get.dart';
import '../../models/event.dart';
import '../../services/delete_event_service.dart';

/// Controlador para un ítem de evento en la lista
class EventItemController extends GetxController {
  // Evento asociado a este controlador
  final Event event;

  // Servicio para eliminar eventos
  final DeleteEventService _deleteEventService = DeleteEventService();

  // Constructor obligatorio para recibir el evento
  EventItemController({required this.event});

  /// Método que se ejecuta al tocar el ítem del evento
  /// Navega a la página de detalles del evento usando GetX
  void onEventTap() {
    Get.toNamed(
      '/event-details', // Ruta definida en GetX para detalles de eventos
      arguments: {'eventId': event.eventId}, // Se pasa el ID del evento
    );
  }

  /// Elimina el evento usando el servicio
  Future<void> deleteEvent() async {
    await _deleteEventService.deleteEvent(event.eventId);
  }

  /// Formatea una fecha a un string tipo "16 Oct 2025"
  String formatDate(DateTime date) {
    const List<String> months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Dic'
    ];
    // Retorna día + mes abreviado + año
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Formatea la hora a un string tipo "14:05"
  String formatTime(DateTime date) {
    // Añade un 0 delante si los minutos son menores a 10
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}