import '/models/location.dart';
import '/models/resource.dart';
import '../models/event.dart';

class EventService {
  static const String baseUrl = 'https://tu-api.com/api';

  Future<Event> getEventById(int eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    final events = await _getMockEvents();
    final event = events.firstWhere(
      (e) => e.eventId == eventId,
      orElse: () => _createDefaultEvent(),
    );
    
    return event;
  }

  Future<List<Event>> getPublicEvents() async {
    await Future.delayed(const Duration(seconds: 1));
    return await _getMockEvents();
  }

  Future<List<Event>> getCreatedEvents() async {
    await Future.delayed(const Duration(seconds: 1));
    final allEvents = await _getMockEvents();
    return allEvents.where((event) => event.eventId % 2 == 0).toList();
  }

  Future<List<Event>> getAttendedEvents() async {
    await Future.delayed(const Duration(seconds: 1));
    final allEvents = await _getMockEvents();
    return allEvents.where((event) => event.isAttending).toList();
  }

  Future<bool> confirmAttendance(int eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<bool> cancelAttendance(int eventId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  Future<List<Event>> _getMockEvents() async {
    return [
      Event(
        eventId: 1,
        title: 'Baile de los Brainrots',
        description: '¡Por primera vez en Perú y como parte de su gira en Latinoamérica, llega el espectacular CONCIERTO OFICIAL EN ESPAÑOL de los BRAINROTS ITALIANOS! Llega a UMA para disfrutar de unas increíbles funciones por el DÍA DEL NIÑO junto a una mega producción internacional con un espectacular escenografía y grandes musicales EN VIVO! ¡Podremos conocer en vivo a Baterina Capuchina, Traialero Tralala, Tun Tun Sahur, Capuchino Asesino, y muchos más Brainrots EN DIRECTO! ¡Los esperamos en el Concierto Infantil Oficial del Día del Niño!',
        startDate: DateTime(2025, 9, 11, 20, 0),
        endDate: DateTime(2025, 9, 11, 23, 0),
        image: 'assets/images/event_brainrots.jpg',
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
            url: 'https://www.ulima.edu.pe/sites/default/files/career/files/malla_ing_sistemas_2025_1.pdf',
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
        description: 'El mejor festival de música electrónica del año',
        startDate: DateTime(2025, 10, 15, 18, 0),
        endDate: DateTime(2025, 10, 16, 6, 0),
        image: 'assets/images/event_festival.jpg',
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
        description: 'Evento sobre las últimas tendencias tecnológicas',
        startDate: DateTime(2025, 8, 20, 9, 0),
        endDate: DateTime(2025, 8, 20, 17, 0),
        image: 'assets/images/event_tech.jpg',
        eventStatus: 1,
        privacy: 1,
        location: Location(
          locationId: 3,
          address: 'Centro de Convenciones, San Isidro',
          latitude: -12.0975,
          longitude: -77.0350,
          eventId: 3,
        ),
        isAttending: true,
      ),
    ];
  }

  Event _createDefaultEvent() {
    return Event(
      eventId: 0,
      title: 'Evento no encontrado',
      description: 'El evento solicitado no está disponible',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(hours: 2)),
      image: '',
      eventStatus: 0,
      privacy: 0,
      isAttending: false,
    );
  }
}