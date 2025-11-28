import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import '../services/session_service.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final _sessionService = SessionService();

  /// Obtiene el perfil del usuario autenticado
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final token = _sessionService.userToken;
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final url = Uri.parse('${Env.apiUrl}/api/profile');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return data['user'];
        } else {
          throw Exception(data['message'] ?? 'Error desconocido');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  /// Actualiza el perfil del usuario
  Future<Map<String, dynamic>> updateProfile({
    String? nombre,
    String? apellido,
    String? correo,
    String? fotoPerfil,
  }) async {
    try {
      final token = _sessionService.userToken;
      if (token == null) {
        throw Exception('No hay sesión activa');
      }

      final url = Uri.parse('${Env.apiUrl}/api/profile');
      
      final body = <String, dynamic>{};
      if (nombre != null) body['nombre'] = nombre;
      if (apellido != null) body['apellido'] = apellido;
      if (correo != null) body['correo'] = correo;
      if (fotoPerfil != null) body['foto_perfil'] = fotoPerfil;

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return data['user'];
        } else {
          throw Exception(data['message'] ?? 'Error desconocido');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 409) {
        throw Exception(data['message'] ?? 'El correo ya está registrado');
      } else if (response.statusCode == 400) {
        throw Exception(data['message'] ?? 'Datos inválidos');
      } else if (response.statusCode == 413) {
        throw Exception(data['message'] ?? 'La imagen es muy grande');
      } else {
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }
}
