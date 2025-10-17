import 'dart:io';
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
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.startDate.value),
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
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(controller.endDate.value),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar evento'),
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
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Imagen (preview + botón cambiar)
                _ImageSection(controller: controller, pickImage: _pickImage),

                const SizedBox(height: 16),

                // Título
                TextFormField(
                  initialValue: controller.title.value,
                  onChanged: (v) => controller.title.value = v,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa un título'
                      : null,
                ),

                const SizedBox(height: 16),

                // Tipo (Privacidad)
                DropdownButtonFormField<String>(
                  value: controller.privacyAsString,
                  items: controller.eventTypes
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.setPrivacyFromString(v);
                  },
                  decoration: const InputDecoration(
                    labelText: 'Tipo de evento',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción
                TextFormField(
                  initialValue: controller.description.value,
                  maxLines: 4,
                  onChanged: (v) => controller.description.value = v,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa una descripción'
                      : null,
                ),

                const SizedBox(height: 16),

                // Ubicación (texto libre)
                TextFormField(
                  initialValue: controller.locationText.value,
                  onChanged: (v) => controller.locationText.value = v,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación / Dirección',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                // Fechas
                _DateTimePickers(
                  onPickStart: () => _pickStartDateTime(context),
                  onPickEnd: () => _pickEndDateTime(context),
                ),

                const SizedBox(height: 24),

                // Botón Guardar (redundante al AppBar, útil en scroll largo)
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar cambios'),
                    onPressed: () {
                      final formOk = _formKey.currentState?.validate() ?? true;
                      if (formOk) controller.save();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _ImageSection extends StatelessWidget {
  const _ImageSection({required this.controller, required this.pickImage});

  final EditEventController controller;
  final Future<void> Function() pickImage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Imagen', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Obx(() {
                final Uint8List? bytes = controller.imageBytes.value;
                if (bytes != null) {
                  return Image.memory(bytes, fit: BoxFit.cover);
                }
                if (controller.imageUrl.value.isNotEmpty) {
                  return Image.network(
                    controller.imageUrl.value,
                    fit: BoxFit.cover,
                  );
                }
                return Center(
                  child: Icon(Icons.image, size: 48, color: cs.outline),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Cambiar imagen'),
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
    final tt = Theme.of(context).textTheme;
    return Obx(() {
      final c = Get.find<EditEventController>();
      String fmt(DateTime d) {
        final two = (int n) => n.toString().padLeft(2, '0');
        return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
      }

      return Column(
        children: [
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
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              c.endDate.value.isBefore(c.startDate.value)
                  ? '⚠️ La fecha/hora de fin debe ser posterior al inicio'
                  : '',
              style: tt.bodySmall?.copyWith(color: Colors.red),
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
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.event, size: 18, color: cs.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(child: Text(value)),
            Icon(
              Icons.edit_calendar_outlined,
              size: 18,
              color: cs.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
