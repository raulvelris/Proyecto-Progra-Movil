import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/event_controller.dart';
import '../../models/event.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key, required this.eventId});
  final int eventId;

  Event? _findEvent(EventController c) {
    final all = <Event>[];
    all.addAll(c.publicEvents);
    all.addAll(c.attendedEvents);
    try {
      return all.firstWhere((e) => e.eventId == eventId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();
    final color = Theme.of(context).colorScheme;
    final e = _findEvent(controller);

    if (e == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detalle de evento')),
        body: const Center(child: Text('Evento no encontrado')),
      );
    }

    final isAttending = controller.isAttending(e);

    return Scaffold(
      appBar: AppBar(
        title: Text(e.title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: Get.back,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Imagen (si no hay asset, mostramos un placeholder)
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              decoration: BoxDecoration(
                color: color.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                image: e.image.isNotEmpty
                    ? DecorationImage(
                        image: AssetImage(e.image),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                      )
                    : null,
              ),
              child: e.image.isEmpty
                  ? const Center(child: Icon(Icons.image, size: 48))
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // Datos básicos (fecha / hora / dirección)
          Text('Datos básicos',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color.onSurface,
                  fontSize: 16)),
          const SizedBox(height: 8),
          _InfoRow(icon: Icons.event, text: _fmtDate(e.startDate)),
          _InfoRow(
              icon: Icons.schedule,
              text: '${_fmtTime(e.startDate)} – ${_fmtTime(e.endDate)}'),
          _InfoRow(icon: Icons.place, text: e.location?.address ?? '—'),
          const SizedBox(height: 12),

          // Mapa “placeholder”
          Container(
            height: 150,
            decoration: BoxDecoration(
              color: color.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.outline.withOpacity(.2)),
            ),
            child: const Center(child: Text('Mapa')),
          ),
          const SizedBox(height: 16),

          // Descripción
          Text('Descripción',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color.onSurface,
                  fontSize: 16)),
          const SizedBox(height: 8),
          Text(e.description, style: TextStyle(color: color.onSurface)),
          const SizedBox(height: 16),

          // === Acciones debajo de la descripción ===
          Row(
            children: [
              Expanded(
                child: _RoundedAction(
                  icon: Icons.badge_outlined,
                  label: 'Lista invitados',
                  onTap: () => Get.toNamed('/invite-list',
                      arguments: {'eventId': e.eventId}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _RoundedAction(
                  icon: Icons.person_add_alt_1_outlined,
                  label: 'Invitar usuarios',
                  onTap: () => Get.toNamed('/invite-users',
                      arguments: {'eventId': e.eventId}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recursos (mock)
          Text('Recursos',
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: color.onSurface,
                  fontSize: 16)),
          const SizedBox(height: 8),
          _ResourceTile(icon: Icons.description_outlined, label: 'Agenda'),
          _ResourceTile(icon: Icons.attach_file, label: 'Trailer'),
          const SizedBox(height: 20),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isAttending ? color.error : color.primary,
              foregroundColor: color.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (isAttending) {
                controller.cancel(e.eventId);
              } else {
                controller.confirm(e.eventId);
              }
            },
            child: Text(isAttending ? 'Cancelar asistencia' : 'Confirmar Asistencia'),
          ),
        ),
      ),
    );
  }

  static String _two(int x) => x.toString().padLeft(2, '0');
  static String _fmtDate(DateTime d) => '${_two(d.day)}/${_two(d.month)}/${d.year}';
  static String _fmtTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: c.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _RoundedAction extends StatelessWidget {
  const _RoundedAction({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.outline.withOpacity(.15)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: c.primaryContainer.withOpacity(.35),
              child: Icon(icon, color: c.primary, size: 26),
            ),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: c.primary, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _ResourceTile extends StatelessWidget {
  const _ResourceTile({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.outline.withOpacity(.15)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: c.primaryContainer.withOpacity(.35),
            child: Icon(icon, color: c.primary),
          ),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: c.onSurface, fontSize: 16)),
        ],
      ),
    );
  }
}
