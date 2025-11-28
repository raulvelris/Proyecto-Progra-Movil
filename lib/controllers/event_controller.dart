import 'package:get/get.dart'; // Para manejo de estado con GetX
import '../models/event.dart'; // Modelo de evento
import '../services/event_service.dart'; // Servicio para obtener eventos

import 'package:flutter/material.dart'; // Widgets de Flutter
import 'package:permission_handler/permission_handler.dart'; // Para permisos de almacenamiento
import 'package:url_launcher/url_launcher.dart'; // Para abrir URLs externas
import 'package:open_file/open_file.dart'; // Para abrir archivos locales
import 'package:http/http.dart' as http; // Para hacer requests HTTP
import 'dart:io'; // Manejo de archivos
import 'dart:convert'; // Para codificar/decodificar base64
import 'dart:typed_data'; // Para manejar bytes
import 'package:path_provider/path_provider.dart'; // Para obtener rutas de directorios

class EventController extends GetxController {
  final EventService _service = Get.find<EventService>(); // Servicio de eventos

  final RxList<Event> publicEvents = <Event>[].obs; // Eventos públicos
  final RxList<Event> attendedEvents = <Event>[].obs; // Eventos a los que se asiste
  final Rxn<Event> selected = Rxn<Event>(); // Evento seleccionado

  bool _seeded = false; // Indica si ya se cargaron los eventos

  // ========== MÉTODOS HELPER PARA IMÁGENES ==========

  static bool isBase64Image(String image) { 
    // Verifica si un string es una imagen en base64
    try {
      if (image.startsWith('data:image/')) return true;
      if (image.length > 100 && _isValidBase64(image)) return true;
      return false;
    } catch (_) {
      return false;
    }
  }

  static bool _isValidBase64(String str) { 
    // Valida si un string puede decodificarse como base64
    try {
      base64Decode(str);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Uint8List? getImageBytes(String image) { 
    // Devuelve los bytes de la imagen si es base64
    if (isBase64Image(image) && image.isNotEmpty) {
      try {
        return base64Decode(image);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static String? getAssetPath(String image) { 
    // Devuelve el path del asset si no es base64 ni URL
    if (!isBase64Image(image) && image.isNotEmpty && !_isUrl(image)) return image;
    return null;
  }

  static bool _isUrl(String str) { 
    // Verifica si es una URL
    return str.startsWith('http://') || str.startsWith('https://');
  }

  static String? getNetworkUrl(String image) { 
    // Devuelve la URL si es una imagen de red
    if (_isUrl(image)) return image;
    return null;
  }

  static Widget buildImage( // Crea un widget de imagen según tipo
    String image, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
    BorderRadius? borderRadius,
  }) {
    if (image.isEmpty) { // Imagen vacía, muestra icono por defecto
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(color: Colors.grey[300], borderRadius: borderRadius),
        child: Icon(Icons.event, color: Colors.grey[600]),
      );
    }

    if (isBase64Image(image) && getImageBytes(image) != null) { 
      // Imagen en base64
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.memory(getImageBytes(image)!, fit: fit, width: width, height: height, errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: borderRadius),
            child: Icon(Icons.event, color: Colors.grey[600]),
          );
        }),
      );
    }

    if (getAssetPath(image) != null) { 
      // Imagen de assets locales
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.asset(getAssetPath(image)!, fit: fit, width: width, height: height, errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: borderRadius),
            child: Icon(Icons.event, color: Colors.grey[600]),
          );
        }),
      );
    }

    if (getNetworkUrl(image) != null) { 
      // Imagen de red
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Image.network(getNetworkUrl(image)!, fit: fit, width: width, height: height, errorBuilder: (_, __, ___) {
          return Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: borderRadius),
            child: Icon(Icons.event, color: Colors.grey[600]),
          );
        }),
      );
    }

    // Fallback si no coincide ningún tipo
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: borderRadius),
      child: Icon(Icons.event, color: Colors.grey[600]),
    );
  }

  // ========== FIN MÉTODOS HELPER ==========

  Future<void> ensureSeeded() async { 
    // Carga eventos públicos si no se han cargado antes
    if (_seeded) return;
    final list = await _service.getPublicEvents();
    publicEvents..clear()..addAll(list);
    attendedEvents.clear();
    _seeded = true;
  }

  bool isAttending(Event e) => attendedEvents.any((x) => x.eventId == e.eventId); 
  // Revisa si un evento ya está siendo asistido

  void confirm(int eventId) { 
    // Confirma asistencia a un evento
    final idx = publicEvents.indexWhere((e) => e.eventId == eventId);
    if (idx == -1) return;
    final e = publicEvents.removeAt(idx);
    if (!attendedEvents.any((x) => x.eventId == e.eventId)) attendedEvents.add(e.copyWith(isAttending: true));
  }

  void cancel(int eventId) { 
    // Cancela asistencia a un evento
    attendedEvents.removeWhere((e) => e.eventId == eventId);
    if (!publicEvents.any((e) => e.eventId == eventId)) {
      final base = _service.findById(eventId);
      if (base != null) publicEvents.add(base);
    }
  }

  void selectById(int eventId) { 
    // Selecciona un evento por ID
    final e = attendedEvents.firstWhereOrNull((x) => x.eventId == eventId) ??
              publicEvents.firstWhereOrNull((x) => x.eventId == eventId) ??
              _service.findById(eventId);
    selected.value = e;
  }

  Future<void> openPdf(String url, String name) async { 
    // Abre un PDF desde URL
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      await _downloadAndOpenPdf(url, name);
    } catch (e) {
      _closeLoading();
      Get.snackbar('Error', 'No se pudo abrir el PDF: $e', backgroundColor: Theme.of(Get.context!).colorScheme.errorContainer, colorText: Theme.of(Get.context!).colorScheme.onErrorContainer);
    }
  }

  void _closeLoading() { 
    // Cierra el diálogo de carga si está abierto
    if (Get.isDialogOpen == true) Get.back();
  }

  Future<void> _downloadAndOpenPdf(String url, String name) async { 
    // Descarga el PDF y lo abre
    try {
      if (url.isEmpty || !url.startsWith('http')) throw Exception('URL del PDF no válida');
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;
      if (response.statusCode != 200) throw Exception('Error al descargar el PDF: Código ${response.statusCode}');
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${_sanitizeFileName(name)}.pdf');
      await file.writeAsBytes(bytes);
      _closeLoading();
      await _openPdfFile(file, name);
    } catch (e) {
      _closeLoading();
      rethrow;
    }
  }

  String _sanitizeFileName(String name) { 
    // Limpia caracteres inválidos para nombre de archivo
    return name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'[-\s]+'), '_');
  }

  Future<void> _openPdfFile(File file, String name) async { 
    // Intenta abrir el PDF localmente, ofrece descargar si falla
    try {
      if (file.existsSync()) {
        final result = await OpenFile.open(file.path);
        if (result.type != ResultType.done) await _offerDownload(file, name);
      } else {
        throw Exception('El archivo PDF no existe');
      }
    } catch (e) {
      await _offerDownload(file, name);
    }
  }

  Future<void> _offerDownload(File file, String name) async { 
    // Pregunta al usuario si desea guardar el PDF
    final result = await Get.defaultDialog(
      title: 'PDF listo',
      middleText: 'El PDF "$name" se ha descargado. ¿Quieres guardarlo en tu dispositivo?',
      textConfirm: 'Guardar',
      textCancel: 'Cancelar',
      confirmTextColor: Theme.of(Get.context!).colorScheme.onPrimary,
      onConfirm: () async { Get.back(result: true); },
      onCancel: () { Get.back(result: false); },
    );

    if (result == true) await _saveToDownloads(file, name);
  }

  Future<void> _saveToDownloads(File file, String name) async { 
    // Guarda el PDF en la carpeta de Descargas si hay permisos
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final downloadsDirectory = await getExternalStorageDirectory();
        if (downloadsDirectory != null) {
          final downloadsPath = '${downloadsDirectory.path}/Download';
          final downloadsDir = Directory(downloadsPath);
          if (!await downloadsDir.exists()) await downloadsDir.create(recursive: true);
          final destinationFile = File('${downloadsDir.path}/${_sanitizeFileName(name)}.pdf');
          await file.copy(destinationFile.path);
          Get.snackbar('Descarga exitosa', 'PDF guardado en: Descargas', backgroundColor: Theme.of(Get.context!).colorScheme.primaryContainer, colorText: Theme.of(Get.context!).colorScheme.onPrimaryContainer, duration: const Duration(seconds: 4));
        }
      }
    } catch (e) {
      Get.snackbar('PDF listo', 'El PDF está disponible temporalmente en la aplicación', backgroundColor: Theme.of(Get.context!).colorScheme.surfaceContainerHighest, colorText: Theme.of(Get.context!).colorScheme.onSurfaceVariant, duration: const Duration(seconds: 3));
    }
  }

  Future<void> openVideo(String url) async { 
    // Abre un video en YouTube u otra URL externa
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    try {
      String formattedUrl = url.trim();
      if (formattedUrl.contains('youtube.com/embed/')) formattedUrl = 'https://www.youtube.com/watch?v=${formattedUrl.split('youtube.com/embed/').last.split('?').first}';
      else if (formattedUrl.contains('youtu.be/')) formattedUrl = 'https://www.youtube.com/watch?v=${formattedUrl.split('youtu.be/').last.split('?').first}';
      _closeLoading();
      await launchUrl(Uri.parse(formattedUrl), mode: LaunchMode.externalApplication);
    } catch (e) {
      _closeLoading();
      await _showVideoErrorDialog(url);
    }
  }

  Future<void> _showVideoErrorDialog(String url) async { 
    // Muestra un diálogo de error si no se puede abrir el video
    final colorScheme = Theme.of(Get.context!).colorScheme;
    await Get.dialog(
      Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text('No se pudo abrir el video', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface)),
              const SizedBox(height: 12),
              Text('Esto puede deberse a:\n\n• Falta de aplicación compatible\n• Problemas de conexión\n• Enlace no válido', textAlign: TextAlign.center, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14)),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: () { Get.back(); }, style: ElevatedButton.styleFrom(backgroundColor: colorScheme.primary, foregroundColor: colorScheme.onPrimary), child: const Text('Cerrar')),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
