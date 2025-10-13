import '/models/location.dart';
import '/models/resource.dart';

class Event {
  final int eventId;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String image;
  final int eventStatus;
  final int privacy;
  final Location? location;
  final List<Resource> resources;
  final bool isAttending;

  Event({
    required this.eventId,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.image,
    required this.eventStatus,
    required this.privacy,
    this.location,
    this.resources = const [],
    this.isAttending = false,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      eventId: json['evento_id'],
      title: json['titulo'],
      description: json['descripcion'],
      startDate: DateTime.parse(json['fechaInicio']),
      endDate: DateTime.parse(json['fechaFin']),
      image: json['imagen'],
      eventStatus: json['estado_evento'],
      privacy: json['privacidad'],
      location: json['ubicacion'] != null ? Location.fromJson(json['ubicacion']) : null,
      resources: json['recursos'] != null 
          ? (json['recursos'] as List).map((r) => Resource.fromJson(r)).toList()
          : [],
      isAttending: json['isAsistido'] ?? false,
    );
  }
}