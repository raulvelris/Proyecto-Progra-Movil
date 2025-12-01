import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/profile_service.dart';
import '../../services/session_service.dart';

class EditProfileController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final photoUrlController = TextEditingController();

  final _profileService = ProfileService();
  final _sessionService = SessionService();

  final isLoading = false.obs;
  final photoUrl = ''.obs; // Observable para la foto

  @override
  void onInit() {
    super.onInit();
    loadCurrentData();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    photoUrlController.dispose();
    super.onClose();
  }

  /// Carga los datos actuales del perfil
  void loadCurrentData() {
    firstNameController.text = _sessionService.userFirstName ?? '';
    lastNameController.text = _sessionService.userLastName ?? '';
    emailController.text = _sessionService.userEmail ?? '';
    photoUrlController.text = _sessionService.userProfilePicture ?? '';
    photoUrl.value = _sessionService.userProfilePicture ?? '';
  }

  /// Actualiza la URL de la foto
  void updatePhotoUrl(String url) {
    photoUrlController.text = url;
    photoUrl.value = url;
  }

  /// Selecciona una imagen de la galería
  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        // Leer la imagen como bytes
        final bytes = await File(image.path).readAsBytes();
        
        // Convertir a base64
        final base64Image = base64Encode(bytes);
        
        // Crear data URL
        final dataUrl = 'data:image/jpeg;base64,$base64Image';
        
        // Actualizar la foto
        updatePhotoUrl(dataUrl);
        
        Get.snackbar(
          'Éxito',
          'Imagen seleccionada correctamente',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo seleccionar la imagen: ${e.toString()}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Valida los campos
  String? _validateFields() {
    final email = emailController.text.trim();

    if (email.isEmpty) {
      return 'El correo es requerido';
    }

    if (!GetUtils.isEmail(email)) {
      return 'Por favor ingresa un correo válido';
    }

    return null;
  }

  /// Actualiza el perfil
  Future<void> updateProfile() async {
    // Validar campos
    final validationError = _validateFields();
    if (validationError != null) {
      Get.snackbar(
        'Error de validación',
        validationError,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    try {
      final nombre = firstNameController.text.trim();
      final apellido = lastNameController.text.trim();
      final correo = emailController.text.trim();
      final fotoPerfil = photoUrlController.text.trim();

      final updatedUser = await _profileService.updateProfile(
        nombre: nombre.isNotEmpty ? nombre : null,
        apellido: apellido.isNotEmpty ? apellido : null,
        correo: correo,
        fotoPerfil: fotoPerfil.isNotEmpty ? fotoPerfil : null,
      );

      // Actualizar SessionService
      await _sessionService.saveUserData(
        _sessionService.userToken!,
        updatedUser['usuario_id'].toString(),
        updatedUser['correo'],
        firstName: updatedUser['nombre'],
        lastName: updatedUser['apellido'],
        profilePicture: updatedUser['foto_perfil'],
      );

      // Volver atrás
      Get.back();

      // Mostrar mensaje de éxito
      Get.snackbar(
        'Éxito',
        'Perfil actualizado correctamente',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
