import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import '../models/event.dart';
import '../models/location.dart';
import 'session_service.dart';

/// Servicio para obtener eventos a los que el usuario asiste
/// Conecta con el endpoint /api/events/attended del backend
class AttendedEventsService {
  static final AttendedEventsService _instance = AttendedEventsService._internal();
  factory AttendedEventsService() => _instance;
  AttendedEventsService._internal();

  final SessionService _sessionService = SessionService();

  /// Obtiene la lista de eventos a los que el usuario asiste
  /// Requiere autenticación JWT
  /// Retorna una lista de eventos o lanza una excepción si falla
  Future<List<Event>> getAttendedEvents() async {
    try {
      // Verificar que el usuario esté autenticado
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Construir la URL del endpoint
      final url = Uri.parse('${Env.apiUrl}/api/events/attended');

      print('[AttendedEventsService] Fetching attended events from: $url');

      // Realizar la petición GET con el token de autenticación
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[AttendedEventsService] Status code: ${response.statusCode}');
      print('[AttendedEventsService] Response body: ${response.body}');

      // Parsear la respuesta
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Petición exitosa
        if (data['success'] == true) {
          final List<dynamic> eventosJson = data['eventos'] ?? [];
          
          print('[AttendedEventsService] Found ${eventosJson.length} attended events');
          
          // Mapear los eventos del backend al modelo Event del frontend
          return eventosJson.map<Event>((eventoData) {
            return Event(
              eventId: eventoData['id'] ?? eventoData['evento_id'] ?? 0,
              title: eventoData['name'] ?? eventoData['titulo'] ?? 'Sin título',
              description: eventoData['description'] ?? eventoData['descripcion'] ?? '',
              startDate: eventoData['dateStart'] != null
                  ? DateTime.parse(eventoData['dateStart']).toLocal()
                  : (eventoData['fechaInicio'] != null
                      ? DateTime.parse(eventoData['fechaInicio']).toLocal()
                      : DateTime.now()),
              endDate: eventoData['dateEnd'] != null
                  ? DateTime.parse(eventoData['dateEnd']).toLocal()
                  : (eventoData['fechaFin'] != null
                      ? DateTime.parse(eventoData['fechaFin']).toLocal()
                      : DateTime.now()),
              image: eventoData['imageUrl'] ?? eventoData['imagen'] ?? '',
              eventStatus: eventoData['eventStatus'] ?? eventoData['estadoEvento'] ?? 1,
              privacy: eventoData['privacy'] ?? eventoData['privacidad'] ?? 1,
              location: eventoData['location'] != null || eventoData['ubicacion'] != null
                  ? Location(
                      locationId: 0,
                      address: eventoData['location'] ?? eventoData['ubicacion']?['direccion'] ?? 'Sin ubicación',
                      latitude: eventoData['ubicacion']?['latitud']?.toDouble() ?? 0.0,
                      longitude: eventoData['ubicacion']?['longitud']?.toDouble() ?? 0.0,
                      eventId: eventoData['id'] ?? eventoData['evento_id'] ?? 0,
                    )
                  : Location(
                      locationId: 0,
                      address: 'Sin ubicación',
                      latitude: 0,
                      longitude: 0,
                      eventId: eventoData['id'] ?? eventoData['evento_id'] ?? 0,
                    ),
              resources: [],
              isAttending: true, // Por definición, estos son eventos a los que asiste
            );
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Error al obtener eventos asistidos');
        }
      } else if (response.statusCode == 401) {
        // No autenticado
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        // Error del servidor
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      // Error de conexión
      print('[AttendedEventsService] Connection error: $e');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  /// Refresca la lista de eventos asistidos
  /// Es un alias de getAttendedEvents para mantener consistencia con otros servicios
  Future<List<Event>> refreshAttendedEvents() async {
    return await getAttendedEvents();
  }
}
