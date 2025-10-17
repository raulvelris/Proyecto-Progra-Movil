import 'package:get/get.dart';
import '../../models/notificacion.dart';
import '../../models/invitation.dart';
import '../../services/notification_service.dart';

class NotificationsController extends GetxController {
  final NotificationService _notificationService = NotificationService();
  final RxList<Notification> notifications = <Notification>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    try {
      isLoading.value = true;
      error.value = '';
      final data = await _notificationService.getAllNotifications();
      notifications.assignAll(data);
    } catch (e) {
      error.value = 'Error al cargar notificaciones: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> acceptInvitation(int invitationId) async {
    try {
      final success = await _notificationService.acceptInvitation(invitationId);
      if (success) {
        _updateInvitationStatus(invitationId, InvitationStatus.accepted);
        Get.snackbar('Éxito', 'Invitación aceptada');
      } else {
        Get.snackbar('Error', 'No se pudo aceptar la invitación');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al aceptar invitación');
    }
  }

  Future<void> declineInvitation(int invitationId) async {
    try {
      final success = await _notificationService.declineInvitation(invitationId);
      if (success) {
        _updateInvitationStatus(invitationId, InvitationStatus.declined);
        Get.snackbar('Éxito', 'Invitación rechazada');
      } else {
        Get.snackbar('Error', 'No se pudo rechazar la invitación');
      }
    } catch (e) {
      Get.snackbar('Error', 'Error al rechazar invitación');
    }
  }

  void _updateInvitationStatus(int invitationId, InvitationStatus status) {
    final index = notifications.indexWhere((n) => n.notificacionId == invitationId);
    if (index != -1) {
      final notification = notifications[index];
      if (notification.invitation != null) {
        notification.invitation!.status = status;
        final updated = notifications.removeAt(index);
        notifications.add(updated);
        notifications.refresh();
      }
    }
  }
}
