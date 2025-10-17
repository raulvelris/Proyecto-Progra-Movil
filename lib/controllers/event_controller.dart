import 'package:get/get.dart';
import '../models/event.dart';
import '../services/event_service.dart';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class EventController extends GetxController {
  final EventService _service = Get.find<EventService>();

  final RxList<Event> publicEvents = <Event>[].obs;
  final RxList<Event> attendedEvents = <Event>[].obs;
  final Rxn<Event> selected = Rxn<Event>();

  bool _seeded = false;

  /// Carga la lista mock solo una vez.
  Future<void> ensureSeeded() async {
    if (_seeded) return;
    final list = await _service.getPublicEvents();
    publicEvents
      ..clear()
      ..addAll(list);
    attendedEvents.clear();
    _seeded = true;
  }

  bool isAttending(Event e) =>
      attendedEvents.any((x) => x.eventId == e.eventId);

  /// Confirmar asistencia: mueve sin duplicar.
  void confirm(int eventId) {
    final idx = publicEvents.indexWhere((e) => e.eventId == eventId);
    if (idx == -1) return;
    final e = publicEvents.removeAt(idx);
    if (!attendedEvents.any((x) => x.eventId == e.eventId)) {
      attendedEvents.add(e.copyWith(isAttending: true));
    }
  }

  /// Cancelar asistencia: regresa a públicos sin duplicar.
  void cancel(int eventId) {
    attendedEvents.removeWhere((e) => e.eventId == eventId);
    if (!publicEvents.any((e) => e.eventId == eventId)) {
      final base = _service.findById(eventId);
      if (base != null) publicEvents.add(base);
    }
  }

  /// Seleccionar para la pantalla de detalle.
  void selectById(int eventId) {
    final e = attendedEvents.firstWhereOrNull((x) => x.eventId == eventId) ??
        publicEvents.firstWhereOrNull((x) => x.eventId == eventId) ??
        _service.findById(eventId);
    selected.value = e;
  }

  Future<void> openPdf(String url, String name) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      await _downloadAndOpenPdf(url, name);
    } catch (e) {
      _closeLoading();
      Get.snackbar(
        'Error',
        'No se pudo abrir el PDF: $e',
        backgroundColor: Theme.of(Get.context!).colorScheme.errorContainer,
        colorText: Theme.of(Get.context!).colorScheme.onErrorContainer,
      );
    }
  }

  void _closeLoading() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }

  Future<void> _downloadAndOpenPdf(String url, String name) async {
    try {
      if (url.isEmpty || !url.startsWith('http')) {
        throw Exception('URL del PDF no válida');
      }

      print('Descargando PDF desde: $url');
      
      final response = await http.get(Uri.parse(url));
      final bytes = response.bodyBytes;

      if (response.statusCode != 200) {
        throw Exception('Error al descargar el PDF: Código ${response.statusCode}');
      }

      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/${_sanitizeFileName(name)}.pdf');
      
      print('Guardando PDF en: ${file.path}');
      await file.writeAsBytes(bytes);

      _closeLoading();

      await _openPdfFile(file, name);
      
    } catch (e) {
      _closeLoading();
      print('Error descargando PDF: $e');
      rethrow;
    }
  }

  String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[^\w\s-]'), '').replaceAll(RegExp(r'[-\s]+'), '_');
  }

  Future<void> _openPdfFile(File file, String name) async {
    try {
      if (file.existsSync()) {
        print('Abriendo PDF: ${file.path}');
        
        final result = await OpenFile.open(file.path);
        
        if (result.type == ResultType.done) {
          print('PDF abierto exitosamente');
        } else {
          await _offerDownload(file, name);
        }
      } else {
        throw Exception('El archivo PDF no existe');
      }
    } catch (e) {
      print('Error abriendo archivo: $e');
      await _offerDownload(file, name);
    }
  }

  Future<void> _offerDownload(File file, String name) async {
    final result = await Get.defaultDialog(
      title: 'PDF listo',
      middleText: 'El PDF "$name" se ha descargado. ¿Quieres guardarlo en tu dispositivo?',
      textConfirm: 'Guardar',
      textCancel: 'Cancelar',
      confirmTextColor: Theme.of(Get.context!).colorScheme.onPrimary,
      onConfirm: () async {
        Get.back(result: true);
      },
      onCancel: () {
        Get.back(result: false);
      },
    );

    if (result == true) {
      await _saveToDownloads(file, name);
    }
  }

  Future<void> _saveToDownloads(File file, String name) async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        final downloadsDirectory = await getExternalStorageDirectory();
        if (downloadsDirectory != null) {
          final downloadsPath = '${downloadsDirectory.path}/Download';
          final downloadsDir = Directory(downloadsPath);
          if (!await downloadsDir.exists()) {
            await downloadsDir.create(recursive: true);
          }
          
          final destinationFile = File('${downloadsDir.path}/${_sanitizeFileName(name)}.pdf');
          await file.copy(destinationFile.path);
          
          Get.snackbar(
            'Descarga exitosa',
            'PDF guardado en: Descargas',
            backgroundColor: Theme.of(Get.context!).colorScheme.primaryContainer,
            colorText: Theme.of(Get.context!).colorScheme.onPrimaryContainer,
            duration: const Duration(seconds: 4),
          );
          
          print('PDF guardado en: ${destinationFile.path}');
        } else {
          throw Exception('No se pudo acceder al directorio de descargas');
        }
      } else {
        throw Exception('Se necesitan permisos de almacenamiento para guardar el PDF');
      }
    } catch (e) {
      print('Error guardando en Downloads: $e');
      Get.snackbar(
        'PDF listo',
        'El PDF está disponible temporalmente en la aplicación',
        backgroundColor: Theme.of(Get.context!).colorScheme.surfaceContainerHighest,
        colorText: Theme.of(Get.context!).colorScheme.onSurfaceVariant,
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> openVideo(String url) async {
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      String formattedUrl = url.trim();
      
      print('Intentando abrir video: $formattedUrl');
      
      if (formattedUrl.contains('youtube.com/embed/')) {
        final videoId = formattedUrl.split('youtube.com/embed/').last.split('?').first;
        formattedUrl = 'https://www.youtube.com/watch?v=$videoId';
      }
      else if (formattedUrl.contains('youtu.be/')) {
        final videoId = formattedUrl.split('youtu.be/').last.split('?').first;
        formattedUrl = 'https://www.youtube.com/watch?v=$videoId';
      }
      
      final uri = Uri.parse(formattedUrl);
      
      _closeLoading();

      try {
        final uri = Uri.parse(formattedUrl);
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        return;
      } catch (e) {
        print('Error abriendo video: $e');
        await _showVideoErrorDialog(formattedUrl);
      }
    } catch (e) {
      _closeLoading();
      print('Error general abriendo video: $e');
      await _showVideoErrorDialog(url);
    }
  }

  Future<void> _showVideoErrorDialog(String url) async {
    final colorScheme = Theme.of(Get.context!).colorScheme;

    await Get.dialog(
      Dialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 64, color: colorScheme.error),
              const SizedBox(height: 16),
              Text(
                'No se pudo abrir el video',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  'Esto puede deberse a:\n\n• Falta de aplicación compatible\n• Problemas de conexión\n• Enlace no válido',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
