import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    try {
      await dotenv.load(fileName: '.env');
      print('Variables de entorno cargadas correctamente');
    } catch (e) {
      print('No se pudo cargar el archivo .env: $e');
      print('Asegúrate de tener un archivo .env en la raíz del proyecto');
    }
  }

  static String get googleMapsApiKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (key.isEmpty) {
      print('GOOGLE_MAPS_API_KEY no está configurada en .env');
    }
    return key;
  }
}