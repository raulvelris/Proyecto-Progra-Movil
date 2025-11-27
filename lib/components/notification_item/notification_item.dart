import 'package:eventmaster/models/invitation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/notificacion.dart' as models;
import '../../pages/inbox/notifications_controller.dart';
import '../event_item/event_item_controller.dart';

/// Widget que representa una notificación individual (evento o invitación)
class NotificationItem extends StatelessWidget {
  final models.Notification notification;

  const NotificationItem({super.key, required this.notification});

  /// Retorna el tiempo relativo desde la fecha de la notificación hasta ahora
  /// Ejemplos: "Hace 5 min", "Hace 1 h", "Hace 2 días"
  String _getRelativeTime(DateTime fechaHora) {
    final diff = DateTime.now().difference(fechaHora);
    if (diff.inMinutes < 1) return 'Hace un momento';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours} h';
    return 'Hace ${diff.inDays} día${diff.inDays > 1 ? 's' : ''}';
  }

  @override
  Widget build(BuildContext context) {
    // Determina si la notificación es de invitación
    final isInvitation = notification.type == models.NotificationType.invitation;

    // Texto que se mostrará según el tipo de notificación
    String messageText = isInvitation
        ? '¡Has sido invitado a este evento!'
        : notification.generalNotification?.mensaje ?? 'Notificación general';

    // Objeto de evento relacionado, si existe
    final event = notification.event;

    // Controlador temporal para formatear fechas y horas del evento
    final eventCtrl = event != null ? EventItemController(event: event) : null;

    // Estado de la invitación (pendiente, aceptada, rechazada)
    final invitationStatus = notification.invitation?.status;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera con ícono y tiempo
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isInvitation ? Colors.blue.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isInvitation ? Icons.person_add_outlined : Icons.notifications_outlined,
                    color: isInvitation ? Colors.blue.shade700 : Colors.grey.shade700,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getRelativeTime(notification.fechaHora),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (event != null) ...[
                        const SizedBox(height: 2),
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
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Mensaje principal
            Text(
              messageText,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            // Fecha y hora del evento si es invitación
            if (isInvitation && event != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    eventCtrl!.formatDate(event.startDate),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    eventCtrl.formatTime(event.startDate),
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
            // Botones de acción solo para invitaciones pendientes
            if (isInvitation && invitationStatus == InvitationStatus.pending) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Get.find<NotificationsController>()
                          .declineInvitation(notification.notificacionId),
                      child: const Text(
                        'Rechazar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Get.find<NotificationsController>()
                          .acceptInvitation(notification.notificacionId),
                      child: const Text(
                        'Aceptar',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            // Mostrar estado de invitación ya procesada (aceptada/rechazada)
            if (isInvitation &&
                invitationStatus != null &&
                invitationStatus != InvitationStatus.pending) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: invitationStatus == InvitationStatus.accepted
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: invitationStatus == InvitationStatus.accepted
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      invitationStatus == InvitationStatus.accepted
                          ? Icons.check_circle_outline_rounded
                          : Icons.cancel_outlined,
                      size: 16,
                      color: invitationStatus == InvitationStatus.accepted
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      invitationStatus == InvitationStatus.accepted
                          ? 'Invitación Aceptada'
                          : 'Invitación Rechazada',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: invitationStatus == InvitationStatus.accepted
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
