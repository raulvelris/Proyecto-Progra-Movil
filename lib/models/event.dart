import 'location.dart';
import 'resource.dart';

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
    this.description = '',
    required this.startDate,
    required this.endDate,
    required this.image,
    this.eventStatus = 0,
    this.privacy = 0,
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
      location: json['ubicacion'] != null
          ? Location.fromJson(json['ubicacion'])
          : null,
      resources: json['recursos'] != null
          ? (json['recursos'] as List).map((r) => Resource.fromJson(r)).toList()
          : [],
      isAttending: json['isAsistido'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'evento_id': eventId,
      'titulo': title,
      'descripcion': description,
      'fechaInicio': startDate.toIso8601String(),
      'fechaFin': endDate.toIso8601String(),
      'imagen': image,
      'estado_evento': eventStatus,
      'privacidad': privacy,
      'ubicacion': location?.toJson(),
      'recursos': resources.isNotEmpty
          ? resources.map((r) => r.toJson()).toList()
          : [],
      'isAsistido': isAttending,
    };
  }

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
