import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event.dart';
import '../models/location.dart';
import '../models/resource.dart';

class EventService {
  static const String _createdEventsKey = 'created_events_list';

  List<Event> _all = [];
  List<Event> _createdEvents = [];

  Future<void> _ensureInitialized() async {
    if (_all.isEmpty) {
      _all = await _getMockEvents();
      await _loadCreatedEventsFromStorage();
      _all.addAll(_createdEvents);
    }
  }

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
      _createdEvents = [];
    }
  }

  Future<void> _saveCreatedEventsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = json.encode(
        _createdEvents.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(_createdEventsKey, eventsJson);
    } catch (_) {}
  }

  Future<Event> getEventById(int eventId) async {
    await _ensureInitialized();
    return _all.firstWhere(
      (e) => e.eventId == eventId,
      orElse: () => _createDefaultEvent(),
    );
  }

  Future<List<Event>> getPublicEvents() async {
    await _ensureInitialized();
    return _all.where((event) => event.eventId < 1000).toList();
  }

  Future<List<Event>> getCreatedEvents() async {
    await _ensureInitialized();
    return _all.where((event) => event.eventId >= 1000).toList();
  }

  Future<List<Event>> getAttendedEvents() async {
    await _ensureInitialized();
    return _all
        .where((event) => event.isAttending && event.eventId < 1000)
        .toList();
  }

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

  Event? findById(int id) {
    try {
      return _all.firstWhere((e) => e.eventId == id);
    } catch (_) {
      return null;
    }
  }

  Future<Event> createEvent(Event event) async {
    await _ensureInitialized();
    final newId = _getNextCreatedEventId();
    final newEvent = event.copyWith(eventId: newId);
    _createdEvents.add(newEvent);
    _all.add(newEvent);
    await _saveCreatedEventsToStorage();
    return newEvent;
  }

  Future<bool> deleteCreatedEvent(int eventId) async {
    await _ensureInitialized();
    if (eventId < 1000) return false;

    final initialLength = _createdEvents.length;
    _createdEvents.removeWhere((e) => e.eventId == eventId);
    _all.removeWhere((e) => e.eventId == eventId);

    final wasRemoved = _createdEvents.length < initialLength;
    if (wasRemoved) await _saveCreatedEventsToStorage();

    return wasRemoved;
  }

  int _getNextCreatedEventId() {
    if (_createdEvents.isEmpty) return 1000;
    return _createdEvents
            .map((e) => e.eventId)
            .reduce((a, b) => a > b ? a : b) +
        1;
  }

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
