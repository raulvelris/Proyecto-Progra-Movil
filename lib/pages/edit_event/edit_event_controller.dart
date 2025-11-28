import 'dart:typed_data';
import 'package:get/get.dart';
import '/models/event.dart';
import '/models/location.dart';

class EditEventController extends GetxController {
  // Evento original (requerido)
  late final Event original;

  // Estado observable (prefill con el evento)
  final RxString title = ''.obs;
  final RxString description = ''.obs;
  final RxString locationText = ''.obs;

  /// 0 = Público, 1 = Privado (alineado al modelo Event.privacy)
  final RxInt privacy = 0.obs;

  /// Imagen: mantenemos la URL original, y opcionalmente bytes si el usuario la cambia localmente
  final RxString imageUrl = ''.obs;
  final Rx<Uint8List?> imageBytes = Rx<Uint8List?>(null);

  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().obs;

  final List<String> eventTypes = const ['Público', 'Privado'];

  @override
  void onInit() {
    super.onInit();
    // Cargamos el evento de los argumentos: Get.toNamed('/edit-event', arguments: {'event': e});
    final args = Get.arguments ?? {};
    final ev = args['event'] as Event?;
    if (ev == null) {
      // Falla segura: si no llega, no podemos editar
      Get.back();
      return;
    }
    original = ev;

    // Prefill
    title.value = ev.title;
    description.value = ev.description;
    imageUrl.value = ev.image;
    privacy.value = ev.privacy; // 0 público / 1 privado
    startDate.value = ev.startDate;
    endDate.value = ev.endDate;
    locationText.value = ev.location?.address ?? '';
  }

  /// Cambiar privacidad desde un String de UI
  void setPrivacyFromString(String value) {
    final idx = eventTypes.indexOf(value);
    privacy.value = idx < 0 ? 0 : idx;
  }

  String get privacyAsString => eventTypes[(privacy.value.clamp(0, 1))];

  /// Validaciones simples
  String? validate() {
    if (title.value.trim().isEmpty) return 'El título es obligatorio';
    if (description.value.trim().isEmpty)
      return 'La descripción es obligatoria';
    if (endDate.value.isBefore(startDate.value)) {
      return 'La fecha/hora de fin no puede ser anterior al inicio';
    }
    return null;
  }

  /// Construir el evento actualizado. Aquí usamos copyWith del modelo.
  Event buildUpdatedEvent() {
    return original.copyWith(
      title: title.value.trim(),
      description: description.value.trim(),
      startDate: startDate.value,
      endDate: endDate.value,
      // Si tuviéramos subida real de imagen, reemplazaríamos image con la URL final.
      image: imageUrl.value,
      privacy: privacy.value,
      location: Location(
        locationId: original.location?.locationId ?? 0,
        address: locationText.value.trim(),
        latitude: original.location?.latitude ?? 0,
        longitude: original.location?.longitude ?? 0,
        eventId: original.eventId,
      ),
    );
  }

  /// Guardar: valida y devuelve el Event actualizado a la pantalla anterior
  void save() {
    final error = validate();
    if (error != null) {
      Get.snackbar('Error', error);
      return;
    }
    final updated = buildUpdatedEvent();
    Get.back(result: updated);
  }
}
