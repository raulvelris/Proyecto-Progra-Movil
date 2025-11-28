import '../models/event.dart';
import 'public_events_service.dart';
import 'created_events_service.dart';
import 'attended_events_service.dart';
import 'create_event_service.dart';

/// Servicio fachada para manejar eventos
/// Delega a servicios especializados que conectan con el backend
/// 
/// NOTA: Este servicio actúa como capa de compatibilidad para código existente
/// Se recomienda usar directamente los servicios especializados en código nuevo:
/// - CreateEventService para crear eventos
/// - PublicEventsService para eventos públicos
/// - CreatedEventsService para eventos gestionados
/// - AttendedEventsService para eventos asistidos
class EventService {
  // Servicios especializados
  final PublicEventsService _publicEventsService = PublicEventsService();
  final CreatedEventsService _createdEventsService = CreatedEventsService();
  final AttendedEventsService _attendedEventsService = AttendedEventsService();
  final CreateEventService _createEventService = CreateEventService();

  /// Obtener eventos públicos desde el backend
  Future<List<Event>> getPublicEvents() async {
    return await _publicEventsService.getPublicEvents();
  }

  /// Obtener eventos creados/gestionados por el usuario desde el backend
  Future<List<Event>> getCreatedEvents() async {
    return await _createdEventsService.getManagedEvents();
  }

  /// Obtener eventos a los que el usuario asiste desde el backend
  Future<List<Event>> getAttendedEvents() async {
    return await _attendedEventsService.getAttendedEvents();
  }

  /// Crear un nuevo evento en el backend
  Future<Event> createEvent(Event event) async {
    return await _createEventService.createEvent(event);
  }

  /// Buscar un evento por ID
  /// NOTA: Este método es una búsqueda local simple y puede no reflejar
  /// el estado actual del backend. Para obtener detalles actualizados,
  /// usa EventDetailsService directamente.
  Event? findById(int id) {
    // Este método ya no tiene sentido sin memoria local
    // Se mantiene solo por compatibilidad pero retorna null
    // Los controllers deberían usar EventDetailsService directamente
    return null;
  }

  /// Obtener un evento por su ID
  /// NOTA: Este método está deprecated, usa EventDetailsService.getEventDetails() directamente
  @Deprecated('Use EventDetailsService.getEventDetails() instead')
  Future<Event> getEventById(int eventId) async {
    // Por compatibilidad, intentamos buscarlo en eventos creados o públicos
    try {
      final created = await getCreatedEvents();
      final found = created.where((e) => e.eventId == eventId).firstOrNull;
      if (found != null) return found;

      final public = await getPublicEvents();
      final foundPublic = public.where((e) => e.eventId == eventId).firstOrNull;
      if (foundPublic != null) return foundPublic;

      // Si no se encuentra, retorna un evento por defecto
      return _createDefaultEvent();
    } catch (e) {
      return _createDefaultEvent();
    }
  }

  /// Eliminar un evento creado
  /// NOTA: Este método está deprecated, usa DeleteEventService directamente
  @Deprecated('Use DeleteEventService.deleteEvent() instead')
  Future<bool> deleteCreatedEvent(int eventId) async {
    throw UnimplementedError(
      'Use DeleteEventService.deleteEvent() instead',
    );
  }

  /// Crear un evento por defecto cuando no se encuentra uno real
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
      isAttending: false,
    );
  }
}
