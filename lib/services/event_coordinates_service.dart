import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import 'session_service.dart';

class EventCoordinatesService {
  final SessionService _sessionService = SessionService();

  /// Obtiene las coordenadas de un evento específico
  Future<Map<String, double>?> getEventCoordinates(int eventId) async {
    try {
      final url = '${Env.apiUrl}/api/event/coordinates/$eventId';
      print('[EventCoordinatesService] Iniciando petición a: $url');
      
      final token = _sessionService.userToken;
      print('[EventCoordinatesService] Token: ${token != null ? "presente" : "ausente"}');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      );

      print('[EventCoordinatesService] Status code: ${response.statusCode}');
      print('[EventCoordinatesService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['success'] == true && data['coordenadas'] != null) {
          final coords = data['coordenadas'];
          print('[EventCoordinatesService] Coordenadas obtenidas: lat=${coords['latitud']}, lng=${coords['longitud']}');
          
          return {
            'latitude': coords['latitud']?.toDouble() ?? 0.0,
            'longitude': coords['longitud']?.toDouble() ?? 0.0,
          };
        }
      }

      print('[EventCoordinatesService] Coordenadas no encontradas o error en respuesta');
      return null;
    } catch (e, stackTrace) {
      print('[EventCoordinatesService] Error al obtener coordenadas: $e');
      print('[EventCoordinatesService] Stack trace: $stackTrace');
      return null;
    }
  }
}
