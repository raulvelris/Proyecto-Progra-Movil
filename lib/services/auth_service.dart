import 'dart:convert';
import 'package:http/http.dart' as http;
import '../configs/env.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Login con email y contraseña
  /// Retorna un mapa con 'user' y 'token' si es exitoso
  /// Lanza una excepción con el mensaje de error si falla
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final url = Uri.parse('${Env.apiUrl}/api/auth/login');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'correo': email,
          'clave': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Login exitoso
        if (data['success'] == true) {
          return {
            'user': data['user'],
            'token': data['token'],
          };
        } else {
          throw Exception(data['message'] ?? 'Error desconocido');
        }
      } else if (response.statusCode == 400) {
        // Error de validación
        throw Exception(data['message'] ?? 'Datos inválidos');
      } else if (response.statusCode == 401) {
        // Credenciales inválidas
        throw Exception(data['message'] ?? 'Credenciales inválidas');
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
}
