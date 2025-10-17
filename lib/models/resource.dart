class Resource {
  final int sharedFileId;
  final String name;
  final String url;
  final int resourceType;
  final int eventId;
  final ResourceType? resourceTypeDetail;

  Resource({
    required this.sharedFileId,
    required this.name,
    required this.url,
    required this.resourceType,
    required this.eventId,
    this.resourceTypeDetail,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      sharedFileId: json['archivo_compartido_id'],
      name: json['nombre'],
      url: json['url'],
      resourceType: json['tipo_recurso'],
      eventId: json['evento_id'],
      resourceTypeDetail: json['tipo_recurso_detalle'] != null
          ? ResourceType.fromJson(json['tipo_recurso_detalle'])
          : null,
    );
  }

  bool get isPDF => resourceType == 1;
  bool get isVideo => resourceType == 2;
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
