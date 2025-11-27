import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../controllers/event_controller.dart';
import '../../models/event.dart';
import '../../models/resource.dart';
import '../../services/event_details_service.dart';
import '../../services/event_participants_service.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({super.key, required this.eventId});
  final int eventId;

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final EventParticipantsService _participantsService = EventParticipantsService();
  bool _isOrganizer = false;
  bool _isCheckingOrganizer = true;

  @override
  void initState() {
    super.initState();
    _checkIfOrganizer();
  }

  Future<void> _checkIfOrganizer() async {
    final isOrg = await _participantsService.isUserOrganizer(widget.eventId);
    setState(() {
      _isOrganizer = isOrg;
      _isCheckingOrganizer = false;
    });
  }

  Future<Event?> _getEvent() async {
    final eventDetailsService = EventDetailsService();
    
    // Intentar obtener del backend primero
    final event = await eventDetailsService.getEventDetails(widget.eventId);
    
    if (event != null) {
      return event;
    }
    
    // Si falla el backend, intentar obtener de los datos locales (fallback)
    final controller = Get.find<EventController>();
    await controller.ensureSeeded();

    final all = <Event>[];
    all.addAll(controller.publicEvents);
    all.addAll(controller.attendedEvents);
    
    try {
      return all.firstWhere((e) => e.eventId == widget.eventId);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EventController>();

    return FutureBuilder<Event?>(
      future: _getEvent(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Detalle de evento', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: const Center(child: CircularProgressIndicator(color: Colors.black)),
          );
        }

        final e = snapshot.data;

        if (e == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text('Detalle de evento', style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: const Center(child: Text('Evento no encontrado')),
          );
        }

        final isAttending = controller.isAttending(e);

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(
              e.title,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: Get.back,
            ),
          ),
          body: ListView(
            padding: EdgeInsets.zero,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: Colors.grey.shade200),
                    EventController.buildImage(
                      e.image,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text('Datos básicos',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18)),
                    const SizedBox(height: 16),
                    _InfoRow(icon: Icons.calendar_today_rounded, text: _fmtDate(e.startDate)),
                    _InfoRow(
                        icon: Icons.access_time_rounded,
                        text: '${_fmtTime(e.startDate)} – ${_fmtTime(e.endDate)}'),
                    _InfoRow(icon: Icons.location_on_outlined, text: e.location?.address ?? '—'),
                    const SizedBox(height: 24),

                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
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
                    const SizedBox(height: 24),

                    const Text('Descripción',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(e.description, style: TextStyle(color: Colors.grey.shade700, fontSize: 15, height: 1.5)),
                    const SizedBox(height: 24),

                    // Mostrar solo si el usuario es el organizador del evento
                    if (_isOrganizer && !_isCheckingOrganizer) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _RoundedAction(
                              icon: Icons.list_alt_rounded,
                              label: 'Lista invitados',
                              onTap: () => Get.toNamed('/invite-list',
                                  arguments: {'eventId': e.eventId}),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _RoundedAction(
                              icon: Icons.person_add_outlined,
                              label: 'Invitar usuarios',
                              onTap: () => Get.toNamed('/invite-users',
                                  arguments: {'eventId': e.eventId}),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    if(e.resources.isNotEmpty) ...[
                      // Recursos (mock)
                      const Text('Recursos',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                              fontSize: 18)),
                      const SizedBox(height: 12),
                      ...e.resources.map((resource) => _buildResourceItem(resource)).toList(),
                    ]
                  ]
                )
              )
            ]
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isAttending ? Colors.red.shade50 : Colors.black,
                  foregroundColor: isAttending ? Colors.red : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isAttending ? BorderSide(color: Colors.red.shade100) : BorderSide.none,
                  ),
                ),
                onPressed: () {
                  if (isAttending) {
                    controller.cancel(e.eventId);
                  } else {
                    controller.confirm(e.eventId);
                  }
                },
                child: Text(
                  isAttending ? 'Cancelar Asistencia' : 'Confirmar Asistencia',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: Colors.black),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
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
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.black, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildResourceItem(Resource resource) {
  final controller = Get.find<EventController>();

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: resource.isPDF ? Colors.red.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          resource.isPDF ? Icons.picture_as_pdf_rounded : Icons.video_library_rounded,
          color: resource.isPDF ? Colors.red : Colors.blue,
          size: 20,
        ),
      ),
      title: Text(resource.name, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(resource.isPDF ? 'Documento PDF' : 'Enlace de video', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey.shade400),
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
