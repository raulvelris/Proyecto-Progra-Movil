import 'package:flutter/material.dart';

class InviteListPage extends StatelessWidget {
  const InviteListPage({super.key});

  // Datos “fake”
  List<_Invite> get _data => const [
    _Invite('Aaron Lobo', _InviteStatus.going),
    _Invite('Brenda Campos', _InviteStatus.undecided),
    _Invite('Carlos Paredes', _InviteStatus.rejected),
    _Invite('Daniela Rivas', _InviteStatus.going),
    _Invite('Eduardo Salas', _InviteStatus.undecided),
    _Invite('Fiorella Ñique', _InviteStatus.rejected),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lista de invitados',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _data.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = _data[i];
          final badge = _statusBadge(item.status);
          return Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: Colors.black,
                child: Text(
                  _initials(item.name),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                item.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              trailing: badge,
            ),
          );
        },
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }

  static Widget _statusBadge(_InviteStatus s) {
    late final String label;
    late final Color bg, fg;

    switch (s) {
      case _InviteStatus.going:
        label = 'Asistirá';
        bg = Colors.green.shade50;
        fg = Colors.green.shade700;
        break;
      case _InviteStatus.rejected:
        label = 'Rechazó';
        bg = Colors.red.shade50;
        fg = Colors.red.shade700;
        break;
      case _InviteStatus.undecided:
        label = 'Pendiente';
        bg = Colors.grey.shade100;
        fg = Colors.grey.shade600;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: bg == Colors.grey.shade100 ? Colors.grey.shade300 : Colors.transparent),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

enum _InviteStatus { going, rejected, undecided }

class _Invite {
  final String name;
  final _InviteStatus status;
  const _Invite(this.name, this.status);
}
