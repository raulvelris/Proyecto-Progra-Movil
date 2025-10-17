import 'package:get/get.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';

class EventItemListController extends GetxController {
  late final EventService _eventService;
  final RxList<Event> events = <Event>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final String eventType;

  EventItemListController({this.eventType = 'public'}) {
    // Inicializa el servicio como singleton si no existe
    if (!Get.isRegistered<EventService>()) {
      Get.put(EventService(), permanent: true);
    }
    _eventService = Get.find<EventService>();
  }

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      List<Event> eventList;

      switch (eventType) {
        case 'created':
          eventList = await _eventService.getCreatedEvents();
          break;
        case 'attended':
          eventList = await _eventService.getAttendedEvents();
          break;
        case 'public':
        default:
          eventList = await _eventService.getPublicEvents();
          break;
      }

      events.assignAll(eventList);
    } catch (e) {
      error.value = 'Error al cargar eventos: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshEvents() async {
    try {
      isLoading.value = true;
      await loadEvents();
    } catch (e) {
      error.value = 'Error al cargar eventos: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void addEvent(Event event) {
    events.add(event);
  }

  Future<void> removeEvent(Event event) async {
    try {
      final success = await _eventService.deleteCreatedEvent(event.eventId);
      if (success) {
        events.remove(event);
        await refreshEvents();
        Get.snackbar(
          'Éxito',
          'Evento eliminado correctamente',
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Error',
          'No se pudo eliminar el evento',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al eliminar el evento',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
