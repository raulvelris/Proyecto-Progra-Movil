import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../controllers/event_controller.dart';
import '../../models/event.dart';
import '../../models/resource.dart';
import '../../services/event_details_service.dart';
import '../../services/event_participants_service.dart';
import '../../services/event_coordinates_service.dart';
import '../../services/resource_service.dart';
import '../add_resource/add_resource_flow.dart';

class EventDetailsPage extends StatefulWidget {
  const EventDetailsPage({super.key, required this.eventId});
  final int eventId;

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final EventParticipantsService _participantsService =
      EventParticipantsService();
  final EventCoordinatesService _coordinatesService = EventCoordinatesService();
  final ResourceService _resourceService = ResourceService();
  bool _isOrganizer = false;
  bool _isCheckingOrganizer = true;
  late Future<Event?> _eventFuture;
  late Future<List<Resource>> _resourcesFuture;
  Map<String, double>? _coordinates;

  @override
  void initState() {
    super.initState();
    _eventFuture = _getEvent();
    _resourcesFuture = _loadResources();
    _checkIfOrganizer();
    _loadCoordinates();
  }

  Future<void> _checkIfOrganizer() async {
    final isOrg = await _participantsService.isUserOrganizer(widget.eventId);
    setState(() {
      _isOrganizer = isOrg;
      _isCheckingOrganizer = false;
    });
  }

  Future<void> _loadCoordinates() async {
    final coords = await _coordinatesService.getEventCoordinates(
      widget.eventId,
    );
    setState(() {
      _coordinates = coords;
    });
  }

  Future<List<Resource>> _loadResources() async {
    try {
      return await _resourceService.getResourcesByEvent(widget.eventId);
    } catch (_) {
      return [];
    }
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
      future: _eventFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Detalle de evento',
                style: TextStyle(color: Colors.black),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
            body: const Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        final e = snapshot.data;

        if (e == null) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              title: const Text(
                'Detalle de evento',
                style: TextStyle(color: Colors.black),
              ),
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
                aspectRatio: 1 / 0.8,
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
                    const Text(
                      'Datos básicos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'Inicio',
                      value:
                          '${_fmtDate(e.startDate)} - ${_fmtTime(e.startDate)}',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.event_available,
                      label: 'Fin',
                      value: '${_fmtDate(e.endDate)} - ${_fmtTime(e.endDate)}',
                    ),
                    const SizedBox(height: 8),
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Ubicación',
                      value: e.location?.address ?? '—',
                    ),
                    const SizedBox(height: 24),

                    if (_coordinates != null)
                      Column(
                        children: [
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: FlutterMap(
                                options: MapOptions(
                                  initialCenter: LatLng(
                                    _coordinates!['latitude']!,
                                    _coordinates!['longitude']!,
                                  ),
                                  initialZoom: 15,
                                  interactionOptions: const InteractionOptions(
                                    flags: InteractiveFlag.all,
                                  ),
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.eventmaster.app',
                                    maxZoom: 19,
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: LatLng(
                                          _coordinates!['latitude']!,
                                          _coordinates!['longitude']!,
                                        ),
                                        width: 40,
                                        height: 40,
                                        child: Icon(
                                          Icons.location_on,
                                          color: Colors.red.shade600,
                                          size: 40,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => controller.openInGoogleMaps(
                                _coordinates!['latitude']!,
                                _coordinates!['longitude']!,
                              ),
                              icon: const Icon(Icons.map),
                              label: const Text('Abrir en Google Maps'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                side: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.map_outlined,
                                size: 48,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Cargando mapa...',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      e.description,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),

                    if (_isOrganizer && !_isCheckingOrganizer) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _RoundedAction(
                              icon: Icons.people_outline,
                              label: 'Participantes',
                              onTap: () => Get.toNamed(
                                '/participants',
                                arguments: {
                                  'eventId': e.eventId,
                                  'eventName': e.title,
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _RoundedAction(
                              icon: Icons.person_add_outlined,
                              label: 'Invitar usuarios',
                              onTap: () => Get.toNamed(
                                '/invite-users',
                                arguments: {'eventId': e.eventId},
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],

                    FutureBuilder<List<Resource>>(
                      future: _resourcesFuture,
                      builder: (context, resourcesSnapshot) {
                        final backendResources = resourcesSnapshot.data ?? [];
                        final hasBackendResources = backendResources.isNotEmpty;
                        final hasLocalResources = e.resources.isNotEmpty;

                        if (!hasBackendResources &&
                            !hasLocalResources &&
                            !_isOrganizer) {
                          return const SizedBox.shrink();
                        }

                        final resources = hasBackendResources
                            ? backendResources
                            : e.resources;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recursos',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (_isOrganizer && !_isCheckingOrganizer)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _openAddResourceFlow(e.eventId),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Agregar recurso'),
                                ),
                              ),
                            ...resources.map(
                              (resource) => _buildResourceItem(
                                resource,
                                onDelete: _isOrganizer && !_isCheckingOrganizer
                                    ? () => _confirmDeleteResource(
                                        e.eventId,
                                        resource,
                                      )
                                    : null,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: (!_isCheckingOrganizer && _isOrganizer)
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAttending
                            ? Colors.red.shade50
                            : Colors.black,
                        foregroundColor: isAttending
                            ? Colors.red
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isAttending
                              ? BorderSide(color: Colors.red.shade100)
                              : BorderSide.none,
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
                        isAttending
                            ? 'Cancelar Asistencia'
                            : 'Confirmar Asistencia',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _openAddResourceFlow(int eventId) async {
    final result = await Get.to<AddResourceResult>(
      () => const AddResourceChoosePage(),
    );

    if (result == null) return;

    try {
      await _resourceService.shareResource(
        eventId: eventId,
        name: result.name,
        url: result.url,
        resourceType: result.type,
      );

      setState(() {
        _resourcesFuture = _loadResources();
      });

      Get.snackbar(
        'Recurso agregado',
        'El recurso se agregó correctamente',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _confirmDeleteResource(int eventId, Resource resource) async {
    final colorScheme = Theme.of(Get.context!).colorScheme;
    final result = await Get.dialog(
      Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                '¿Deseas eliminar el recurso?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      Get.back(result: true);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                      foregroundColor: colorScheme.primary,
                    ),
                    child: const Text('Eliminar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );

    if (result == true) {
      try {
        await _resourceService.deleteResource(
          eventId: eventId,
          resourceId: resource.sharedFileId,
        );

        setState(() {
          _resourcesFuture = _loadResources();
        });

        Get.snackbar(
          'Recurso eliminado',
          'El recurso se eliminó correctamente',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          'Error',
          e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  static String _two(int x) => x.toString().padLeft(2, '0');
  static String _fmtDate(DateTime d) =>
      '${_two(d.day)}/${_two(d.month)}/${d.year}';
  static String _fmtTime(DateTime d) => '${_two(d.hour)}:${_two(d.minute)}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildResourceItem(Resource resource, {VoidCallback? onDelete}) {
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
          color: resource.isFile ? Colors.red.shade50 : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          resource.isFile ? Icons.description_rounded : Icons.link_rounded,
          color: resource.isFile ? Colors.red : Colors.blue,
          size: 20,
        ),
      ),
      title: Text(
        resource.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        resource.isFile ? 'Archivo' : 'Enlace',
        style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red.shade400,
              onPressed: onDelete,
            ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
      onTap: () {
        if (resource.isFile) {
          controller.openFile(resource.url, resource.name);
        } else {
          controller.openLink(resource.url);
        }
      },
    ),
  );
}
