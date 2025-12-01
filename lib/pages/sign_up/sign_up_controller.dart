import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart'; 

class SignUpController extends GetxController {
  final AuthService _authService = AuthService();
  final SessionService _sessionService = SessionService(); 

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> register() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Error',
        'Todos los campos son obligatorios',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Error',
        'La contraseña debe tener al menos 6 caracteres',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;
      await _authService.register(firstName, lastName, email, password);
      
      // Navegar a la página de verificación de email
      Get.offNamed('/verify-email');
      
    } catch (e) {
      Get.snackbar(
        'Error al registrarse',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final result = await _authService.loginWithGoogle();
      
      // Guardar sesión
      final user = result['user'];
      await _sessionService.saveUserData(
        result['token'],
        user['usuario_id'].toString(),
        user['correo'],
        firstName: user['nombre'],
        lastName: user['apellido'],
        profilePicture: user['foto_perfil'],
      );
      
      Get.offAllNamed('/home');
      
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
