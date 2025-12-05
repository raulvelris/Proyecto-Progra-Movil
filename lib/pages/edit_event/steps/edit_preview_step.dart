import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'dart:convert';
import '../edit_event_controller.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'edit_image_step.dart'; // Para reutilizar StepProgressBar

class EditPreviewStep extends StatelessWidget {
  final EditEventController controller = Get.find();

  EditPreviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => controller.previousStep(),
        ),
        title: const Text(
          '3 de 3: Vista Previa',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => _buildImage()),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(() => Text(
                    controller.title.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )),
                  const SizedBox(height: 24),
                  _buildInfoRow(
                    icon: Icons.calendar_today,
                    label: 'Inicio',
                    value: '${controller.startDate.value.day}/${controller.startDate.value.month}/${controller.startDate.value.year} - '
                           '${controller.startTime.value.hour.toString().padLeft(2, '0')}:${controller.startTime.value.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.event_available,
                    label: 'Fin',
                    value: '${controller.endDate.value.day}/${controller.endDate.value.month}/${controller.endDate.value.year} - '
                           '${controller.endTime.value.hour.toString().padLeft(2, '0')}:${controller.endTime.value.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 16),
                  Obx(() => _buildInfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Ubicación',
                    value: controller.location.value,
                  )),
                  const SizedBox(height: 24),
                  
                  // Mapa con marcador
                  Obx(() => Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: LatLng(
                            controller.latitude.value != 0 ? controller.latitude.value : -12.0464,
                            controller.longitude.value != 0 ? controller.longitude.value : -77.0428
                          ),
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.eventmaster.app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: LatLng(
                                  controller.latitude.value != 0 ? controller.latitude.value : -12.0464,
                                  controller.longitude.value != 0 ? controller.longitude.value : -77.0428
                                ),
                                width: 40,
                                height: 40,
                                child: Icon(
                                  Icons.location_on,
                                  color: Colors.red.shade600,
                                  size: 40,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )),
                  const SizedBox(height: 24),
                  const Text(
                    'Descripción del evento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text(
                    controller.description.value,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ElevatedButton(
            onPressed: controller.updateEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Guardar Cambios',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (controller.isImageChanged.value && controller.imageBytes.value != null) {
      return Image.memory(
        controller.imageBytes.value!,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
      );
    } else if (controller.imagePath.value.startsWith('http')) {
      return Image.network(
        controller.imagePath.value,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: double.infinity,
          height: 240,
          color: Colors.grey.shade200,
          child: const Icon(Icons.error),
        ),
      );
    } else if (controller.imagePath.value.startsWith('data:image')) {
       // Handle Base64 string from backend
       try {
         final parts = controller.imagePath.value.split(',');
         final base64String = parts.length > 1 ? parts[1] : parts[0];
         final bytes = base64Decode(base64String.trim());
         return Image.memory(
           bytes,
           width: double.infinity,
           height: 240,
           fit: BoxFit.cover,
           errorBuilder: (_, __, ___) => Container(
             width: double.infinity,
             height: 240,
             color: Colors.grey.shade200,
             child: const Icon(Icons.error),
           ),
         );
       } catch (e) {
         return Container(
           width: double.infinity,
           height: 240,
           color: Colors.grey.shade200,
           child: const Icon(Icons.broken_image, size: 64, color: Colors.grey),
         );
       }
    } else if (controller.imagePath.value.isNotEmpty) {
      return Image.file(
        File(controller.imagePath.value),
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        width: double.infinity,
        height: 240,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, size: 64, color: Colors.grey),
      );
    }
  }

  Widget _buildInfoRow({required IconData icon, required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 20, color: Colors.black),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
