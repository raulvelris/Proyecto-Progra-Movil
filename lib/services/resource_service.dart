import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../configs/env.dart';
import '../models/resource.dart';
import 'session_service.dart';

class ResourceService {
  final SessionService _sessionService = SessionService();
  final Logger _logger = Logger();

  Future<List<Resource>> getResourcesByEvent(int eventId, {int? resourceType}) async {
    final token = _sessionService.userToken;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa');
    }

    final queryParameters = <String, String>{};
    if (resourceType != null) {
      queryParameters['tipo_recurso'] = resourceType.toString();
    }

    Uri uri = Uri.parse('${Env.apiUrl}/api/visualizar-recursos/evento/$eventId');
    if (queryParameters.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    try {
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['recursos'] is List) {
          final List<dynamic> items = data['recursos'];
          return items.map<Resource>((item) {
            final tipo = item['tipo'];
            final evento = item['evento'];
            final resourceTypeId = tipo != null ? (tipo['tipo_recurso_id'] ?? 1) : 1;

            return Resource(
              sharedFileId: item['recurso_id'] ?? 0,
              name: item['nombre'] ?? '',
              url: item['url'] ?? '',
              resourceType: resourceTypeId,
              eventId: evento != null ? (evento['evento_id'] ?? eventId) : eventId,
              resourceTypeDetail: tipo != null
                  ? ResourceType(
                      resourceTypeId: tipo['tipo_recurso_id'] ?? resourceTypeId,
                      name: tipo['nombre'] ?? '',
                    )
                  : null,
            );
          }).toList();
        }
      }

      return [];
    } catch (e, stack) {
      _logger.e(
        'Error fetching resources for event $eventId',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<Resource> shareResource({
    required int eventId,
    required String name,
    required String url,
    required int resourceType,
  }) async {
    final token = _sessionService.userToken;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa');
    }

    final uri = Uri.parse('${Env.apiUrl}/api/compartir-recursos');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'evento_id': eventId,
          'nombre': name,
          'url': url,
          'tipo_recurso': resourceType,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true && data['recurso'] != null) {
        final recurso = data['recurso'];
        final tipo = recurso['tipo'];
        final evento = recurso['evento'];

        final resourceTypeId =
            tipo != null ? (tipo['tipo_recurso_id'] ?? resourceType) : resourceType;

        return Resource(
          sharedFileId: recurso['recurso_id'] ?? 0,
          name: recurso['nombre'] ?? name,
          url: recurso['url'] ?? url,
          resourceType: resourceTypeId,
          eventId: evento != null ? (evento['evento_id'] ?? eventId) : eventId,
          resourceTypeDetail: tipo != null
              ? ResourceType(
                  resourceTypeId: tipo['tipo_recurso_id'] ?? resourceTypeId,
                  name: tipo['nombre'] ?? '',
                )
              : null,
        );
      }

      final message = data['message'] ?? 'No se pudo compartir el recurso';
      throw Exception(message);
    } catch (e, stack) {
      _logger.e(
        'Error sharing resource for event $eventId',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }

  Future<bool> deleteResource({
    required int eventId,
    required int resourceId,
  }) async {
    final token = _sessionService.userToken;
    if (token == null || token.isEmpty) {
      throw Exception('No hay sesión activa');
    }

    final uri = Uri.parse('${Env.apiUrl}/api/eliminar-recursos');

    try {
      final response = await http.delete(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'evento_id': eventId,
          'recurso_id': resourceId,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return true;
      }

      final message = data['message'] ?? 'No se pudo eliminar el recurso';
      throw Exception(message);
    } catch (e, stack) {
      _logger.e(
        'Error deleting resource $resourceId for event $eventId',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }
  }
}
