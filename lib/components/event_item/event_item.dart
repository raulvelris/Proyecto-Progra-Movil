import 'package:flutter/material.dart';
import 'event_item_controller.dart';
import '../../models/event.dart';

class EventItem extends StatelessWidget {
  final Event event;
  final EventItemController controller;

  EventItem({super.key, required this.event})
      : controller = EventItemController(event: event);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: colorScheme.primaryContainer,
          ),
          child: event.image.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    event.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.event, color: colorScheme.onPrimaryContainer);
                    },
                  ),
                )
              : Icon(Icons.event, color: colorScheme.onPrimaryContainer),
        ),
        title: Text(
          event.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${controller.formatDate(event.startDate)} • ${controller.formatTime(event.startDate)}',
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
            if (event.location != null)
              Text(
                event.location!.address,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface),
        onTap: controller.onEventTap,
      ),
    );
  }
}