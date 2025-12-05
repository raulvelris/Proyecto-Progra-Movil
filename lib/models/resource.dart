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
      sharedFileId: json['archivo_id'],
      name: json['nombre'],
      url: json['url'],
      resourceType: json['tipo'],
      eventId: json['evento_id'],
      resourceTypeDetail: json['tipo_recurso_detalle'] != null 
          ? ResourceType.fromJson(json['tipo_recurso_detalle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'archivo_id': sharedFileId,
      'nombre': name,
      'url': url,
      'tipo': resourceType,
      'evento_id': eventId,
      'tipo_recurso_detalle': resourceTypeDetail?.toJson(),
    };
  }

  bool get isFile => resourceType == 1;
  bool get isLink => resourceType == 2;
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

  Map<String, dynamic> toJson() {
    return {
      'tipo_recurso_id': resourceTypeId,
      'nombre': name,
    };
  }
}
