import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import '../configs/env.dart';

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
        body: json.encode({'correo': email, 'clave': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Login exitoso
        if (data['success'] == true) {
          return {'user': data['user'], 'token': data['token']};
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

  /// Registro de usuario
  Future<Map<String, dynamic>> register(
    String nombre,
    String apellido,
    String email,
    String password,
  ) async {
    try {
      final url = Uri.parse('${Env.apiUrl}/api/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'nombre': nombre,
          'apellido': apellido,
          'correo': email,
          'clave': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        return data; // Retorna éxito y datos del usuario
      } else {
        throw Exception(data['message'] ?? 'Error al registrarse');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error de conexión al registrarse');
    }
  }

  /// Login con Google
  Future<Map<String, dynamic>> loginWithGoogle() async {
    try {
      // ✅ Google Sign-In v6 permite configuración explícita
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '249558996091-n22q983j0fk9e8lt8p79tadm76v3h7qc.apps.googleusercontent.com',
        scopes: ['email', 'profile'],
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Inicio de sesión con Google cancelado');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No se pudo obtener el token de Google');
      }

      final url = Uri.parse('${Env.apiUrl}/api/auth/google');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'idToken': idToken}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return {'user': data['user'], 'token': data['token']};
      } else {
        throw Exception(data['message'] ?? 'Error en login con Google');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error al iniciar sesión con Google');
    }
  }
}
