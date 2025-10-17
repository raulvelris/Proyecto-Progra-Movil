import 'package:flutter/material.dart' as material;

import '../models/notificacion.dart';
import '../models/invitation.dart';
import '../models/general_notification.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class NotificationService {
  // Mapa estático para mantener el estado de las invitaciones procesadas
  static final Map<int, InvitationStatus> _invitationStates = {};

  /// Obtiene todas las notificaciones (invitaciones + generales)
  Future<List<Notification>> getAllNotifications() async {
    // Simula un retraso como si viniera de una API
    await Future.delayed(const Duration(seconds: 1));

    // Cargar invitaciones, notificaciones generales y mock de notificaciones
    final invitations = await _getMockInvitations();
    final generalNotifications = await _getMockGeneralNotifications();
    final mockNotifications = await _getMockNotifications();

    // Servicio para obtener información de eventos asociados
    final eventService = EventService();
    final eventMap = <int, Event>{};

    // Recorrer todas las notificaciones y obtener su evento si tiene eventoId
    for (final notification in mockNotifications) {
      if (notification.eventoId != null) {
        try {
          final event = await eventService.getEventById(notification.eventoId!);
          eventMap[notification.eventoId!] = event;
        } catch (e) {
          // Debug en consola si falla la obtención del evento
          material.debugPrint(
            'Failed to fetch event ${notification.eventoId}: $e',
          );
        }
      }
    }

    final notifications = <Notification>[];

    // Crear notificaciones tipo invitación
    // Se hace un match entre invitations y mockNotifications por índice
    for (var i = 0; i < invitations.length && i < mockNotifications.length; i++) {
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

    // Crear notificaciones generales
    // Se ajusta el índice restando la cantidad de invitaciones
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

    // Ordenar notificaciones: primero las pendientes, luego las aceptadas/rechazadas
    notifications.sort((a, b) {
      final aStatus = a.invitation?.status ?? InvitationStatus.pending;
      final bStatus = b.invitation?.status ?? InvitationStatus.pending;

      // Si el estado es igual, mantener el orden original
      if (aStatus == bStatus) return 0;

      // Pendientes van primero
      if (aStatus == InvitationStatus.pending && bStatus != InvitationStatus.pending) {
        return -1;
      }

      // Procesadas van al final
      if (aStatus != InvitationStatus.pending && bStatus == InvitationStatus.pending) {
        return 1;
      }

      return 0;
    });

    return notifications;
  }

  /// Acepta una invitación y actualiza su estado en memoria
  Future<bool> acceptInvitation(int invitationId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula delay
    _invitationStates[invitationId] = InvitationStatus.accepted; // Guardar estado
    return true;
  }

  /// Rechaza una invitación y actualiza su estado en memoria
  Future<bool> declineInvitation(int invitationId) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simula delay
    _invitationStates[invitationId] = InvitationStatus.declined; // Guardar estado
    return true;
  }

  /// Mock de notificaciones (tipo Notification)
  Future<List<Notification>> _getMockNotifications() async {
    return [
      Notification(
        notificacionId: 1,
        fechaHora: DateTime(2025, 10, 16, 10, 30),
        eventoId: 1,
        type: NotificationType.invitation, // Tipo invitación
      ),
      Notification(
        notificacionId: 2,
        fechaHora: DateTime(2025, 10, 15, 14, 0),
        eventoId: 2,
        type: NotificationType.general, // Tipo general
      ),
      Notification(
        notificacionId: 3,
        fechaHora: DateTime(2025, 10, 16, 6, 0),
        eventoId: 3,
        type: NotificationType.general,
      ),
    ];
  }

  /// Mock de notificaciones generales
  Future<List<GeneralNotification>> _getMockGeneralNotifications() async {
    return [
      GeneralNotification(
        notificacionId: 3,
        mensaje: 'El evento ha sido cancelado.',
      ),
    ];
  }

  /// Mock de invitaciones con estado persistente en memoria
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
