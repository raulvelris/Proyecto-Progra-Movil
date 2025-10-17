import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../create_event_controller.dart';

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
              color: Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailsFormStep extends StatelessWidget {
  final CreateEventController controller = Get.find();

  DetailsFormStep({super.key});

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
        title: const Text('2 de 3: Detalla'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Obx(() => StepProgressBar(
            currentStep: controller.currentStep.value,
            totalSteps: 3,
          )),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: TextEditingController(text: controller.title.value),
              onChanged: (value) => controller.title.value = value,
              decoration: const InputDecoration(
                labelText: 'Título del evento',
                hintText: 'Ingresa el título del evento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Tipo de evento',
                border: OutlineInputBorder(),
              ),
              value: controller.eventTypes.contains(controller.eventType.value)
                ? controller.eventType.value
                : (controller.eventType.value.isEmpty ? null : controller.eventType.value),
              items: controller.eventTypes.map((String type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.eventType.value = value;
                }
              },
              hint: Text(controller.eventTypes[0]),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: TextEditingController(text: controller.description.value),
              onChanged: (value) => controller.description.value = value,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Descripción del evento',
                hintText: 'Escribe la descripción del evento',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            Text('Horario del evento',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    return InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: controller.startDate.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          controller.startDate.value = date;
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha inicio',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${controller.startDate.value.day}/${controller.startDate.value.month}/${controller.startDate.value.year}',
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() {
                    return InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(controller.startTime.value),
                        );
                        if (time != null) {
                          controller.startTime.value = DateTime(
                            controller.startTime.value.year,
                            controller.startTime.value.month,
                            controller.startTime.value.day,
                            time.hour,
                            time.minute,
                          );
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora inicio',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          '${controller.startTime.value.hour.toString().padLeft(2, '0')}:${controller.startTime.value.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Obx(() {
                    final initialDate = controller.endDate.value.isBefore(controller.startDate.value)
                        ? controller.startDate.value
                        : controller.endDate.value;
                    return InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: controller.startDate.value,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          controller.endDate.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            controller.endTime.value.hour,
                            controller.endTime.value.minute,
                          );
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha fin',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${controller.endDate.value.day}/${controller.endDate.value.month}/${controller.endDate.value.year}',
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() {
                    return InkWell(
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(controller.endTime.value),
                        );
                        if (time != null) {
                          controller.endTime.value = DateTime(
                            controller.endTime.value.year,
                            controller.endTime.value.month,
                            controller.endTime.value.day,
                            time.hour,
                            time.minute,
                          );
                        }
                      },
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Hora fin',
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.access_time),
                        ),
                        child: Text(
                          '${controller.endTime.value.hour.toString().padLeft(2, '0')}:${controller.endTime.value.minute.toString().padLeft(2, '0')}',
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 32),

            TextField(
              controller: TextEditingController(text: controller.location.value),
              onChanged: (value) => controller.location.value = value,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                hintText: 'Ingresa la ubicación',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.location_on),
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
        child: Obx(() => ElevatedButton(
          onPressed: controller.canMoveNext ? controller.nextStep : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            minimumSize: const Size(double.infinity, 48),
          ),
          child: Text(controller.nextButtonText),
        )),
      ),
    );
  }
}