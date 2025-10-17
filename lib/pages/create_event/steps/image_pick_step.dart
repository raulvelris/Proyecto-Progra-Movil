import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../create_event_controller.dart';
import 'dart:typed_data';

// Componente reutilizable para la barra de progreso
class StepProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (currentStep + 1) / totalSteps;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 4,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: Color(0xFF4CAF50), // Verde más vibrante
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePickStep extends StatelessWidget {
  final CreateEventController controller = Get.find();
  final ImagePicker _picker = ImagePicker();

  ImagePickStep({super.key});

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        controller.imagePath.value = image.path;
        // Leer los bytes de la imagen
        controller.imageBytes.value = await image.readAsBytes();
      } else {
        Get.snackbar(
          'Aviso',
          'No se seleccionó ninguna imagen',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      Get.snackbar(
        'Error',
        'No se pudo seleccionar la imagen: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text('1 de 3: Personaliza'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Obx(() => StepProgressBar(
            currentStep: controller.currentStep.value,
            totalSteps: 3,
          )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Obx(() => GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline,
                width: 1,
              ),
            ),
            child: controller.imagePath.value.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Toca para seleccionar una imagen',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: controller.imageBytes.value != null
                            ? Image.memory(
                                controller.imageBytes.value!,
                                fit: BoxFit.cover,
                              )
                            : const SizedBox(),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.edit),
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.surface.withValues(alpha: 0.9),
                            foregroundColor: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        )),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() => ElevatedButton(
          onPressed: controller.imagePath.value.isNotEmpty ? controller.nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Siguiente: Detalla'),
        )),
      ),
    );
  }
}