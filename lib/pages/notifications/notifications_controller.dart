import 'package:get/get.dart';
import '../../models/notificacion.dart';
import '../../models/invitation.dart';
import '../../services/notification_service.dart';

// Controlador de notificaciones usando GetX
class NotificationsController extends GetxController {
  // Servicio para manejar las notificaciones
  final NotificationService _notificationService = NotificationService();

  // Lista observable de notificaciones
  final RxList<Notification> notifications = <Notification>[].obs;

  // Estado de carga
  final RxBool isLoading = true.obs;

  // Mensaje de error
  final RxString error = ''.obs;

  // Método que se ejecuta al inicializar el controlador
  @override
  void onInit() {
    super.onInit();
    loadNotifications(); // Carga las notificaciones al iniciar
  }

  // Método para cargar todas las notificaciones
  Future<void> loadNotifications() async {
    try {
      isLoading.value = true; // Activar indicador de carga
      error.value = ''; // Limpiar errores
      final data = await _notificationService.getAllNotifications(); // Obtener datos
      notifications.assignAll(data); // Asignar datos a la lista observable
    } catch (e) {
      error.value = 'Error al cargar notificaciones: $e'; // Guardar mensaje de error
    } finally {
      isLoading.value = false; // Desactivar indicador de carga
    }
  }

  // Método para aceptar una invitación
  Future<void> acceptInvitation(int invitationId) async {
    try {
      final success = await _notificationService.acceptInvitation(invitationId); // Llamada al servicio
      if (success) {
        _updateInvitationStatus(invitationId, InvitationStatus.accepted); // Actualizar estado
        Get.snackbar('Éxito', 'Invitación aceptada'); // Mostrar mensaje
      } else {
        Get.snackbar('Error', 'No se pudo aceptar la invitación'); // Error de operación
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al aceptar invitación'); // Error de excepción
    }
  }

  // Método para rechazar una invitación
  Future<void> declineInvitation(int invitationId) async {
    try {
      final success = await _notificationService.declineInvitation(invitationId); // Llamada al servicio
      if (success) {
        _updateInvitationStatus(invitationId, InvitationStatus.declined); // Actualizar estado
        Get.snackbar('Éxito', 'Invitación rechazada'); // Mostrar mensaje
      } else {
        Get.snackbar('Error', 'No se pudo rechazar la invitación'); // Error de operación
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al rechazar invitación'); // Error de excepción
    }
  }

  // Método privado para actualizar el estado de una invitación en la lista de notificaciones
  void _updateInvitationStatus(int invitationId, InvitationStatus status) {
    final index = notifications.indexWhere((n) => n.notificacionId == invitationId); // Buscar notificación
    if (index != -1) {
      final notification = notifications[index];
      if (notification.invitation != null) {
        notification.invitation!.status = status; // Actualizar estado
        final updated = notifications.removeAt(index); // Remover de la lista
        notifications.add(updated); // Volver a agregar para refrescar la UI
        notifications.refresh(); // Forzar actualización de GetX
      }
    }
  }
}
