import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/invitation.dart';
import '../configs/env.dart';
import 'session_service.dart';

class InvitationService extends GetxService {
  final SessionService _sessionService = SessionService();

  // Debounce timer for search
  Timer? _debounceTimer;

  /// Busca usuarios por email o nombre
  /// Retorna una lista de usuarios que coinciden con la búsqueda
  Future<List<Invitee>> searchUsers(String query) async {
    try {
      // Verificar que el usuario esté autenticado
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Si la query está vacía, retornar lista vacía
      if (query.trim().isEmpty) {
        return [];
      }

      // Construir la URL del endpoint
      final url = Uri.parse(
        '${Env.apiUrl}/api/send-invitations/search?query=${Uri.encodeComponent(query)}',
      );

      print('Searching users with query: $query');

      // Realizar la petición GET con el token de autenticación
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Search Response Status: ${response.statusCode}');
      print('Search Response Body: ${response.body}');

      // Parsear la respuesta
      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Respuesta inválida del servidor');
      }

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final List<dynamic> usuariosJson = data['usuarios'] ?? [];

          // Mapear los usuarios del backend al modelo Invitee del frontend
          return usuariosJson.map<Invitee>((userData) {
            final nombre = userData['nombre'] ?? '';
            final apellido = userData['apellido'] ?? '';
            final fullName = '$nombre $apellido'.trim();

            String? rawFoto = userData['foto_perfil'] as String?;
            String? normalizedFoto;
            if (rawFoto != null && rawFoto.isNotEmpty) {
              if (rawFoto.startsWith('http://') ||
                  rawFoto.startsWith('https://') ||
                  rawFoto.startsWith('data:')) {
                normalizedFoto = rawFoto;
              } else {
                if (rawFoto.startsWith('/')) {
                  normalizedFoto = '${Env.apiUrl}$rawFoto';
                } else {
                  normalizedFoto = '${Env.apiUrl}/$rawFoto';
                }
              }
            }

            return Invitee(
              id: userData['usuario_id'],
              name: fullName.isNotEmpty ? fullName : userData['correo'],
              email: userData['correo'] ?? '',
              photoUrl: normalizedFoto,
            );
          }).toList();
        } else {
          throw Exception(data['message'] ?? 'Error al buscar usuarios');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      print('Unexpected error in searchUsers: $e');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  /// Busca usuarios con debounce para evitar llamadas excesivas
  Future<List<Invitee>> searchUsersDebounced(
    String query, {
    Duration delay = const Duration(milliseconds: 500),
  }) async {
    // Cancelar el timer anterior si existe
    _debounceTimer?.cancel();

    // Crear un Completer para manejar el resultado
    final completer = Completer<List<Invitee>>();

    // Crear nuevo timer
    _debounceTimer = Timer(delay, () async {
      try {
        final results = await searchUsers(query);
        completer.complete(results);
      } catch (e) {
        completer.completeError(e);
      }
    });

    return completer.future;
  }

  /// Envía invitaciones a usuarios seleccionados
  Future<Map<String, dynamic>> sendInvites({
    required int eventId,
    required List<int> userIds,
  }) async {
    try {
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      final url = Uri.parse('${Env.apiUrl}/api/send-invitations/send');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'evento_id': eventId,
          'usuarios': userIds.map((id) => {'usuario_id': id}).toList(),
        }),
      );

      print('Send Invites Response Status: ${response.statusCode}');
      print('Send Invites Response Body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (data['success'] == true) {
          return {
            'success': true,
            'message': data['message'] ?? 'Invitaciones enviadas exitosamente',
          };
        } else {
          throw Exception(data['message'] ?? 'Error al enviar invitaciones');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else if (response.statusCode == 403) {
        throw Exception(
          data['message'] ?? 'No tienes permisos para enviar invitaciones',
        );
      } else {
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      print('Unexpected error in sendInvites: $e');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  /// Obtiene la lista de usuarios no elegibles para un evento
  /// Retorna un mapa con los IDs de usuarios y su tipo (participante o invitación pendiente)
  Future<Map<int, String>> getNonEligibleUsers(int eventId) async {
    try {
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      final url = Uri.parse(
        '${Env.apiUrl}/api/send-invitations/no-eligible/$eventId',
      );

      print('Getting non-eligible users for event: $eventId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Non-Eligible Response Status: ${response.statusCode}');
      print('Non-Eligible Response Body: ${response.body}');

      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Respuesta inválida del servidor');
      }

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          final List<dynamic> noElegiblesJson = data['noElegibles'] ?? [];

          // Crear un mapa de usuario_id -> tipo
          final Map<int, String> nonEligibleMap = {};
          for (var userData in noElegiblesJson) {
            final userId = userData['usuario_id'] as int;
            final tipo = userData['tipo'] as String;
            nonEligibleMap[userId] = tipo;
          }

          return nonEligibleMap;
        } else {
          throw Exception(
            data['message'] ?? 'Error al obtener usuarios no elegibles',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada. Por favor inicia sesión nuevamente.');
      } else {
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      print('Unexpected error in getNonEligibleUsers: $e');
      throw Exception('Error de conexión. Verifica tu internet.');
    }
  }

  /// Obtiene el conteo de invitaciones pendientes para un evento
  Future<Map<String, int>> getPendingInvitationsCount(int eventId) async {
    try {
      final token = _sessionService.userToken;
      if (token == null || token.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      final url = Uri.parse(
        '${Env.apiUrl}/api/send-invitations/count/$eventId',
      );

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Map<String, dynamic> data;
      try {
        data = json.decode(response.body);
      } catch (e) {
        print('Error parsing JSON: $e');
        throw Exception('Respuesta inválida del servidor');
      }

      if (response.statusCode == 200) {
        if (data['success'] == true) {
          return {
            'pendientes': data['pendientes'] as int,
            'limite': data['limite'] as int,
          };
        } else {
          throw Exception(data['message'] ?? 'Error al obtener conteo');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Sesión expirada');
      } else {
        throw Exception(data['message'] ?? 'Error del servidor');
      }
    } on Exception {
      rethrow;
    } catch (e) {
      print('Unexpected error in getPendingInvitationsCount: $e');
      throw Exception('Error de conexión');
    }
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }
}
