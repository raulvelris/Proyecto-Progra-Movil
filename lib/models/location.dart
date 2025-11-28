class Location {
  final int locationId;
  final String address;
  final double latitude;
  final double longitude;
  final int eventId;

  Location({
    required this.locationId,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.eventId,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      locationId: json['ubicacion_id'],
      address: json['direccion'],
      latitude: (json['lat'] as num).toDouble(),
      longitude: (json['lng'] as num).toDouble(),
      eventId: json['evento_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ubicacion_id': locationId,
      'direccion': address,
      'lat': latitude,
      'lng': longitude,
      'evento_id': eventId,
    };
  }
}
