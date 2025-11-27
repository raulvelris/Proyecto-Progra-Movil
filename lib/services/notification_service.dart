import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../configs/env.dart';
import '../models/notificacion.dart';
import '../models/invitation.dart';
import '../models/general_notification.dart';
import '../models/event.dart';
import 'session_service.dart';

class NotificationService {
  final SessionService _sessionService = SessionService();
  final Logger _logger = Logger();

  /// Obtiene todas las notificaciones (invitaciones + generales)
  Future<List<Notification>> getAllNotifications() async {
    final token = _sessionService.userToken;
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      // 1. Obtener Invitaciones Privadas
      final invitationsResponse = await http.get(
        Uri.parse('${Env.apiUrl}/api/private-invitations'),
        headers: headers,
      );

      // 2. Obtener Notificaciones de Acción
      final notificationsResponse = await http.get(
        Uri.parse('${Env.apiUrl}/api/notifications-action'),
        headers: headers,
      );

      final List<Notification> allNotifications = [];

      // Procesar Invitaciones
      if (invitationsResponse.statusCode == 200) {
        final data = json.decode(invitationsResponse.body);
        if (data['success'] == true) {
          final List<dynamic> items = data['invitaciones'];
          for (var item in items) {
            // Mapear a modelo Invitation

            final eventData = item['evento'];
            Event? event;
            if (eventData != null) {
              event = Event(
                eventId: eventData['evento_id'],
                title: eventData['titulo'] ?? 'Evento sin título',
                startDate: eventData['fechaInicio'] != null
                    ? DateTime.parse(eventData['fechaInicio'])
                    : DateTime.now(),
                endDate: eventData['fechaFin'] != null
                    ? DateTime.parse(eventData['fechaFin'])
                    : DateTime.now(),
                description: '',
                image: '', // Campo requerido por el modelo Event
                location: null,
                privacy: 0,
                eventStatus: 0,
              );
            }

            final invitation = Invitation(
              notificacionId: item['invitacion_usuario_id'],
              fechaLimite: item['fechaLimite'] != null
                  ? DateTime.parse(item['fechaLimite'])
                  : DateTime.now(),
              status: _parseStatus(item['estado']),
            );

            allNotifications.add(
              Notification.fromInvitation(
                invitation,
                eventoId: event?.eventId,
                fechaHora: invitation.fechaLimite,
                event: event,
              ),
            );
          }
        }
      }

      // Procesar Notificaciones de Acción
      if (notificationsResponse.statusCode == 200) {
        final data = json.decode(notificationsResponse.body);
        if (data['success'] == true) {
          final List<dynamic> items = data['notificaciones_accion'];
          for (var item in items) {
            final eventData = item['evento'];
            Event? event;
            if (eventData != null) {
              event = Event(
                eventId: eventData['evento_id'],
                title: eventData['titulo'] ?? 'Evento sin título',
                startDate: DateTime.now(),
                endDate: DateTime.now(),
                description: '',
                image: '',
                location: null,
                privacy: 0,
                eventStatus: 0,
              );
            }

            final generalNotification = GeneralNotification(
              notificacionId: item['notificacion_accion_id'],
              mensaje: item['mensaje'] ?? '',
            );

            allNotifications.add(
              Notification.fromGeneralNotification(
                generalNotification,
                eventoId: event?.eventId,
                fechaHora: item['fechaHora'] != null
                    ? DateTime.parse(item['fechaHora'])
                    : DateTime.now(),
                event: event,
              ),
            );
          }
        }
      }

      // Ordenar por fecha (más reciente primero)
      allNotifications.sort((a, b) => b.fechaHora.compareTo(a.fechaHora));

      return allNotifications;
    } catch (e) {
      _logger.e('Error fetching notifications', e);
      throw Exception('Error al cargar notificaciones');
    }
  }

  InvitationStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'aceptada':
        return InvitationStatus.accepted;
      case 'rechazada':
        return InvitationStatus.declined;
      case 'pendiente':
      default:
        return InvitationStatus.pending;
    }
  }

  /// Acepta una invitación
  Future<bool> acceptInvitation(int invitationId) async {
    return _respondToInvitation(invitationId, true);
  }

  /// Rechaza una invitación
  Future<bool> declineInvitation(int invitationId) async {
    return _respondToInvitation(invitationId, false);
  }

  /// Método privado para enviar la respuesta al backend
  Future<bool> _respondToInvitation(int invitationId, bool accept) async {
    final token = _sessionService.userToken;
    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    try {
      final url = Uri.parse('${Env.apiUrl}/api/invitaciones/respond');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'invitacion_usuario_id': invitationId,
          'accept': accept,
          'estado': accept ? 'aceptada' : 'rechazada',
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      } else {
        // Intentar obtener mensaje de error del backend
        String errorMessage = 'Error al responder invitación';
        try {
          final data = json.decode(response.body);
          if (data['message'] != null) {
            errorMessage = data['message'];
          }
        } catch (_) {}

        _logger.e(
          'Error responding invitation: ${response.statusCode} - $errorMessage',
        );
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('Exception responding invitation', e);
      rethrow;
    }
  }
}
