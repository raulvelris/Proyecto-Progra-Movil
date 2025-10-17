import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import '../create_event_controller.dart';

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

class PreviewStep extends StatelessWidget {
  final CreateEventController controller = Get.find();
  
  PreviewStep({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.previousStep();
          },
        ),
        title: const Text('3 de 3: Vista Previa'),
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
            // Imagen del evento
            Obx(() => controller.imagePath.value.isNotEmpty
              ? kIsWeb
                ? Image.network(
                    controller.imagePath.value,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error, size: 64),
                      );
                    },
                  )
                : Image.file(
                    File(controller.imagePath.value),
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.error, size: 64),
                      );
                    },
                  )
              : Container(
                  width: double.infinity,
                  height: 200,
                  color: colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image, size: 64),
                ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título del evento
                  Obx(() => Text(
                    controller.title.value,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                  const SizedBox(height: 16),

                  // Fecha y hora de inicio
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Inicio',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                            '${controller.startDate.value.day}/${controller.startDate.value.month}/${controller.startDate.value.year} - '
                            '${controller.startTime.value.hour.toString().padLeft(2, '0')}:${controller.startTime.value.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          )),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Fecha y hora de fin
                  Row(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fin',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Obx(() => Text(
                            '${controller.endDate.value.day}/${controller.endDate.value.month}/${controller.endDate.value.year} - '
                            '${controller.endTime.value.hour.toString().padLeft(2, '0')}:${controller.endTime.value.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          )),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Ubicación
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 20,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Obx(() => Text(
                          controller.location.value,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Mapa
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      height: 200,
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
                  const SizedBox(height: 16),

                  // Descripción
                  Text(
                    'Descripción del evento',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    controller.description.value,
                    style: Theme.of(context).textTheme.bodyMedium,
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: controller.saveEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text('Guardar'),
        ),
      ),
    );
  }
}