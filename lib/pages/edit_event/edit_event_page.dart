import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'edit_event_controller.dart';

class EditEventPage extends StatelessWidget {
  EditEventPage({super.key});

  final EditEventController controller = Get.put(EditEventController());
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (image != null) {
      final bytes = await image.readAsBytes();
      controller.imageBytes.value = bytes;
      // En este mock mantenemos imageUrl; si subes a tu API, reemplaza por la URL resultante.
      // controller.imageUrl.value = 'https://mi-cdn.com/imagen_subida.jpg';
    }
  }

  Future<void> _pickStartDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDate: controller.startDate.value,
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
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.startDate.value),
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
    if (time == null) return;

    controller.startDate.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    // Ajuste: si la nueva startDate supera a endDate, empujamos endDate a +1h
    if (controller.endDate.value.isBefore(controller.startDate.value)) {
      controller.endDate.value = controller.startDate.value.add(
        const Duration(hours: 1),
      );
    }
  }

  Future<void> _pickEndDateTime(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 3),
      initialDate: controller.endDate.value,
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
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.endDate.value),
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
    if (time == null) return;

    controller.endDate.value = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Editar evento',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Guardar cambios',
            onPressed: () {
              // Validación visual extra (por si quieres validadores en TextFormField)
              final formOk = _formKey.currentState?.validate() ?? true;
              if (formOk) controller.save();
            },
          ),
        ],
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Imagen (preview + botón cambiar)
                _ImageSection(controller: controller, pickImage: _pickImage),

                const SizedBox(height: 24),

                // Título
                _buildTextField(
                  label: 'Título',
                  initialValue: controller.title.value,
                  onChanged: (v) => controller.title.value = v,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa un título'
                      : null,
                ),

                const SizedBox(height: 20),

                // Tipo (Privacidad)
                DropdownButtonFormField<String>(
                  value: controller.privacyAsString,
                  items: controller.eventTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.setPrivacyFromString(v);
                  },
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
                      borderSide: const BorderSide(
                        color: Colors.black,
                        width: 1.5,
                      ),
                    ),
                  ),
                  dropdownColor: Colors.white,
                ),

                const SizedBox(height: 20),

                // Descripción
                _buildTextField(
                  label: 'Descripción',
                  initialValue: controller.description.value,
                  maxLines: 4,
                  onChanged: (v) => controller.description.value = v,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa una descripción'
                      : null,
                ),

                const SizedBox(height: 20),

                // Ubicación (texto libre)
                _buildTextField(
                  label: 'Ubicación / Dirección',
                  initialValue: controller.locationText.value,
                  onChanged: (v) => controller.locationText.value = v,
                  suffixIcon: Icons.location_on_outlined,
                ),

                const SizedBox(height: 24),

                // Fechas
                _DateTimePickers(
                  onPickStart: () => _pickStartDateTime(context),
                  onPickEnd: () => _pickEndDateTime(context),
                ),

                const SizedBox(height: 32),

                // Botón Guardar (redundante al AppBar, útil en scroll largo)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar cambios'),
                    onPressed: () {
                      final formOk = _formKey.currentState?.validate() ?? true;
                      if (formOk) controller.save();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTextField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    int maxLines = 1,
    IconData? suffixIcon,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
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
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: Colors.grey.shade600)
            : null,
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.controller, required this.pickImage});

  final EditEventController controller;
  final Future<void> Function() pickImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Imagen',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Obx(() {
                    final Uint8List? bytes = controller.imageBytes.value;
                    if (bytes != null) {
                      return Image.memory(bytes, fit: BoxFit.cover);
                    }
                    if (controller.imageUrl.value.isNotEmpty) {
                      return Image.network(
                        controller.imageUrl.value,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 48,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      );
                    }
                    return Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                    );
                  }),
                ),
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: InkWell(
                    onTap: pickImage,
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(10),
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
                      child: const Icon(
                        Icons.edit,
                        size: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DateTimePickers extends StatelessWidget {
  const _DateTimePickers({required this.onPickStart, required this.onPickEnd});

  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final c = Get.find<EditEventController>();
      String fmt(DateTime d) {
        final two = (int n) => n.toString().padLeft(2, '0');
        return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Horario',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: 'Inicio',
                  value: fmt(c.startDate.value),
                  onTap: onPickStart,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DateTile(
                  label: 'Fin',
                  value: fmt(c.endDate.value),
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
          if (c.endDate.value.isBefore(c.startDate.value))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '⚠️ La fecha/hora de fin debe ser posterior al inicio',
                style: TextStyle(color: Colors.red.shade700, fontSize: 12),
              ),
            ),
        ],
      );
    });
  }
}

class _DateTile extends StatelessWidget {
  const _DateTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
