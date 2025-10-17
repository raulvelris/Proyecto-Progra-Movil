class GeneralNotification {
  final int notificacionId;
  final String mensaje;

  GeneralNotification({
    required this.notificacionId,
    required this.mensaje,
  });

  factory GeneralNotification.fromJson(Map<String, dynamic> json) {
    return GeneralNotification(
      notificacionId: json['notificacion_id'],
      mensaje: json['mensaje'],
    );
  }
}
