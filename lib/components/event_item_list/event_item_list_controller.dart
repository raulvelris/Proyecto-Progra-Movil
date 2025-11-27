import 'package:get/get.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';
import '../../services/created_events_service.dart';

class EventItemListController extends GetxController {
  late final EventService _eventService;
  late final CreatedEventsService _createdEventsService;
  final RxList<Event> events = <Event>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final String eventType;

  EventItemListController({this.eventType = 'public'}) {
    if (!Get.isRegistered<EventService>()) {
      Get.put(EventService(), permanent: true);
    }
    _eventService = Get.find<EventService>();
    
    if (!Get.isRegistered<CreatedEventsService>()) {
      Get.put(CreatedEventsService(), permanent: true);
    }
    _createdEventsService = Get.find<CreatedEventsService>();
  }

  @override
  void onInit() {
    super.onInit();
    loadEvents();
  }

  Future<void> loadEvents() async {
    try {
      isLoading.value = true;
      error.value = ''; // Limpiar errores previos
      List<Event> eventList;

      switch (eventType) {
        case 'created':
          // Usar el servicio de eventos gestionados que se conecta al backend
          eventList = await _createdEventsService.getManagedEvents();
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

  void removeEvent(Event event) {
    events.remove(event);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
