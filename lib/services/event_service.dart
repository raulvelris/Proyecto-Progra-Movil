import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../models/resource.dart';

// Servicio encargado de manejar eventos (mock y creados por el usuario)
class EventService {
  static const String _createdEventsKey = 'created_events_list'; // Clave para almacenamiento local

  List<Event> _all = []; // Todos los eventos (mock + creados)
  List<Event> _createdEvents = []; // Eventos creados por el usuario

  // Inicializa la lista de eventos si está vacía
  Future<void> _ensureInitialized() async {
    if (_all.isEmpty) {
      _all = await _getMockEvents(); // Cargar eventos mock
      await _loadCreatedEventsFromStorage(); // Cargar eventos creados desde SharedPreferences
      _all.addAll(_createdEvents); // Combinar ambas listas
    }
  }

  // Carga los eventos creados guardados en SharedPreferences
  Future<void> _loadCreatedEventsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_createdEventsKey);
      if (eventsJson != null && eventsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(eventsJson);
        _createdEvents = decoded.map((e) => Event.fromJson(e)).toList();
      } else {
        _createdEvents = [];
      }
    } catch (_) {
      _createdEvents = []; // Si falla la carga, lista vacía
    }
  }

  // Guarda los eventos creados en SharedPreferences
  Future<void> _saveCreatedEventsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = json.encode(
        _createdEvents.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_createdEventsKey, eventsJson);
    } catch (_) {}
  }

  // Obtener un evento por su ID
  Future<Event> getEventById(int eventId) async {
    await _ensureInitialized();
    return _all.firstWhere(
      (e) => e.eventId == eventId,
      orElse: () => _createDefaultEvent(), // Retorna evento por defecto si no existe
    );
  }

  // Obtener eventos públicos (mock con id < 1000)
  Future<List<Event>> getPublicEvents() async {
    await _ensureInitialized();
    return _all.where((event) => event.eventId < 1000).toList();
  }

  // Obtener eventos creados por el usuario (id >= 1000)
  Future<List<Event>> getCreatedEvents() async {
    await _ensureInitialized();
    return _all.where((event) => event.eventId >= 1000).toList();
  }

  // Obtener eventos públicos a los que el usuario asiste
  Future<List<Event>> getAttendedEvents() async {
    await _ensureInitialized();
    return _all
        .where((event) => event.isAttending && event.eventId < 1000)
        .toList();
  }

  // Eventos mock para pruebas
  Future<List<Event>> _getMockEvents() async {
    return [
      Event(
        eventId: 1,
        title: 'Baile de los Brainrots',
        description: '¡Por primera vez en Perú ...!',
        startDate: DateTime(2026, 9, 11, 20, 0),
        endDate: DateTime(2026, 9, 11, 23, 0),
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
  }

  // Buscar un evento por ID (retorna null si no existe)
  Event? findById(int id) {
    try {
      return _all.firstWhere((e) => e.eventId == id);
    } catch (_) {
      return null;
    }
  }

  // Crear un nuevo evento
  Future<Event> createEvent(Event event) async {
    await _ensureInitialized();
    final newId = _getNextCreatedEventId(); // Asigna un nuevo ID >=1000
    final newEvent = event.copyWith(eventId: newId);
    _createdEvents.add(newEvent);
    _all.add(newEvent);
    await _saveCreatedEventsToStorage(); // Guardar en almacenamiento local
    return newEvent;
  }

  // Eliminar un evento creado
  Future<bool> deleteCreatedEvent(int eventId) async {
    await _ensureInitialized();
    if (eventId < 1000) return false; // No se eliminan eventos públicos

    final initialLength = _createdEvents.length;
    _createdEvents.removeWhere((e) => e.eventId == eventId);
    _all.removeWhere((e) => e.eventId == eventId);

    final wasRemoved = _createdEvents.length < initialLength;
    if (wasRemoved) await _saveCreatedEventsToStorage(); // Guardar cambios

    return wasRemoved;
  }

  // Generar próximo ID para eventos creados
  int _getNextCreatedEventId() {
    if (_createdEvents.isEmpty) return 1000;
    return _createdEvents
            .map((e) => e.eventId)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

  // Crear un evento por defecto si no se encuentra uno real
  Event _createDefaultEvent() {
    return Event(
      eventId: 0,
      title: 'Evento no encontrado',
      description: '',
      startDate: DateTime.now(),
      endDate: DateTime.now(),
      image: '',
      eventStatus: 0,
      privacy: 0,
      location: Location(
        locationId: 0,
        address: '',
        latitude: 0,
        longitude: 0,
        eventId: 0,
      ),
      resources: [],
      isAttending: false,
    );
  }
}
