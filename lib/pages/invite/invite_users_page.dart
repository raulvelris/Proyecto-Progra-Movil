import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InviteUsersPage extends StatefulWidget {
  const InviteUsersPage({super.key});

  @override
  State<InviteUsersPage> createState() => _InviteUsersPageState();
}

class _InviteUsersPageState extends State<InviteUsersPage> {
  final Set<int> _selected = {};
  final _users = const [
    'Aaron Lobo',
    'Aaron Tello',
    'Aaron Pérez',
    'Beatriz Soto',
    'Carlos Ponce',
    'Diana Huerta',
  ];

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Invitar usuarios')),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final name = _users[i];
                final isSel = _selected.contains(i);
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: c.primaryContainer.withOpacity(.35),
                    child: Text(_initials(name), style: TextStyle(color: c.primary)),
                  ),
                  title: Text(name),
                  trailing: Icon(
                    isSel ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: isSel ? c.primary : c.outline,
                  ),
                  onTap: () {
                    setState(() {
                      if (isSel) {
                        _selected.remove(i);
                      } else {
                        _selected.add(i);
                      }
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            onPressed: () {
              if (_selected.isEmpty) {
                Get.snackbar('Invitar usuarios', 'Selecciona al menos una persona');
              } else {
                final names = _selected.map((i) => _users[i]).join(', ');
                Get.snackbar('Invitación enviada', names, snackPosition: SnackPosition.BOTTOM);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: c.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Enviar Invitación'),
          ),
        ),
      ),
    );
  }

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first[0] : '';
    final b = parts.length > 1 ? parts.last[0] : '';
    return (a + b).toUpperCase();
  }
}
