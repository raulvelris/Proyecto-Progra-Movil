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
    final c = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de invitados')),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _data.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) {
          final item = _data[i];
          final badge = _statusBadge(item.status, c);
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: c.primaryContainer.withOpacity(.35),
              child: Text(_initials(item.name), style: TextStyle(color: c.primary)),
            ),
            title: Text(item.name),
            trailing: badge,
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

  static Widget _statusBadge(_InviteStatus s, ColorScheme c) {
    late final String label;
    late final Color bg, fg;

    switch (s) {
      case _InviteStatus.going:
        label = 'Asistirá';
        bg = Colors.green.withOpacity(.15);
        fg = Colors.green.shade800;
        break;
      case _InviteStatus.rejected:
        label = 'Rechazó';
        bg = Colors.red.withOpacity(.15);
        fg = Colors.red.shade800;
        break;
      case _InviteStatus.undecided:
        label = 'Sin decidir';
        bg = c.outlineVariant.withOpacity(.25);
        fg = c.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}

enum _InviteStatus { going, rejected, undecided }

class _Invite {
  final String name;
  final _InviteStatus status;
  const _Invite(this.name, this.status);
}
