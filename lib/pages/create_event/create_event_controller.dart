// Importaciones necesarias
import 'package:get/get.dart';
import '/models/event.dart';
import '/models/location.dart';
import 'dart:typed_data';
import 'dart:convert';
import '/services/event_service.dart';

// Controlador de creación de eventos usando GetX
class CreateEventController extends GetxController {
  // Servicio para manejar eventos
  late final EventService _eventService;

  // Constructor: asegura que EventService esté registrado y lo asigna
  CreateEventController() {
    if (!Get.isRegistered<EventService>()) {
      Get.put(EventService(), permanent: true);
    }
    _eventService = Get.find<EventService>();
  }

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
        return 'Siguiente: Detalla';
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

  // Guarda el evento usando EventService
  void saveEvent() async {
    try {
      // Convertir imagen a base64 si existe
      String base64Image = '';
      if (imageBytes.value != null) {
        base64Image = base64Encode(imageBytes.value!);
      }

      final event = Event(
        eventId: 0,
        title: title.value,
        description: description.value,
        startDate: DateTime(
          startDate.value.year,
          startDate.value.month,
          startDate.value.day,
          startTime.value.hour,
          startTime.value.minute,
        ),
        endDate: DateTime(
          endDate.value.year,
          endDate.value.month,
          endDate.value.day,
          endTime.value.hour,
          endTime.value.minute,
        ),
        image: base64Image,
        eventStatus: 1,
        privacy: eventType.value == 'Privado' ? 0 : 1,
        location: Location(
          locationId: 0,
          address: location.value,
          latitude: 0,
          longitude: 0,
          eventId: 0,
        ),
        isAttending: true,
      );

      final createdEvent = await _eventService.createEvent(event);
      Get.back(result: createdEvent); // Cierra la página y devuelve el evento creado
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el evento',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
