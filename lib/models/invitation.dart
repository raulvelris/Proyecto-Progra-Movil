import 'package:flutter/material.dart';

enum InviteStatus { pending, accepted, rejected }

extension InviteStatusX on InviteStatus {
  String get label {
    switch (this) {
      case InviteStatus.accepted:
        return 'Aceptó';
      case InviteStatus.rejected:
        return 'Rechazó';
      case InviteStatus.pending:
      default:
        return 'Sin respuesta';
    }
  }

  Color get color {
    switch (this) {
      case InviteStatus.accepted:
        return Colors.green;
      case InviteStatus.rejected:
        return Colors.redAccent;
      case InviteStatus.pending:
      default:
        return Colors.orange;
    }
  }
}

class Invitee {
  final int id;
  final String name;
  final String email;
  InviteStatus status;

  Invitee({
    required this.id,
    required this.name,
    required this.email,
    this.status = InviteStatus.pending,
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
