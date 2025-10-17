import 'package:get/get.dart';
import '/models/event.dart';
import '/models/location.dart';
import 'dart:typed_data';
import '/services/event_service.dart';

class CreateEventController extends GetxController {
  late final EventService _eventService;

  CreateEventController() {
    if (!Get.isRegistered<EventService>()) {
      Get.put(EventService(), permanent: true);
    }
    _eventService = Get.find<EventService>();
  }

  // Paso 1: Imagen
  final RxString imagePath = ''.obs;
  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);

  // Paso 2: Detalles
  final RxInt currentStep = 0.obs;
  final RxString title = ''.obs;
  final RxString eventType = ''.obs;
  final RxString description = ''.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> startTime = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(hours: 2)).obs;
  final Rx<DateTime> endTime = DateTime.now().add(const Duration(hours: 2)).obs;
  final RxString location = ''.obs;

  final List<String> eventTypes = [
    'Selecciona el tipo de evento',
    'Público',
    'Privado',
  ];

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
        return 'Siguiente: Detalla';
      case 1:
        return 'Siguiente: Vista Previa';
      case 2:
        return 'Guardar';
      default:
        return 'Siguiente';
    }
  }

  void nextStep() {
    if (currentStep.value < 2 && canMoveNext) {
      currentStep.value++;
    } else if (currentStep.value == 2) {
      saveEvent();
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void saveEvent() async {
    try {
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
        image: imagePath.value,
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
      Get.back(result: createdEvent);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo crear el evento',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
