import 'package:get/get.dart';
import '/models/event.dart';
import '/models/location.dart';
import 'dart:typed_data';

class CreateEventController extends GetxController {
  // Paso 1: Personaliza (Imagen)
  final RxString imagePath = ''.obs;
  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);

  // Paso 2: Detalla
  final RxInt currentStep = 0.obs;
  final RxString title = ''.obs;
  final RxString eventType = ''.obs;
  final RxString description = ''.obs;
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> startTime = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(hours: 2)).obs;
  final Rx<DateTime> endTime = DateTime.now().add(const Duration(hours: 2)).obs;
  final RxString location = ''.obs;

  // Lista de tipos de eventos disponibles
  final List<String> eventTypes = [
    'Selecciona el tipo de evento',
    'Público',
    'Privado',
  ];

  @override
  void onInit() {
    super.onInit();
    startDate.listen((newStartDate) {
      if (endDate.value.isBefore(newStartDate)) {
        endDate.value = DateTime(
          newStartDate.year,
          newStartDate.month,
          newStartDate.day,
          endTime.value.hour,
          endTime.value.minute,
        );
      }
    });
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
      case 2:
        return true;
      default:
        return false;
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

  void saveEvent() {
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
      privacy: 0,
      location: Location(
        locationId: 0,
        address: location.value,
        latitude: 0,
        longitude: 0,
        eventId: 0,
      ),
      isAttending: true,
    );
    Get.back(result: event);
  }
}
