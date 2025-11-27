import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event.dart';
import '../models/location.dart';
import '../configs/env.dart';
import 'session_service.dart';

class PublicEventsService {
  final SessionService _sessionService = SessionService();

  /// Obtiene la lista de eventos públicos desde el backend
  Future<List<Event>> getPublicEvents() async {
    try {
      final url = '${Env.apiUrl}/api/events/public';
      print('[PublicEventsService] Iniciando petición a: $url');
      
      final token = _sessionService.userToken;
      
      print('[PublicEventsService] Token: ${token != null ? "presente" : "ausente"}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print('[PublicEventsService] Status code: ${response.statusCode}');
      print('[PublicEventsService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        print('[PublicEventsService] Success: ${data['success']}');
        print('[PublicEventsService] Eventos count: ${data['eventos']?.length ?? 0}');
        
        if (data['success'] == true && data['eventos'] != null) {
          final List<dynamic> eventosJson = data['eventos'];
          
          final events = eventosJson.map((eventJson) {
            print('[PublicEventsService] Procesando evento: ${eventJson['name']}');
            return Event(
              eventId: eventJson['id'] ?? 0,
              title: eventJson['name'] ?? 'Sin título',
              description: eventJson['description'] ?? '',
              startDate: eventJson['dateStart'] != null
                  ? DateTime.parse(eventJson['dateStart']).toLocal()
                  : DateTime.now(),
              endDate: eventJson['dateEnd'] != null
                  ? DateTime.parse(eventJson['dateEnd']).toLocal()
                  : DateTime.now(),
              image: eventJson['imageUrl'] ?? '',
              eventStatus: 1,
              privacy: 1,
              location: Location(
                locationId: 0,
                address: eventJson['location'] ?? 'Sin ubicación',
                latitude: 0,
                longitude: 0,
                eventId: eventJson['id'] ?? 0,
              ),
              resources: [],
              isAttending: false,
            );
          }).toList();
          
          print('[PublicEventsService] Eventos procesados: ${events.length}');
          return events;
        }
      }

      // Si falla, retornar lista vacía
      print('[PublicEventsService] Retornando lista vacía');
      return [];
    } catch (e, stackTrace) {
      print('[PublicEventsService] Error al obtener eventos públicos: $e');
      print('[PublicEventsService] Stack trace: $stackTrace');
      return [];
    }
  }
}
