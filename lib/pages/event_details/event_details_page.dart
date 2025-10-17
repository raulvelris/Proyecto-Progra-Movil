import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../controllers/event_controller.dart';
import '../../models/event.dart';
import '../../models/resource.dart';
import '../../services/event_service.dart';

class EventDetailsPage extends StatelessWidget {
  const EventDetailsPage({super.key, required this.eventId});
  final int eventId;

  Future<Event?> _getEvent() async {
    final controller = Get.find<EventController>();
    await controller.ensureSeeded();

    final all = <Event>[];
    all.addAll(controller.publicEvents);
    all.addAll(controller.attendedEvents);
    try {
      return all.firstWhere((e) => e.eventId == eventId);
    } catch (_) {
      // Si no encuentra en las listas del controlador, busca directamente en el servicio
      try {
        return await Get.find<EventService>().getEventById(eventId);
      } catch (_) {
        return null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();
    final color = Theme.of(context).colorScheme;

    return FutureBuilder<Event?>(
      future: _getEvent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detalle de evento')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final e = snapshot.data;

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
            padding: EdgeInsets.zero,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(color: color.primaryContainer),
                      if (e.image.isNotEmpty)
                        Image.asset(
                          e.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Icon(Icons.event, size: 60, color: color.onPrimaryContainer),
                            );
                          },
                        )
                      else
                        Center(
                          child: Icon(Icons.event, size: 60, color: color.onPrimaryContainer),
                        ),
                    ],
                  )
                ),
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

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

                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: color.surfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: color.outline.withOpacity(.2)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              e.location!.latitude,
                              e.location!.longitude,
                            ),
                            zoom: 15,
                          ),
                            markers: {
                              Marker(
                                markerId: const MarkerId('event_location'),
                                position: LatLng(
                                  e.location!.latitude,
                                  e.location!.longitude,
                                ),
                                infoWindow: InfoWindow(
                                  title: e.title,
                                  snippet: e.location!.address,
                                ),
                              ),
                            },
                            myLocationEnabled: true,
                            myLocationButtonEnabled: true,
                            zoomControlsEnabled: true,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    Text('Descripción',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: color.onSurface,
                            fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(e.description, style: TextStyle(color: color.onSurface)),
                    const SizedBox(height: 16),

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

                    if(e.resources.isNotEmpty) ...[
                      // Recursos (mock)
                      Text('Recursos',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: color.onSurface,
                              fontSize: 16)),
                      const SizedBox(height: 8),
                      ...e.resources.map((resource) => _buildResourceItem(resource, color)).toList(),
                    ]
                  ]
                )
              )
            ]
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
            Text(
              label,
              style: TextStyle(color: c.primary, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildResourceItem(Resource resource, ColorScheme colorScheme) {
  final controller = Get.find<EventController>();

  return Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: Icon(
        resource.isPDF ? Icons.picture_as_pdf : Icons.video_library,
        color: resource.isPDF ? colorScheme.error : colorScheme.primary,
      ),
      title: Text(resource.name),
      subtitle: Text(resource.isPDF ? 'Documento PDF' : 'Enlace de video'),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface),
      onTap: () {
        if (resource.isPDF) {
          controller.openPdf(resource.url, resource.name);
        } else {
          controller.openVideo(resource.url);
        }
      },
    ),
  );
}
