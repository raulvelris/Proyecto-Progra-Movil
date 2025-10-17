class Resource {
  final int sharedFileId;
  final String name;
  final String url; // Carta PDF, trailer, etc.
  final int resourceType; // 1:pdf 2:video ...
  final int eventId;

  Resource({
    required this.sharedFileId,
    required this.name,
    required this.url,
    required this.resourceType,
    required this.eventId,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      sharedFileId: json['archivo_id'],
      name: json['nombre'],
      url: json['url'],
      resourceType: json['tipo'],
      eventId: json['evento_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'archivo_id': sharedFileId,
      'nombre': name,
      'url': url,
      'tipo': resourceType,
      'evento_id': eventId,
    };
  }
}

class ResourceType {
  final int resourceTypeId;
  final String name;

  ResourceType({required this.resourceTypeId, required this.name});

  factory ResourceType.fromJson(Map<String, dynamic> json) {
    return ResourceType(
      resourceTypeId: json['tipo_recurso_id'],
      name: json['nombre'],
    );
  }
}
