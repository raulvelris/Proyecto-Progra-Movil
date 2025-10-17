import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '/extensions/event_extensions.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';

class EventDetailsController extends GetxController {
  final EventService _eventService = EventService();
  final Rx<Event?> event = Rx<Event?>(null);
  final RxBool isLoading = true.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadEvent();
  }

  Future<void> loadEvent() async {
    try {
      isLoading.value = true;
      final eventId = Get.arguments?['eventId'] ?? 1;
      final Event eventData = await _eventService.getEventById(eventId);
      event.value = eventData;
    } catch (e) {
      error.value = 'Error al cargar el evento: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAttendance() async {
    if (event.value == null) return;

    try {
      bool success;
      if (event.value!.isAttending) {
        success = await _eventService.cancelAttendance(event.value!.eventId);
      } else {
        success = await _eventService.confirmAttendance(event.value!.eventId);
      }

      if (success) {
        event.value = event.value!.copyWith(
          isAttending: !event.value!.isAttending,
        );
        event.refresh();
        Get.snackbar(
          'Éxito', 
          event.value!.isAttending ? 'Asistencia confirmada' : 'Asistencia cancelada'
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar la asistencia');
    }
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

  void navigateToSection(String section) {
    switch (section) {
      case 'Creados':
        Get.toNamed('/created-events');
        break;
      case 'Asistidos':
        Get.toNamed('/attended-events');
        break;
      case 'Públicos':
        Get.toNamed('/public-events');
        break;
      case 'Avisos':
        Get.toNamed('/notifications');
        break;
      case 'Perfil':
        Get.toNamed('/profile');
        break;
    }
  }
}