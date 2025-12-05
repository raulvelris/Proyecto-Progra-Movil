import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../edit_event_controller.dart';
import 'edit_image_step.dart'; // Para reutilizar StepProgressBar
import '../../location_picker/location_picker_page.dart';

class EditDetailsStep extends StatelessWidget {
  final EditEventController controller = Get.find();

  EditDetailsStep({super.key});

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
          '2 de 3: Editar detalles',
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTextField(
              label: 'Título del evento',
              hint: 'Ingresa el título',
              controller: controller.titleController,
              onChanged: (value) => controller.title.value = value,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: _inputDecoration('Tipo de evento'),
              dropdownColor: Colors.white,
              value: controller.eventTypes.contains(controller.eventType.value)
                  ? controller.eventType.value
                  : null,
              items: controller.eventTypes.map((String type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                if (value != null) controller.eventType.value = value;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              label: 'Descripción',
              hint: 'Descripción del evento',
              controller: controller.descriptionController,
              onChanged: (value) => controller.description.value = value,
              maxLines: 4,
            ),
            const SizedBox(height: 32),
            const Text('Horario del evento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildDateTimePicker(
                    context: context,
                    label: 'Fecha inicio',
                    value: '${controller.startDate.value.day}/${controller.startDate.value.month}/${controller.startDate.value.year}',
                    icon: Icons.calendar_today,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: controller.startDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) controller.startDate.value = date;
                    },
                  )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => _buildDateTimePicker(
                    context: context,
                    label: 'Hora inicio',
                    value: '${controller.startTime.value.hour.toString().padLeft(2, '0')}:${controller.startTime.value.minute.toString().padLeft(2, '0')}',
                    icon: Icons.access_time,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(controller.startTime.value),
                      );
                      if (time != null) {
                        final now = controller.startTime.value;
                        controller.startTime.value = DateTime(
                            now.year, now.month, now.day, time.hour, time.minute);
                      }
                    },
                  )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildDateTimePicker(
                    context: context,
                    label: 'Fecha fin',
                    value: '${controller.endDate.value.day}/${controller.endDate.value.month}/${controller.endDate.value.year}',
                    icon: Icons.calendar_today,
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: controller.endDate.value,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) controller.endDate.value = date;
                    },
                  )),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => _buildDateTimePicker(
                    context: context,
                    label: 'Hora fin',
                    value: '${controller.endTime.value.hour.toString().padLeft(2, '0')}:${controller.endTime.value.minute.toString().padLeft(2, '0')}',
                    icon: Icons.access_time,
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(controller.endTime.value),
                      );
                      if (time != null) {
                        final now = controller.endTime.value;
                        controller.endTime.value = DateTime(
                            now.year, now.month, now.day, time.hour, time.minute);
                      }
                    },
                  )),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTextField(
              label: 'Ubicación',
              hint: 'Toca para seleccionar ubicación',
              controller: controller.locationController,
              readOnly: true,
              onTap: () async {
                final result = await Get.to(() => const LocationPickerPage(), arguments: {
                  'lat': controller.latitude.value != 0.0 ? controller.latitude.value : -12.0464,
                  'lng': controller.longitude.value != 0.0 ? controller.longitude.value : -77.0428,
                  'address': controller.location.value,
                });
                
                if (result != null && result is Map) {
                  controller.location.value = result['address'];
                  controller.locationController.text = result['address']; // Actualizar el texto visible
                  controller.latitude.value = result['lat'];
                  controller.longitude.value = result['lng'];
                }
              },
              suffixIcon: Icons.location_on_outlined,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Obx(() => ElevatedButton(
            onPressed: controller.canMoveNext ? controller.nextStep : null,
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

  InputDecoration _inputDecoration(String label, {String? hint, IconData? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
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
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: Colors.grey.shade600) : null,
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    Function(String)? onChanged,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      decoration: _inputDecoration(label, hint: hint, suffixIcon: suffixIcon),
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
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                        fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500),
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
