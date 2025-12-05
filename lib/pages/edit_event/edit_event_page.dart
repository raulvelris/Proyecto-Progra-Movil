import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/event.dart';
import 'edit_event_controller.dart';
import 'steps/edit_image_step.dart';
import 'steps/edit_details_step.dart';
import 'steps/edit_preview_step.dart';

class EditEventPage extends StatelessWidget {
  final Event event;

  EditEventPage({super.key}) : event = Get.arguments as Event {
    // Inicializar el controlador con el evento pasado por argumentos
    Get.put(EditEventController(eventToEdit: event));
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EditEventController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: Colors.black),
          ),
        );
      }

      switch (controller.currentStep.value) {
        case 0:
          return EditImageStep();
        case 1:
          return EditDetailsStep();
        case 2:
          return EditPreviewStep();
        default:
          return EditImageStep();
      }
    });
  }
}
