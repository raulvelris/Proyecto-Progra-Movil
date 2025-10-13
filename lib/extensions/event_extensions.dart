import '/models/location.dart';
import '/models/resource.dart';
import '../models/event.dart';

extension EventCopyWith on Event {
  Event copyWith({
    int? eventId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? image,
    int? eventStatus,
    int? privacy,
    Location? location,
    List<Resource>? resources,
    bool? isAttending,
  }) {
    return Event(
      eventId: eventId ?? this.eventId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      image: image ?? this.image,
      eventStatus: eventStatus ?? this.eventStatus,
      privacy: privacy ?? this.privacy,
      location: location ?? this.location,
      resources: resources ?? this.resources,
      isAttending: isAttending ?? this.isAttending,
    );
  }
}