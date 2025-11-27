import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/location.dart';
import '../models/resource.dart';
import '../configs/env.dart';
import 'session_service.dart';

class EventDetailsService {
  final SessionService _sessionService = SessionService();

  /// Obtiene los detalles de un evento específico desde el backend
  Future<Event?> getEventDetails(int eventId) async {
    try {
      final url = '${Env.apiUrl}/api/eventos/$eventId';
      print('[EventDetailsService] Iniciando petición a: $url');
      
      final token = _sessionService.userToken;
      print('[EventDetailsService] Token: ${token != null ? "presente" : "ausente"}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print('[EventDetailsService] Status code: ${response.statusCode}');
      print('[EventDetailsService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['evento'] != null) {
          final eventoJson = data['evento'];
          print('[EventDetailsService] Procesando evento: ${eventoJson['titulo']}');
          
          return Event(
            eventId: eventoJson['evento_id'] ?? 0,
            title: eventoJson['titulo'] ?? 'Sin título',
            description: eventoJson['descripcion'] ?? '',
            startDate: eventoJson['fechaInicio'] != null
                ? DateTime.parse(eventoJson['fechaInicio']).toLocal()
                : DateTime.now(),
            endDate: eventoJson['fechaFin'] != null
                ? DateTime.parse(eventoJson['fechaFin']).toLocal()
                : DateTime.now(),
            image: eventoJson['imagen'] ?? '',
            eventStatus: eventoJson['estadoEvento'] ?? 1,
            privacy: eventoJson['privacidad'] ?? 1,
            location: eventoJson['ubicacion'] != null
                ? Location(
                    locationId: 0,
                    address: eventoJson['ubicacion']['direccion'] ?? 'Sin ubicación',
                    latitude: eventoJson['ubicacion']['latitud']?.toDouble() ?? 0.0,
                    longitude: eventoJson['ubicacion']['longitud']?.toDouble() ?? 0.0,
                    eventId: eventoJson['evento_id'] ?? 0,
                  )
                : Location(
                    locationId: 0,
                    address: 'Sin ubicación',
                    latitude: 0,
                    longitude: 0,
                    eventId: eventoJson['evento_id'] ?? 0,
                  ),
            resources: eventoJson['recursos'] != null
                ? (eventoJson['recursos'] as List).map((recurso) {
                    return Resource(
                      sharedFileId: recurso['id'] ?? 0,
                      name: recurso['nombre'] ?? '',
                      url: recurso['url'] ?? '',
                      resourceType: recurso['tipo'] ?? 1,
                      eventId: eventoJson['evento_id'] ?? 0,
                    );
                  }).toList()
                : [],
            isAttending: false,
          );
        }
      }

      print('[EventDetailsService] Evento no encontrado o error en respuesta');
      return null;
    } catch (e, stackTrace) {
      print('[EventDetailsService] Error al obtener detalles del evento: $e');
      print('[EventDetailsService] Stack trace: $stackTrace');
      return null;
    }
  }
}
