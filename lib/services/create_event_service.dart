import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import '../models/event.dart';
import 'session_service.dart';

/// Servicio para crear eventos en el backend
/// Conecta con el endpoint /api/events/create del backend
class CreateEventService {
  static final CreateEventService _instance = CreateEventService._internal();
  factory CreateEventService() => _instance;
  CreateEventService._internal();

  final SessionService _sessionService = SessionService();

  /// Crea un nuevo evento en el backend
  /// Requiere autenticación JWT
  /// Retorna el evento creado con su ID del backend o lanza una excepción si falla
  Future<Event> createEvent(Event event) async {
    try {
      // Verificar que el usuario esté autenticado
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Construir la URL del endpoint
      final url = Uri.parse('${Env.apiUrl}/api/events/create');

      // Preparar el body del request
      final body = {
        'name': event.title,
        'description': event.description,
        'dateStart': event.startDate.toUtc().toIso8601String(),
        'dateEnd': event.endDate.toUtc().toIso8601String(),
        'location': event.location?.address ?? '',
        'privacy': event.privacy, // 0 = privado, 1 = público
        'imageUrl': event.image, // URL o base64
      };

      print('[CreateEventService] Creating event: ${event.title}');
      print('[CreateEventService] URL: $url');

      // Realizar la petición POST con el token de autenticación
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      print('[CreateEventService] Status code: ${response.statusCode}');
      print('[CreateEventService] Response body: ${response.body}');

      // Parsear la respuesta
      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Evento creado exitosamente
        if (data['success'] == true && data['evento'] != null) {
          final eventoData = data['evento'];
          
          // Retornar el evento con el ID asignado por el backend
          return event.copyWith(
            eventId: eventoData['evento_id'] ?? eventoData['id'],
            image: eventoData['imagen'] ?? eventoData['imageUrl'] ?? event.image,
          );
        } else {
          throw Exception(data['message'] ?? 'Error al crear evento');
        }
      } else if (response.statusCode == 401) {
        // No autenticado o token expirado
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 400) {
        // Validación fallida
        throw Exception(data['message'] ?? 'Datos del evento inválidos');
      } else if (response.statusCode == 403) {
        // Sin permisos
        throw Exception(data['message'] ?? 'No tienes permisos para crear eventos');
      } else {
        // Error del servidor
        throw Exception(data['message'] ?? 'Error del servidor al crear evento');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      // Error de conexión
      print('[CreateEventService] Connection error: $e');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }
}
