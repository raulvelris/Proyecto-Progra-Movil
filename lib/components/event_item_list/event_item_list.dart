import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'event_item_list_controller.dart';
import '../event_item/event_item.dart';

class EventItemList extends StatelessWidget {
  final String eventType;

  const EventItemList({super.key, this.eventType = 'public'});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final EventItemListController controller = Get.put(
      EventItemListController(eventType: eventType),
      tag: 'event_list_$eventType',
    );

    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: colorScheme.primary),
              const SizedBox(height: 16),
              Text(
                'Cargando eventos...',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }

      if (controller.error.value.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                controller.error.value,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => controller.loadEvents(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        );
      }

      if (controller.events.isEmpty) {
        return _buildEmptyState(eventType, colorScheme, textTheme);
      }

      return RefreshIndicator(
        backgroundColor: colorScheme.surface,
        color: colorScheme.primary,
        onRefresh: () => controller.refreshEvents(),
        child: ListView.builder(
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            return EventItem(
              event: controller.events[index],
              isCreatedEvent: eventType == 'created',
            );
          },
        ),
      );
    });
  }

  Widget _buildEmptyState(
    String type,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    IconData icon;
    String message;

    switch (type) {
      case 'created':
        icon = Icons.event;
        message = 'No has creado eventos aún';
        break;
      case 'attended':
        icon = Icons.event_available;
        message = 'No tienes eventos confirmados';
        break;
      case 'public':
      default:
        icon = Icons.public;
        message = 'No hay eventos públicos disponibles';
        break;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: colorScheme.onSurface.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
