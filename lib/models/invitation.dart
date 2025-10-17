// Enum para el estado de la invitación
enum InvitationStatus {
  pending,   // Pendiente
  accepted,  // Aceptada
  declined,  // Rechazada
}

class Invitation {
  final int notificacionId;
  final DateTime fechaLimite;
  InvitationStatus status;

  Invitation({
    required this.notificacionId,
    required this.fechaLimite,
    this.status = InvitationStatus.pending, // por defecto pendiente
  });

  factory Invitation.fromJson(Map<String, dynamic> json) {
    return Invitation(
      notificacionId: json['notificacion_id'],
      fechaLimite: DateTime.parse(json['fechaLimite']),
      status: json['status'] != null
          ? InvitationStatus.values[json['status']]
          : InvitationStatus.pending,
    );
  }
}

