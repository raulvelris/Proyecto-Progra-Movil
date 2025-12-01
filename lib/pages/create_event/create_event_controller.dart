// Importaciones necesarias
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'dart:convert';

import '/models/event.dart';
import '/models/location.dart';
import '/services/session_service.dart';
import '/services/resource_service.dart';
import '/configs/env.dart';

// Controlador de creación de eventos usando GetX
class CreateEventController extends GetxController {

  // Variables observables para el formulario y el paso actual
  final RxString imagePath = ''.obs;
  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);
  final RxInt currentStep = 0.obs;
  final RxString title = ''.obs;
  final RxString eventType = ''.obs;
  final RxString description = ''.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> startTime = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(hours: 2)).obs;
  final Rx<DateTime> endTime = DateTime.now().add(const Duration(hours: 2)).obs;
  final RxString location = ''.obs;

  // Recursos agregados durante la creación del evento
  final RxList<_DraftResource> draftResources = <_DraftResource>[].obs;

  // Lista de tipos de evento
  final List<String> eventTypes = [
    'Selecciona el tipo de evento',
    'Público',
    'Privado',
  ];

  // Método para limpiar el formulario y reiniciar valores
  void clearForm() {
    imagePath.value = '';
    imageBytes.value = null;
    currentStep.value = 0;
    title.value = '';
    eventType.value = '';
    description.value = '';
    location.value = '';
    startDate.value = DateTime.now();
    startTime.value = DateTime.now();
    endDate.value = DateTime.now().add(const Duration(hours: 2));
    endTime.value = DateTime.now().add(const Duration(hours: 2));
    draftResources.clear();
  }

  // Verifica si se puede avanzar al siguiente paso
  bool get canMoveNext {
    switch (currentStep.value) {
      case 0:
        return imagePath.value.isNotEmpty;
      case 1:
        return title.value.isNotEmpty &&
            eventType.value.isNotEmpty &&
            eventType.value != eventTypes[0] &&
            description.value.isNotEmpty &&
            location.value.isNotEmpty;
      default:
        return true;
    }
  }

  // Texto del botón dependiendo del paso
  String get nextButtonText {
    switch (currentStep.value) {
      case 0:
        return 'Siguiente: Detalles';
      case 1:
        return 'Siguiente: Vista Previa';
      case 2:
        return 'Guardar';
      default:
        return 'Siguiente';
    }
  }

  // Avanza al siguiente paso o guarda el evento si es el último
  void nextStep() {
    if (currentStep.value < 2 && canMoveNext) {
      currentStep.value++;
    } else if (currentStep.value == 2) {
      saveEvent();
    }
  }

  // Retrocede al paso anterior
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Agregar un recurso temporal durante la creación del evento
  void addDraftResource({required String name, required String url, required int type}) {
    draftResources.add(_DraftResource(name: name, url: url, type: type));
  }

  // Guarda el evento usando EventService
  void saveEvent() async {
    try {
      final session = SessionService();
      final token = session.userToken;
      final userIdStr = session.userId;

      if (token == null || token.isEmpty || userIdStr == null || userIdStr.isEmpty) {
        Get.snackbar(
          'Error',
          'Debes iniciar sesión para crear eventos',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Construir fechas de inicio y fin
      final startDateTime = DateTime(
        startDate.value.year,
        startDate.value.month,
        startDate.value.day,
        startTime.value.hour,
        startTime.value.minute,
      );

      final endDateTime = DateTime(
        endDate.value.year,
        endDate.value.month,
        endDate.value.day,
        endTime.value.hour,
        endTime.value.minute,
      );

      final privacyString = eventType.value == 'Privado' ? 'private' : 'public';

      if (imageBytes.value == null || imageBytes.value!.isEmpty) {
        Get.snackbar(
          'Error',
          'Debes seleccionar una imagen para el evento',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final base64Image = base64Encode(imageBytes.value!);
      final imageUrl = 'data:image/jpeg;base64,$base64Image';

      final body = {
        'name': title.value,
        'date': startDateTime.toIso8601String(),
        'capacity': 50,
        'description': description.value,
        'privacy': privacyString,
        'ownerId': int.tryParse(userIdStr) ?? 0,
        'locationAddress': location.value,
        'imageUrl': imageUrl,
        'lat': null,
        'lng': null,
      };

      final response = await http.post(
        Uri.parse('${Env.apiUrl}/api/eventos'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      // Manejo específico para código 413 (payload demasiado grande)
      if (response.statusCode == 413) {
        Get.snackbar(
          'Error',
          'La imagen o datos enviados son demasiado pesados (código 413). Intenta con una imagen más ligera.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      Map<String, dynamic>? data;
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        }
      } catch (_) {
        data = null;
      }

      if (response.statusCode != 201 || data == null || data['success'] != true) {
        final backendMessage = (data != null && data['message'] is String && (data['message'] as String).isNotEmpty)
            ? data['message'] as String
            : 'No se pudo crear el evento. Código: ${response.statusCode}';
        Get.snackbar(
          'Error',
          backendMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final backendId = data['evento'] != null ? (data['evento']['id'] ?? 0) : 0;

      // Si se agregaron recursos durante la creación, enviarlos ahora al backend
      if (backendId is int && backendId > 0 && draftResources.isNotEmpty) {
        final resourceService = ResourceService();
        for (final r in draftResources) {
          try {
            await resourceService.shareResource(
              eventId: backendId,
              name: r.name,
              url: r.url,
              resourceType: r.type,
            );
          } catch (_) {
            // Si un recurso falla, continuamos con los demás
          }
        }
      }

      // Construir el modelo local para devolverlo a la lista creada
      final createdEvent = Event(
        eventId: backendId is int ? backendId : 0,
        title: title.value,
        description: description.value,
        startDate: startDateTime,
        endDate: endDateTime,
        image: '',
        eventStatus: 1,
        privacy: privacyString == 'private' ? 0 : 1,
        location: Location(
          locationId: 0,
          address: location.value,
          latitude: 0,
          longitude: 0,
          eventId: backendId is int ? backendId : 0,
        ),
        isAttending: false,
      );

      draftResources.clear();
      Get.back(result: createdEvent); // Cierra la página y devuelve el evento creado
    } catch (e) {
      final raw = e.toString().replaceFirst('Exception: ', '');
      final message = raw.isNotEmpty
          ? raw
          : 'No se pudo crear el evento. Verifica tu conexión e inténtalo nuevamente.';
      Get.snackbar(
        'Error',
        message,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}

class _DraftResource {
  final String name;
  final String url;
  final int type; // 1 = Archivo, 2 = Enlace

  _DraftResource({required this.name, required this.url, required this.type});
}
