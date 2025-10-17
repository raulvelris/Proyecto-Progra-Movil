import 'package:eventmaster/models/invitation.dart';
import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import '../../models/notificacion.dart';
import '../../pages/notifications/notifications_controller.dart';
import '../event_item/event_item_controller.dart';

/// Widget que representa una notificación individual (evento o invitación)
class NotificationItem extends material.StatelessWidget {
  final Notification notification;

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
  material.Widget build(material.BuildContext context) {
    final colors = material.Theme.of(context).colorScheme;

    // Determina si la notificación es de invitación
    final isInvitation = notification.type == NotificationType.invitation;

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

    return material.Card(
      margin: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: material.Padding(
        padding: const material.EdgeInsets.all(8.0),
        child: material.Column(
          children: [
            // Cabecera de la notificación con ícono y tiempo relativo
            material.ListTile(
              leading: material.Icon(
                isInvitation
                    ? material.Icons.person_add
                    : material.Icons.notifications,
                color: colors.primary,
                size: 32,
              ),
              title: material.Text(
                _getRelativeTime(notification.fechaHora),
                style: material.TextStyle(
                  fontSize: 14,
                  color: colors.onSurfaceVariant,
                ),
              ),
              // Subtítulo con información adicional
              subtitle: material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
                  // Nombre del evento si existe
                  if (event != null)
                    material.Text(
                      event.title,
                      style: material.TextStyle(
                        fontWeight: material.FontWeight.bold,
                        fontSize: 16,
                        color: colors.onSurface,
                      ),
                    ),
                  const material.SizedBox(height: 2),
                  // Mensaje principal
                  material.Text(
                    messageText,
                    style: material.TextStyle(
                      fontSize: 14,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  // Fecha y hora del evento si es invitación
                  if (isInvitation && event != null)
                    material.Text(
                      '${eventCtrl!.formatDate(event.startDate)} • ${eventCtrl.formatTime(event.startDate)}',
                      style: material.TextStyle(
                        fontSize: 14,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            // Botones de acción solo para invitaciones pendientes
            if (isInvitation && invitationStatus == InvitationStatus.pending)
              material.Row(
                mainAxisAlignment: material.MainAxisAlignment.center,
                children: [
                  // Botón "Rechazar"
                  material.ElevatedButton(
                    style: material.ElevatedButton.styleFrom(
                      backgroundColor: colors.errorContainer,
                      foregroundColor: colors.onErrorContainer,
                    ),
                    onPressed: () => Get.find<NotificationsController>()
                        .declineInvitation(notification.notificacionId),
                    child: const material.Text('Rechazar'),
                  ),
                  const material.SizedBox(width: 16),
                  // Botón "Aceptar"
                  material.ElevatedButton(
                    style: material.ElevatedButton.styleFrom(
                      backgroundColor: colors.primaryContainer,
                      foregroundColor: colors.onPrimaryContainer,
                    ),
                    onPressed: () => Get.find<NotificationsController>()
                        .acceptInvitation(notification.notificacionId),
                    child: const material.Text('Aceptar'),
                  ),
                ],
              ),
            // Mostrar estado de invitación ya procesada (aceptada/rechazada)
            if (isInvitation &&
                invitationStatus != null &&
                invitationStatus != InvitationStatus.pending)
              material.Padding(
                padding: const material.EdgeInsets.symmetric(vertical: 8.0),
                child: material.Text(
                  invitationStatus == InvitationStatus.accepted
                      ? 'Invitación Aceptada'
                      : 'Invitación Rechazada',
                  style: material.TextStyle(
                    fontWeight: material.FontWeight.bold,
                    fontSize: 14,
                    color: invitationStatus == InvitationStatus.accepted
                        ? colors.primary
                        : colors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
