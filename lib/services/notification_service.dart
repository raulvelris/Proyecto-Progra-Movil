import 'package:flutter/material.dart' as material;

import '../models/notificacion.dart';
import '../models/invitation.dart';
import '../models/general_notification.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class NotificationService {
  // Estado persistente de las invitaciones procesadas
  static final Map<int, InvitationStatus> _invitationStates = {};
  Future<List<Notification>> getAllNotifications() async {
    await Future.delayed(const Duration(seconds: 1));

    final invitations = await _getMockInvitations();
    final generalNotifications = await _getMockGeneralNotifications();
    final mockNotifications = await _getMockNotifications();

    // Fetch events for notifications that have eventoId
    final eventService = EventService();
    final eventMap = <int, Event>{};
    for (final notification in mockNotifications) {
      if (notification.eventoId != null) {
        try {
          final event = await eventService.getEventById(notification.eventoId!);
          eventMap[notification.eventoId!] = event;
        } catch (e) {
          material.debugPrint(
            'Failed to fetch event ${notification.eventoId}: $e',
          );
        }
      }
    }

    final notifications = <Notification>[];

    // Notificaciones de invitación
    for (
      var i = 0;
      i < invitations.length && i < mockNotifications.length;
      i++
    ) {
      final mockNotification = mockNotifications[i];
      final event = eventMap[mockNotification.eventoId];

      notifications.add(
        Notification.fromInvitation(
          invitations[i],
          eventoId: mockNotification.eventoId,
          fechaHora: mockNotification.fechaHora,
          event: event,
        ),
      );
    }

    // Notificaciones generales
    for (var i = invitations.length; i < mockNotifications.length; i++) {
      final mockNotification = mockNotifications[i];
      final event = eventMap[mockNotification.eventoId];

      notifications.add(
        Notification.fromGeneralNotification(
          generalNotifications[i - invitations.length],
          eventoId: mockNotification.eventoId,
          fechaHora: mockNotification.fechaHora,
          event: event,
        ),
      );
    }

    // Ordenar notificaciones: pendientes primero, procesadas al final
    notifications.sort((a, b) {
      final aStatus = a.invitation?.status ?? InvitationStatus.pending;
      final bStatus = b.invitation?.status ?? InvitationStatus.pending;

      // Si ambas son del mismo tipo, mantener orden original
      if (aStatus == bStatus) {
        return 0;
      }

      // Las pendientes van primero
      if (aStatus == InvitationStatus.pending && bStatus != InvitationStatus.pending) {
        return -1;
      }

      // Las procesadas van al final
      if (aStatus != InvitationStatus.pending && bStatus == InvitationStatus.pending) {
        return 1;
      }

      return 0;
    });

    return notifications;
  }

  Future<bool> acceptInvitation(int invitationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Guardar el estado de la invitación como aceptada
    _invitationStates[invitationId] = InvitationStatus.accepted;
    return true;
  }

  Future<bool> declineInvitation(int invitationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Guardar el estado de la invitación como rechazada
    _invitationStates[invitationId] = InvitationStatus.declined;
    return true;
  }

  Future<List<Notification>> _getMockNotifications() async {
    return [
      Notification(
        notificacionId: 1,
        fechaHora: DateTime(2025, 10, 16, 10, 30),
        eventoId: 1,
        type: NotificationType.invitation,
      ),
      Notification(
        notificacionId: 2,
        fechaHora: DateTime(2025, 10, 15, 14, 0),
        eventoId: 2,
        type: NotificationType.general,
      ),
      Notification(
        notificacionId: 3,
        fechaHora: DateTime(2025, 10, 16, 6, 0),
        eventoId: 3,
        type: NotificationType.general,
      ),
    ];
  }

  Future<List<GeneralNotification>> _getMockGeneralNotifications() async {
    return [
      GeneralNotification(
        notificacionId: 3,
        mensaje: 'El evento ha sido cancelado.',
      ),
    ];
  }

  // Mocks actualizados con estado persistente
  Future<List<Invitation>> _getMockInvitations() async {
    return [
      Invitation(
        notificacionId: 1,
        fechaLimite: DateTime(2025, 10, 22, 14, 0),
        status: _invitationStates[1] ?? InvitationStatus.pending,
      ),
      Invitation(
        notificacionId: 2,
        fechaLimite: DateTime(2025, 10, 23, 6, 0),
        status: _invitationStates[2] ?? InvitationStatus.pending,
      ),
    ];
  }
}
