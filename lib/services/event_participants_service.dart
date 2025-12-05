import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import 'session_service.dart';

class Participant {
  final int participanteId;
  final int usuarioId;
  final String nombre;
  final String apellido;
  final String correo;
  final String rol;

  Participant({
    required this.participanteId,
    required this.usuarioId,
    required this.nombre,
    required this.apellido,
    required this.correo,
    required this.rol,
  });

  factory Participant.fromJson(Map<String, dynamic> json) {
    return Participant(
      participanteId: json['participante_id'] ?? 0,
      usuarioId: json['usuario_id'] ?? 0,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? '',
    );
  }
}

class EventParticipantsService {
  final SessionService _sessionService = SessionService();

  /// Obtiene los participantes de un evento específico
  Future<List<Participant>> getEventParticipants(int eventId) async {
    try {
      final url = '${Env.apiUrl}/api/eventos/$eventId/participantes';
      print('[EventParticipantsService] Iniciando petición a: $url');
      
      final token = _sessionService.userToken;

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print('[EventParticipantsService] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['participantes'] != null) {
          final List<dynamic> participantesJson = data['participantes'];
          
          final participants = participantesJson.map((p) => Participant.fromJson(p)).toList();
          print('[EventParticipantsService] Participantes obtenidos: ${participants.length}');
          return participants;
        }
      }

      print('[EventParticipantsService] No se pudieron obtener participantes');
      return [];
    } catch (e, stackTrace) {
      print('[EventParticipantsService] Error al obtener participantes: $e');
      print('[EventParticipantsService] Stack trace: $stackTrace');
      return [];
    }
  }

  /// Verifica si el usuario actual es el organizador del evento
  Future<bool> isUserOrganizer(int eventId) async {
    try {
      final userId = _sessionService.userId;
      if (userId == null) {
        print('[EventParticipantsService] Usuario no autenticado');
        return false;
      }

      final participants = await getEventParticipants(eventId);
      
      // Buscar si el usuario actual es organizador
      final organizer = participants.firstWhere(
        (p) => p.rol.toLowerCase() == 'organizador' && p.usuarioId.toString() == userId,
        orElse: () => Participant(
          participanteId: 0,
          usuarioId: 0,
          nombre: '',
          apellido: '',
          correo: '',
          rol: '',
        ),
      );

      final isOrganizer = organizer.participanteId != 0;
      print('[EventParticipantsService] ¿Es organizador? $isOrganizer');
      return isOrganizer;
    } catch (e) {
      print('[EventParticipantsService] Error verificando organizador: $e');
      return false;
    }
  }

  /// Elimina un participante del evento
  Future<Map<String, dynamic>> deleteParticipant(int eventId, int userId) async {
    try {
      final url = '${Env.apiUrl}/api/eventos/$eventId/participantes/$userId/eliminar';
      print('[EventParticipantsService] Eliminando participante: $url');
      
      final token = _sessionService.userToken;

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print('[EventParticipantsService] Status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print('[EventParticipantsService] Respuesta: $data');
        return data;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        print('[EventParticipantsService] Error: $errorData');
        return errorData;
      }
    } catch (e, stackTrace) {
      print('[EventParticipantsService] Error al eliminar participante: $e');
      print('[EventParticipantsService] Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'Error al eliminar participante: $e'
      };
    }
  }
}
