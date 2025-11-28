import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import 'session_service.dart';

/// Servicio para confirmar o cancelar asistencia a eventos
/// Conecta con los endpoints:
/// - /api/events/confirm-attendance (POST)
/// - /api/events/leave (POST/DELETE)
class AttendanceService {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final SessionService _sessionService = SessionService();

  /// Confirma la asistencia del usuario a un evento público
  /// Requiere autenticación JWT
  /// Retorna true si la confirmación fue exitosa, false en caso contrario
  Future<bool> confirmAttendance(int eventId) async {
    try {
      // Verificar que el usuario esté autenticado
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Construir la URL del endpoint
      final url = Uri.parse('${Env.apiUrl}/api/events/confirm-attendance');

      print('[AttendanceService] Confirming attendance to event: $eventId');

      // Realizar la petición POST con el token de autenticación
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'evento_id': eventId,
        }),
      );

      print('[AttendanceService] Confirm Status code: ${response.statusCode}');
      print('[AttendanceService] Confirm Response body: ${response.body}');

      // Parsear la respuesta
      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Confirmación exitosa
        if (data['success'] == true) {
          return true;
        } else {
          throw Exception(data['message'] ?? 'Error al confirmar asistencia');
        }
      } else if (response.statusCode == 401) {
        // No autenticado
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 400) {
        // Validación fallida (ej: ya confirmado)
        throw Exception(data['message'] ?? 'No se pudo confirmar asistencia');
      } else if (response.statusCode == 404) {
        // Evento no encontrado
        throw Exception(data['message'] ?? 'Evento no encontrado');
      } else {
        // Error del servidor
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      // Error de conexión
      print('[AttendanceService] Connection error in confirmAttendance: $e');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  /// Cancela la asistencia del usuario a un evento
  /// Requiere autenticación JWT y el middleware verifyAttendeeInEvent
  /// Retorna true si la cancelación fue exitosa, false en caso contrario
  Future<bool> leaveEvent(int eventId) async {
    try {
      // Verificar que el usuario esté autenticado
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Construir la URL del endpoint
      final url = Uri.parse('${Env.apiUrl}/api/events/leave');

      print('[AttendanceService] Leaving event: $eventId');

      // Realizar la petición POST/DELETE con el token de autenticación
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'evento_id': eventId,
        }),
      );

      print('[AttendanceService] Leave Status code: ${response.statusCode}');
      print('[AttendanceService] Leave Response body: ${response.body}');

      // Parsear la respuesta
      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Cancelación exitosa
        if (data['success'] == true) {
          return true;
        } else {
          throw Exception(data['message'] ?? 'Error al cancelar asistencia');
        }
      } else if (response.statusCode == 401) {
        // No autenticado
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        // Sin permisos (no es asistente del evento)
        throw Exception(data['message'] ?? 'No estás inscrito en este evento');
      } else if (response.statusCode == 404) {
        // Evento no encontrado
        throw Exception(data['message'] ?? 'Evento no encontrado');
      } else {
        // Error del servidor
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      // Error de conexión
      print('[AttendanceService] Connection error in leaveEvent: $e');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }
}
