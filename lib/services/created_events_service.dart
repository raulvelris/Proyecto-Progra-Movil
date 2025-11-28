import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import '../models/event.dart';
import 'session_service.dart';

/// Servicio para manejar eventos creados/gestionados por el usuario
/// Conecta con el endpoint /api/events/managed del backend
class CreatedEventsService {
  static final CreatedEventsService _instance = CreatedEventsService._internal();
  factory CreatedEventsService() => _instance;
  CreatedEventsService._internal();

  final SessionService _sessionService = SessionService();

  /// Obtiene la lista de eventos gestionados por el usuario autenticado
  /// Retorna una lista de eventos o lanza una excepción si falla
  Future<List<Event>> getManagedEvents() async {
    try {
      // Verificar que el usuario esté autenticado
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Construir la URL del endpoint
      final url = Uri.parse('${Env.apiUrl}/api/events/managed');

      // Realizar la petición GET con el token de autenticación
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Parsear la respuesta
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Petición exitosa
        if (data['success'] == true) {
          final List<dynamic> eventosJson = data['eventos'] ?? [];
          
          // Mapear los eventos del backend al modelo Event del frontend
          return eventosJson.map<Event>((eventoData) {
            return Event(
              eventId: _parseId(eventoData['id']),
              title: eventoData['name'] ?? '',
              startDate: DateTime.parse(eventoData['dateStart']),
              endDate: DateTime.parse(eventoData['dateEnd']),
              image: eventoData['imageUrl'] ?? '',
            );
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Error al obtener eventos');
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
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  /// Parsea el ID que puede venir como number o string desde el backend
  int _parseId(dynamic id) {
    if (id is int) return id;
    if (id is String) return int.tryParse(id) ?? 0;
    return 0;
  }

  /// Refresca la lista de eventos gestionados
  /// Es un alias de getManagedEvents para mantener consistencia con otros servicios
  Future<List<Event>> refreshManagedEvents() async {
    return await getManagedEvents();
  }
}
