import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../create_event_controller.dart';

// Widget para mostrar la barra de progreso de los pasos
class StepProgressBar extends StatelessWidget {
  final int currentStep; // Paso actual
  final int totalSteps; // Total de pasos

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        (currentStep + 1) / totalSteps; // Calcula porcentaje de avance

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Fondo de la barra
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress, // Porción llenada según avance
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black, // Color de progreso
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget para el paso de selección de imagen
class ImagePickStep extends StatelessWidget {
  final CreateEventController controller = Get.find(); // Controlador de estado
  final ImagePicker _picker = ImagePicker(); // Selector de imágenes

  ImagePickStep({super.key});

  // Función para seleccionar una imagen de la galería
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image != null) {
        controller.imagePath.value = image.path; // Guarda la ruta de la imagen
        controller.imageBytes.value = await image
            .readAsBytes(); // Guarda los bytes para mostrar
      } else {
        Get.snackbar(
          'Aviso',
          'No se seleccionó ninguna imagen',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.black,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      print('Error al seleccionar imagen: $e');
      Get.snackbar(
        'Error',
        'No se pudo seleccionar la imagen: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 5),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar con botón de retroceso y barra de progreso
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(), // Regresa a la pantalla anterior
        ),
        title: const Text(
          '1 de 3: Personaliza',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Obx(
            () => StepProgressBar(
              currentStep: controller.currentStep.value,
              totalSteps: 3,
            ),
          ),
        ),
      ),
      // Cuerpo principal
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(
          () => GestureDetector(
            onTap: _pickImage, // Permite tocar para seleccionar imagen
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                color: Colors.grey.shade50, // Fondo del contenedor
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: controller.imagePath.value.isEmpty
                      ? Colors.grey.shade300
                      : Colors.transparent,
                  width: 1.5,
                  style: controller.imagePath.value.isEmpty
                      ? BorderStyle.solid
                      : BorderStyle.none,
                ),
              ),
              // Si no hay imagen seleccionada, muestra icono y texto
              child: controller.imagePath.value.isEmpty
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Toca para seleccionar una imagen',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    )
                  // Si hay imagen, la muestra y permite editar
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: controller.imageBytes.value != null
                              ? Image.memory(
                                  controller.imageBytes.value!,
                                  fit: BoxFit.cover,
                                )
                              : const SizedBox(),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            color: Colors.black.withOpacity(0.1),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.edit, color: Colors.black),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
      // Botón inferior para continuar al siguiente paso
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Obx(
            () => ElevatedButton(
              onPressed: controller.imagePath.value.isNotEmpty
                  ? controller.nextStep
                  : null, // Habilitado solo si hay imagen
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              child: const Text(
                'Siguiente: Detalles',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
