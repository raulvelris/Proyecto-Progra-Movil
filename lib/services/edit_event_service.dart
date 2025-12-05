import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import 'session_service.dart';

class EditEventService {
  final String _baseUrl = '${Env.apiUrl}/api/eventos/update';

  Future<Map<String, dynamic>> updateEvent(
      int eventId, Map<String, dynamic> eventData) async {
    final token = SessionService().userToken;

    if (token == null) {
      throw Exception('No hay sesión activa');
    }

    final url = Uri.parse('$_baseUrl/$eventId');

    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(eventData),
      );

      dynamic responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        print('Error decoding JSON: $e');
        print('Response body: ${response.body}');
        throw Exception('Respuesta inválida del servidor: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Error al actualizar evento');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }
}
