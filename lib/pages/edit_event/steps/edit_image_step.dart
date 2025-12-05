import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import '../edit_event_controller.dart';

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
    final progress = (currentStep + 1) / totalSteps;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class EditImageStep extends StatelessWidget {
  final EditEventController controller = Get.find();
  final ImagePicker _picker = ImagePicker();

  EditImageStep({super.key});

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
        controller.imageBytes.value = await image.readAsBytes();
        controller.isImageChanged.value = true;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo seleccionar la imagen: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '1 de 3: Editar imagen',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Obx(() => StepProgressBar(
            currentStep: controller.currentStep.value,
            totalSteps: 3,
          )),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Obx(() => GestureDetector(
          onTap: _pickImage,
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.5,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: _buildImage(),
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
        )),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Obx(() => ElevatedButton(
            onPressed: controller.imagePath.value.isNotEmpty ? controller.nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              controller.nextButtonText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          )),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (controller.isImageChanged.value && controller.imageBytes.value != null) {
      return Image.memory(
        controller.imageBytes.value!,
        fit: BoxFit.cover,
      );
    } else if (controller.imagePath.value.startsWith('http')) {
      return Image.network(
        controller.imagePath.value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.error),
      );
    } else if (controller.imagePath.value.startsWith('data:image')) {
       // Handle Base64 string from backend
       try {
         final parts = controller.imagePath.value.split(',');
         final base64String = parts.length > 1 ? parts[1] : parts[0];
         final bytes = base64Decode(base64String.trim());
         return Image.memory(
           bytes,
           fit: BoxFit.cover,
           errorBuilder: (_, __, ___) => const Icon(Icons.error),
         );
       } catch (e) {
         return const Center(child: Icon(Icons.broken_image, size: 50, color: Colors.grey));
       }
    } else if (controller.imagePath.value.isNotEmpty) {
      return Image.file(
        File(controller.imagePath.value),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.error),
      );
    } else {
      return const Center(child: Icon(Icons.image, size: 50, color: Colors.grey));
    }
  }
}
