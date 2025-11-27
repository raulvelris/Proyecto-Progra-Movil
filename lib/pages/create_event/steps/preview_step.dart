import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import '../create_event_controller.dart';

// Barra de progreso de los pasos
class StepProgressBar extends StatelessWidget {
  final int currentStep; // Paso actual
  final int totalSteps;  // Total de pasos

  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep + 1) / totalSteps; // Porcentaje completado

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade200, // Fondo barra
        borderRadius: BorderRadius.circular(2),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: progress, // Progreso visible
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black, // Color de la barra
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

// Paso de vista previa del evento
class PreviewStep extends StatelessWidget {
  final CreateEventController controller = Get.find(); // Controlador de estado

  PreviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar con botón de retroceso y barra de progreso
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            controller.previousStep(); // Retroceder un paso
          },
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
      // Cuerpo principal con scroll
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del evento
            Obx(() => controller.imagePath.value.isNotEmpty
              ? kIsWeb
                ? Image.network(
                    controller.imagePath.value,
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 240,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      );
                    },
                  )
                : Image.file(
                    File(controller.imagePath.value),
                    width: double.infinity,
                    height: 240,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 240,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                      );
                    },
                  )
              : Container(
                  width: double.infinity,
                  height: 240,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_outlined, size: 64, color: Colors.grey),
                ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del evento
                  Obx(() => Text(
                    controller.title.value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  )),
                  const SizedBox(height: 24),

                  // Inicio del evento
                  _buildInfoRow(
                    context,
                    icon: Icons.calendar_today_rounded,
                    label: 'Inicio',
                    value: '${controller.startDate.value.day}/${controller.startDate.value.month}/${controller.startDate.value.year} - '
                           '${controller.startTime.value.hour.toString().padLeft(2, '0')}:${controller.startTime.value.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 16),

                  // Fin del evento
                  _buildInfoRow(
                    context,
                    icon: Icons.event_available_rounded,
                    label: 'Fin',
                    value: '${controller.endDate.value.day}/${controller.endDate.value.month}/${controller.endDate.value.year} - '
                           '${controller.endTime.value.hour.toString().padLeft(2, '0')}:${controller.endTime.value.minute.toString().padLeft(2, '0')}',
                  ),
                  const SizedBox(height: 16),

                  // Ubicación
                  _buildInfoRow(
                    context,
                    icon: Icons.location_on_outlined,
                    label: 'Ubicación',
                    value: controller.location.value,
                  ),
                  const SizedBox(height: 24),

                  // Mapa con marcador
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(-12.0464, -77.0428), // Lima, Perú
                          zoom: 15,
                        ),
                        markers: {
                          const Marker(
                            markerId: MarkerId('event_location'),
                            position: LatLng(-12.0464, -77.0428),
                          ),
                        },
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Descripción del evento
                  const Text(
                    'Descripción del evento',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Obx(() => Text(
                    controller.description.value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),

      // Botón inferior para guardar el evento
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ElevatedButton(
            onPressed: controller.saveEvent, // Llama a la función de guardado
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
              'Guardar y Publicar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
