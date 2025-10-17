import 'package:get/get.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';

class EventItemListController extends GetxController {
  final EventService _eventService = EventService();
  final RxList<Event> events = <Event>[].obs;
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  final String eventType;

  EventItemListController({this.eventType = 'public'});

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
    await loadEvents();
  }

  // Agrega un evento a la lista
  void addEvent(Event event) {
    events.add(event);
  }

  // Elimina un evento de la lista
  void removeEvent(Event event) {
    events.remove(event);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
