import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_event_controller.dart';
import 'steps/image_pick_step.dart';
import 'steps/details_form_step.dart';
import 'steps/preview_step.dart';

class CreateEventPage extends StatelessWidget {
  final CreateEventController controller = Get.put(
    CreateEventController(),
    permanent: true,
  );

  CreateEventPage({super.key}) {
    // Limpiar el formulario cuando se inicializa la página
    controller.clearForm();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.currentStep.value) {
        case 0:
          return ImagePickStep();
        case 1:
          return DetailsFormStep();
        case 2:
          return PreviewStep();
        default:
          return ImagePickStep();
      }
    });
  }
}
