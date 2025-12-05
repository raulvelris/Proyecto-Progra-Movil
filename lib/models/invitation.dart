import 'package:flutter/material.dart';

enum InvitationStatus { pending, accepted, declined }

class Invitation {
  final int notificacionId;
  final DateTime fechaLimite;
  InvitationStatus status;

  Invitation({
    required this.notificacionId,
    required this.fechaLimite,
    this.status = InvitationStatus.pending,
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

extension InviteStatusX on InvitationStatus {
  String get label {
    switch (this) {
      case InvitationStatus.accepted:
        return 'Aceptó';
      case InvitationStatus.declined:
        return 'Rechazó';
      case InvitationStatus.pending:
        return 'Sin respuesta';
    }
  }

  Color get color {
    switch (this) {
      case InvitationStatus.accepted:
        return Colors.green;
      case InvitationStatus.declined:
        return Colors.redAccent;
      case InvitationStatus.pending:
        return Colors.orange;
    }
  }
}

class Invitee {
  final int id;
  final String name;
  final String email;
  final String? photoUrl;
  InvitationStatus status;

  Invitee({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.status = InvitationStatus.pending,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first : '';
    final b = parts.length > 1 ? parts.last : '';
    final i1 = a.isNotEmpty ? a[0] : '';
    final i2 = b.isNotEmpty ? b[0] : '';
    return (i1 + i2).toUpperCase();
  }
}
