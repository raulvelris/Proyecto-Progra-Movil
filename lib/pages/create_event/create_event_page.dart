// Importación de paquetes necesarios
import 'package:flutter/material.dart'; // Para construir la interfaz en Flutter
import 'package:get/get.dart'; 
import 'create_event_controller.dart'; // Controlador personalizado para la creación de eventos
import 'steps/image_pick_step.dart'; // Paso para seleccionar imágenes
import 'steps/details_form_step.dart'; // Paso para llenar detalles del evento
import 'steps/preview_step.dart'; // Paso para previsualizar el evento

// Definición de la página CreateEventPage
class CreateEventPage extends StatelessWidget {
  final CreateEventController controller = Get.put(
    CreateEventController(),
    permanent: true,
  );

  // Constructor de la página
  CreateEventPage({super.key}) {
    controller.clearForm(); // Limpia cualquier dato previo del formulario al crear la página
  }

  // Método build que genera la interfaz
  @override
  Widget build(BuildContext context) {
    return Obx(() { 
      switch (controller.currentStep.value) { // Dependiendo del paso actual
        case 0:
          return ImagePickStep(); // Muestra el paso de selección de imagen
        case 1:
          return DetailsFormStep(); // Muestra el paso de detalles del evento
        case 2:
          return PreviewStep(); // Muestra el paso de previsualización
        default:
          return ImagePickStep(); // Valor por defecto: vuelve al paso de selección de imagen
      }
    });
  }
}
