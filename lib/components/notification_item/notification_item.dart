import 'package:eventmaster/models/invitation.dart';
import 'package:flutter/material.dart' as material;
import 'package:get/get.dart';
import '../../models/notificacion.dart';
import '../../pages/notifications/notifications_controller.dart';
import '../event_item/event_item_controller.dart';

class NotificationItem extends material.StatelessWidget {
  final Notification notification;

  const NotificationItem({super.key, required this.notification});

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
    final isInvitation = notification.type == NotificationType.invitation;

    String messageText = isInvitation
        ? '¡Has sido invitado a este evento!'
        : notification.generalNotification?.mensaje ?? 'Notificación general';

    final event = notification.event;
    final eventCtrl = event != null ? EventItemController(event: event) : null;

    // Determinar estado de la invitación
    final invitationStatus = notification.invitation?.status;

    return material.Card(
      margin: const material.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: material.Padding(
        padding: const material.EdgeInsets.all(8.0),
        child: material.Column(
          children: [
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
              subtitle: material.Column(
                crossAxisAlignment: material.CrossAxisAlignment.start,
                children: [
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
                  material.Text(
                    messageText,
                    style: material.TextStyle(
                      fontSize: 14,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
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
            // Si es invitación pendiente, mostrar botones
            if (isInvitation && invitationStatus == InvitationStatus.pending)
              material.Row(
                mainAxisAlignment: material.MainAxisAlignment.center,
                children: [
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
            // Si ya fue aceptada o rechazada, mostrar texto
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
