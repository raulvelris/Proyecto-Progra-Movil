import 'invitation.dart';
import 'general_notification.dart';
import 'event.dart'; // importa tu modelo Event

enum NotificationType {
  invitation,
  general,
}

class Notification {
  final int notificacionId;
  final DateTime fechaHora;
  final int? eventoId;
  final NotificationType type;
  final Invitation? invitation;
  final GeneralNotification? generalNotification;
  // Evento ya cargado 
  final Event? event;

  Notification({
    required this.notificacionId,
    required this.fechaHora,
    this.eventoId,
    required this.type,
    this.invitation,
    this.generalNotification,
    this.event,
  });

  factory Notification.fromInvitation(
    Invitation invitation, {
    int? eventoId,
    DateTime? fechaHora,
    Event? event,
  }) {
    return Notification(
      notificacionId: invitation.notificacionId,
      fechaHora: fechaHora ?? DateTime.now(),
      eventoId: eventoId,
      type: NotificationType.invitation,
      invitation: invitation,
      event: event,
    );
  }

  factory Notification.fromGeneralNotification(
    GeneralNotification generalNotification, {
    int? eventoId,
    DateTime? fechaHora,
    Event? event,
  }) {
    return Notification(
      notificacionId: generalNotification.notificacionId,
      fechaHora: fechaHora ?? DateTime.now(),
      eventoId: eventoId,
      type: NotificationType.general,
      generalNotification: generalNotification,
      event: event,
    );
  }

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      notificacionId: json['notificacion_id'],
      fechaHora: DateTime.parse(json['fechaHora']),
      eventoId: json['evento_id'],
      type: NotificationType.values[json['type'] ?? 0],
      invitation: json['invitation'] != null
          ? Invitation.fromJson(json['invitation'])
          : null,
      generalNotification: json['generalNotification'] != null
          ? GeneralNotification.fromJson(json['generalNotification'])
          : null,
      event: json['event'] != null ? Event.fromJson(json['event']) : null,
    );
  }
}
