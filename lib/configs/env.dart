import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static Future<void> load() async {
    if (!dotenv.isInitialized) {
      try {
        await dotenv.load(fileName: '.env');
        debugPrint('ENV cargado desde asset (.env)');
      } catch (e) {
        debugPrint('ENV no cargado: $e');
      }
    }
  }

  static String get apiUrl {
    final url = dotenv.env['API_URL'] ?? 'http://localhost:5000';
    if (url.isEmpty) debugPrint('API_URL vacío');
    return url;
  }
}
