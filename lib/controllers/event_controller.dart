import 'package:get/get.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventController extends GetxController {
  final EventService _service = Get.find<EventService>();

  final RxList<Event> publicEvents = <Event>[].obs;
  final RxList<Event> attendedEvents = <Event>[].obs;
  final Rxn<Event> selected = Rxn<Event>();

  bool _seeded = false;

  /// Carga la lista mock solo una vez.
  Future<void> ensureSeeded() async {
    if (_seeded) return;
    final list = await _service.getPublicEvents();
    publicEvents
      ..clear()
      ..addAll(list);
    attendedEvents.clear();
    _seeded = true;
  }

  bool isAttending(Event e) =>
      attendedEvents.any((x) => x.eventId == e.eventId);

  /// Confirmar asistencia: mueve sin duplicar.
  void confirm(int eventId) {
    final idx = publicEvents.indexWhere((e) => e.eventId == eventId);
    if (idx == -1) return;
    final e = publicEvents.removeAt(idx);
    if (!attendedEvents.any((x) => x.eventId == e.eventId)) {
      attendedEvents.add(e.copyWith(isAttending: true));
    }
  }

  /// Cancelar asistencia: regresa a públicos sin duplicar.
  void cancel(int eventId) {
    attendedEvents.removeWhere((e) => e.eventId == eventId);
    if (!publicEvents.any((e) => e.eventId == eventId)) {
      final base = _service.findById(eventId);
      if (base != null) publicEvents.add(base);
    }
  }

  /// Seleccionar para la pantalla de detalle.
  void selectById(int eventId) {
    final e =
        attendedEvents.firstWhereOrNull((x) => x.eventId == eventId) ??
        publicEvents.firstWhereOrNull((x) => x.eventId == eventId) ??
        _service.findById(eventId);
    selected.value = e;
  }
}
