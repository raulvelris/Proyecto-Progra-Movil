import 'package:get/get.dart';
import '../../models/event.dart';

class EventItemController extends GetxController {
  final Event event;

  EventItemController({required this.event});

  void onEventTap() {
    Get.toNamed(
      '/event-details',
      arguments: {'eventId': event.eventId},
    );
  }

  String formatDate(DateTime date) {
    const List<String> months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Set', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}