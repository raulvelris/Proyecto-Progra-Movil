import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/event.dart';
import '../../services/session_service.dart';
import '../../services/edit_event_service.dart';
import '../../services/event_details_service.dart';
import '../../services/event_coordinates_service.dart';
import '../../configs/env.dart';

class EditEventController extends GetxController {
  final Event eventToEdit;

  EditEventController({required this.eventToEdit});

  // Variables observables
  final RxBool isLoading = true.obs;
  final RxString imagePath = ''.obs; // URL o path local
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
  final RxDouble latitude = 0.0.obs;
  final RxDouble longitude = 0.0.obs;
  final RxBool isImageChanged = false.obs;

  // Controladores de texto
  final TextEditingController locationController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  final List<String> eventTypes = [
    'Selecciona el tipo de evento',
    'Público',
    'Privado',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeValues();
  }

  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    locationController.dispose();
    super.onClose();
  }

  Future<void> _initializeValues() async {
    isLoading.value = true;
    try {
      // Cargar datos frescos del backend
      final detailsService = EventDetailsService();
      final coordinatesService = EventCoordinatesService();

      final freshEvent = await detailsService.getEventDetails(
        eventToEdit.eventId,
      );
      final coords = await coordinatesService.getEventCoordinates(
        eventToEdit.eventId,
      );

      if (freshEvent != null) {
        updateEventData(freshEvent);

        // Override with specific coordinates if available
        if (coords != null) {
          print('Overriding coordinates with specific service data: $coords');
          latitude.value = coords['latitude'] ?? 0.0;
          longitude.value = coords['longitude'] ?? 0.0;
        }
      } else {
        // Fallback a los datos pasados por argumento si falla la carga
        updateEventData(eventToEdit);
        if (coords != null) {
          latitude.value = coords['latitude'] ?? 0.0;
          longitude.value = coords['longitude'] ?? 0.0;
        }
      }
    } catch (e) {
      print('Error loading fresh event data: $e');
      updateEventData(eventToEdit);
    } finally {
      isLoading.value = false;
    }
  }

  void updateEventData(Event event) {
    title.value = event.title;
    titleController.text = event.title;

    description.value = event.description;
    descriptionController.text = event.description;

    location.value = event.location?.address ?? '';
    locationController.text = location.value;

    // Inicializar fechas
    startDate.value = event.startDate;
    startTime.value = event.startDate;
    endDate.value = event.endDate;
    endTime.value = event.endDate;

    // Inicializar tipo
    eventType.value = event.privacy == 0 ? 'Privado' : 'Público';

    // Inicializar imagen
    imagePath.value = event.image;
    imageBytes.value = null; // Resetear bytes al cargar nuevo evento
    isImageChanged.value = false;

    // Inicializar coordenadas
    if (event.location != null) {
      latitude.value = event.location!.latitude;
      longitude.value = event.location!.longitude;

      // Si las coordenadas son 0.0 (inválidas), usar default (Lima)
      if (latitude.value == 0.0 && longitude.value == 0.0) {
        latitude.value = -12.0464;
        longitude.value = -77.0428;
      }
    } else {
      // Default Lima
      latitude.value = -12.0464;
      longitude.value = -77.0428;
    }

    // Resetear paso
    currentStep.value = 0;
  }

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

  String get nextButtonText {
    switch (currentStep.value) {
      case 0:
        return 'Siguiente: Editar detalles';
      case 1:
        return 'Siguiente: Vista Previa';
      case 2:
        return 'Guardar Cambios';
      default:
        return 'Siguiente';
    }
  }

  void nextStep() {
    if (currentStep.value < 2 && canMoveNext) {
      currentStep.value++;
    } else if (currentStep.value == 2) {
      updateEvent();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  Future<void> updateEvent() async {
    try {
      final session = SessionService();
      final token = session.userToken;

      if (token == null) {
        Get.snackbar(
          'Error',
          'No hay sesión activa',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Construir fechas completas
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

      // Preparar body para el servicio
      // Nota: El backend espera 'capacity', pero no lo estamos editando en este flujo
      // Usamos el valor original o un default de 10 si no existe
      // También aseguramos que lat/lng sean números válidos
      print(
        'Updating event with lat: ${latitude.value}, lng: ${longitude.value}',
      );

      // Safety check for coordinates
      if (latitude.value == 0.0 && longitude.value == 0.0) {
        print('Coordinates are 0.0, using default Lima coordinates');
        latitude.value = -12.0464;
        longitude.value = -77.0428;
      }

      final Map<String, dynamic> body = {
        'name': title.value,
        'date': startDateTime.toIso8601String(),
        'endDate': endDateTime.toIso8601String(),
        'description': description.value,
        'privacy': privacyString,
        'capacity':
            100, // Valor por defecto o tomar del evento original si estuviera disponible en el modelo detallado
        'locationAddress': location.value,
        'lat': latitude.value,
        'lng': longitude.value,
      };

      // Solo enviar imagen si cambió
      if (isImageChanged.value && imageBytes.value != null) {
        final base64Image = base64Encode(imageBytes.value!);
        body['imageUrl'] = 'data:image/jpeg;base64,$base64Image';
      } else {
        // Si no cambió, enviamos la URL original para que el backend sepa que no es vacía
        // Ojo: El backend valida "Image cannot be empty" si se envía el campo.
        // Si el backend requiere el campo siempre, enviamos la actual.
        body['imageUrl'] = imagePath.value;
      }

      // Llamar al servicio
      final editService = EditEventService();
      await editService.updateEvent(eventToEdit.eventId, body);

      // Navegar a Home en la pestaña de eventos creados y mostrar snackbar verde arriba
      Get.offAllNamed('/home', arguments: {'tabIndex': 0});
      Get.snackbar(
        'Éxito',
        'Evento actualizado correctamente',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } catch (e) {
      print('Error actualizando evento: $e');
      Get.snackbar(
        'Error',
        'No se pudo actualizar el evento: ${e.toString().replaceAll("Exception: ", "")}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
