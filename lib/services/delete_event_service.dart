import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import 'session_service.dart';

/// Servicio para eliminar eventos
/// Conecta con el endpoint /api/events/delete del backend
class DeleteEventService {
  static final DeleteEventService _instance = DeleteEventService._internal();
  factory DeleteEventService() => _instance;
  DeleteEventService._internal();

  final SessionService _sessionService = SessionService();

  /// Elimina un evento por su ID
  /// Retorna true si se eliminó exitosamente, false en caso contrario
  /// Lanza una excepción con el mensaje de error si falla
  Future<Map<String, dynamic>> deleteEvent(int eventId) async {
    try {
      // Verificar que el usuario esté autenticado
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Construir la URL del endpoint
      final url = Uri.parse('${Env.apiUrl}/api/events/delete/$eventId');

      // Realizar la petición DELETE con el token de autenticación
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Log para debugging
      print('Delete Event Response Status: ${response.statusCode}');
      print('Delete Event Response Body: ${response.body}');

      // Parsear la respuesta
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        // Si no se puede parsear el JSON, asumimos error del servidor
        throw Exception('Respuesta inválida del servidor');
      }

      if (response.statusCode == 200) {
        // Petición exitosa
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Evento eliminado exitosamente',
          };
        } else {
          throw Exception(data['message'] ?? 'Error al eliminar evento');
        }
      } else if (response.statusCode == 401) {
        // No autenticado
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        // No autorizado (no es organizador)
        throw Exception(data['message'] ?? 'No tienes permisos para eliminar este evento');
      } else if (response.statusCode == 404) {
        // Evento no encontrado
        throw Exception(data['message'] ?? 'Evento no encontrado');
      } else {
        // Error del servidor
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      // Error de conexión u otro error no esperado
      print('Unexpected error in deleteEvent: $e');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }
}
