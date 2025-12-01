import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../create_event_controller.dart';
import '../../add_resource/add_resource_flow.dart';

// Widget que representa la barra de progreso de los pasos
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
    final progress = (currentStep + 1) / totalSteps; // Calcula el progreso

    // Contenedor principal de la barra
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
          widthFactor: progress, // Porción coloreada según progreso
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

// Widget del paso de detalles del evento
class DetailsFormStep extends StatelessWidget {
  final CreateEventController controller = Get.find(); // Obtiene el controlador

  DetailsFormStep({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // AppBar con botón de retroceso y barra de progreso
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            controller.previousStep(); // Retrocede al paso anterior
          },
        ),
        title: const Text(
          '2 de 3: Detalles',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(12),
          child: Obx(() => StepProgressBar(
            currentStep: controller.currentStep.value, // Muestra paso actual
            totalSteps: 3,
          )),
        ),
      ),
      // Cuerpo principal con formulario
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto para el título del evento
            _buildTextField(
              label: 'Título del evento',
              hint: 'Ingresa el título del evento',
              controller: TextEditingController(text: controller.title.value),
              onChanged: (value) => controller.title.value = value,
            ),
            const SizedBox(height: 20),

            // Dropdown para seleccionar tipo de evento
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Tipo de evento',
                labelStyle: TextStyle(color: Colors.grey.shade600),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.black, width: 1.5),
                ),
              ),
              dropdownColor: Colors.white,
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
                  controller.eventType.value = value; // Actualiza tipo de evento
                }
              },
              hint: Text(controller.eventTypes[0]),
            ),
            const SizedBox(height: 20),

            // Campo de descripción del evento
            _buildTextField(
              label: 'Descripción del evento',
              hint: 'Escribe la descripción del evento',
              controller: TextEditingController(text: controller.description.value),
              onChanged: (value) => controller.description.value = value,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Etiqueta para horario del evento
            const Text('Horario del evento',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                )),
            const SizedBox(height: 20),
            
            // Fila de fecha y hora de inicio
            Row(
              children: [
                Expanded(
                  child: Obx(() { // Campo fecha inicio
                    return _buildDateTimePicker(
                      context: context,
                      label: 'Fecha inicio',
                      value: '${controller.startDate.value.day}/${controller.startDate.value.month}/${controller.startDate.value.year}',
                      icon: Icons.calendar_today_rounded,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: controller.startDate.value,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.black,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          controller.startDate.value = date; // Actualiza fecha inicio
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() { // Campo hora inicio
                    return _buildDateTimePicker(
                      context: context,
                      label: 'Hora inicio',
                      value: '${controller.startTime.value.hour.toString().padLeft(2, '0')}:${controller.startTime.value.minute.toString().padLeft(2, '0')}',
                      icon: Icons.access_time_rounded,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(controller.startTime.value),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.black,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          controller.startTime.value = DateTime(
                            controller.startTime.value.year,
                            controller.startTime.value.month,
                            controller.startTime.value.day,
                            time.hour,
                            time.minute,
                          ); // Actualiza hora inicio
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Fila de fecha y hora de fin
            Row(
              children: [
                Expanded(
                  child: Obx(() { // Campo fecha fin
                    final initialDate = controller.endDate.value.isBefore(controller.startDate.value)
                        ? controller.startDate.value
                        : controller.endDate.value;
                    return _buildDateTimePicker(
                      context: context,
                      label: 'Fecha fin',
                      value: '${controller.endDate.value.day}/${controller.endDate.value.month}/${controller.endDate.value.year}',
                      icon: Icons.calendar_today_rounded,
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: controller.startDate.value,
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.black,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (date != null) {
                          controller.endDate.value = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            controller.endTime.value.hour,
                            controller.endTime.value.minute,
                          ); // Actualiza fecha fin
                        }
                      },
                    );
                  }),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() { // Campo hora fin
                    return _buildDateTimePicker(
                      context: context,
                      label: 'Hora fin',
                      value: '${controller.endTime.value.hour.toString().padLeft(2, '0')}:${controller.endTime.value.minute.toString().padLeft(2, '0')}',
                      icon: Icons.access_time_rounded,
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(controller.endTime.value),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: Colors.black,
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black,
                                ),
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (time != null) {
                          controller.endTime.value = DateTime(
                            controller.endTime.value.year,
                            controller.endTime.value.month,
                            controller.endTime.value.day,
                            time.hour,
                            time.minute,
                          ); // Actualiza hora fin
                        }
                      },
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Campo de ubicación del evento
            _buildTextField(
              label: 'Ubicación',
              hint: 'Ingresa la ubicación',
              controller: TextEditingController(text: controller.location.value),
              onChanged: (value) => controller.location.value = value,
              suffixIcon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 32),

            // Sección de recursos agregados durante la creación (paso 2)
            const Text(
              'Recursos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() {
              final items = controller.draftResources;
              if (items.isEmpty) {
                return Text(
                  'Aún no has agregado recursos a este evento.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                );
              }
              return Column(
                children: List.generate(items.length, (index) {
                  final r = items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          r.type == 1
                              ? Icons.insert_drive_file_rounded
                              : Icons.link_rounded,
                          size: 20,
                          color: r.type == 1
                              ? Colors.blueGrey
                              : Colors.blueAccent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                r.url,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          color: Colors.red.shade400,
                          onPressed: () async {
                            final shouldDelete = await _confirmDeleteDraftResource(context, r.name);
                            if (shouldDelete == true) {
                              controller.draftResources.removeAt(index);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }),
              );
            }),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final result = await Get.to<AddResourceResult>(
                    () => const AddResourceChoosePage(),
                  );
                  if (result != null) {
                    controller.addDraftResource(
                      name: result.name,
                      url: result.url,
                      type: result.type,
                    );
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar recurso'),
              ),
            ),
          ],
        ),
      ),
      // Botón inferior para avanzar al siguiente paso
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Obx(() => ElevatedButton(
            onPressed: controller.canMoveNext ? controller.nextStep : null, // Habilita según validación
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
            child: Text(
              controller.nextButtonText,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ), // Texto dinámico del botón
          )),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String) onChanged,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.grey.shade600),
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.black, width: 1.5),
        ),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade600) : null,
      ),
    );
  }

  Widget _buildDateTimePicker({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(icon, size: 20, color: Colors.grey.shade600),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> _confirmDeleteDraftResource(BuildContext context, String name) {
  return Get.defaultDialog<bool>(
    title: 'Eliminar recurso',
    middleText: '¿Deseas eliminar "$name"?',
    textConfirm: 'Eliminar',
    textCancel: 'Cancelar',
    confirmTextColor: Theme.of(context).colorScheme.onError,
    onConfirm: () => Get.back(result: true),
    onCancel: () => Get.back(result: false),
  );
}
