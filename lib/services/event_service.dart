import 'dart:async';
import '../models/event.dart';
import '../models/location.dart';
import '../models/resource.dart';

/// Servicio “mock” que expone SIEMPRE la misma lista base.
/// No muta estado; el estado vivo lo lleva el controlador.
class EventService {
  // Lista maestra de ejemplo
  static final List<Event> _all = <Event>[
    Event(
      eventId: 1,
      title: 'Baile de los Brainrots',
      description:
          '¡Show oficial en español! Música en vivo, luces, y sorpresas para toda la familia.',
      startDate: DateTime(2025, 9, 11, 20, 0),
      endDate: DateTime(2025, 9, 11, 23, 0),
      image:
          'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?q=80&w=1400&auto=format&fit=crop',
      eventStatus: 1,
      privacy: 1,
      location: Location(
        locationId: 1,
        address: 'Av de los Precursores 125-127, San Miguel 15088',
        latitude: -12.0775,
        longitude: -77.0930,
        eventId: 1,
      ),
      resources: [
        Resource(
          sharedFileId: 1,
          name: 'Agenda',
          url:
              'https://www.ulima.edu.pe/sites/default/files/career/files/malla_ing_sistemas_2025_1.pdf',
          resourceType: 1,
          eventId: 1,
        ),
        Resource(
          sharedFileId: 2,
          name: 'Trailer',
          url: 'https://www.youtube.com/watch?v=-MKFIecXRys',
          resourceType: 2,
          eventId: 1,
        ),
      ],
      isAttending: false,
    ),
    Event(
      eventId: 2,
      title: 'Festival de Música Electrónica',
      description: 'El mejor festival de música electrónica del año.',
      startDate: DateTime(2025, 10, 15, 18, 0),
      endDate: DateTime(2025, 10, 16, 6, 0),
      image:
          'https://images.unsplash.com/photo-1506157786151-b8491531f063?q=80&w=1400&auto=format&fit=crop',
      eventStatus: 1,
      privacy: 1,
      location: Location(
        locationId: 2,
        address: 'Costa Verde, Miraflores',
        latitude: -12.1260,
        longitude: -77.0300,
        eventId: 2,
      ),
      isAttending: false,
    ),
    Event(
      eventId: 3,
      title: 'Conferencia de Tecnología',
      description:
          'Charlas sobre IA, nube y buenas prácticas. Networking con cafecito y stickers.',
      startDate: DateTime(2025, 8, 20, 9, 0),
      endDate: DateTime(2025, 8, 20, 17, 0),
      image:
          'https://images.unsplash.com/photo-1517245386807-bb43f82c33c4?q=80&w=1400&auto=format&fit=crop',
      eventStatus: 1,
      privacy: 1,
      location: Location(
        locationId: 3,
        address: 'Centro de Convenciones, San Isidro',
        latitude: -12.0975,
        longitude: -77.0350,
        eventId: 3,
      ),
      isAttending: false,
    ),
  ];

  Future<List<Event>> getPublicEvents() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Copia nueva para evitar aliasing
    return _all.map((e) => e.copyWith()).toList();
  }

  /// Útil para el controlador cuando necesita rehacer un evento por id.
  Event? findById(int id) {
    try {
      return _all.firstWhere((e) => e.eventId == id).copyWith();
    } catch (_) {
      return null;
    }
  }

  // Stubs para compatibilidad con otros archivos
  Future<List<Event>> getCreatedEvents() async => <Event>[];
  Future<List<Event>> getAttendedEvents() async => <Event>[];
}
