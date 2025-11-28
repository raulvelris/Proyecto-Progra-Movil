import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';

class SignInController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  final _authService = AuthService();
  final _sessionService = SessionService();
  
  final isLoading = false.obs;
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
  
  /// Valida los campos de email y contraseña
  String? _validateFields() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    
    if (email.isEmpty || password.isEmpty) {
      return 'Por favor completa todos los campos';
    }
    
    if (!GetUtils.isEmail(email)) {
      return 'Por favor ingresa un correo válido';
    }
    
    if (password.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }
  
  /// Realiza el login
  Future<void> login() async {
    // Validar campos
    final validationError = _validateFields();
    if (validationError != null) {
      Get.snackbar(
        'Error de validación',
        validationError,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
      return;
    }
    
    isLoading.value = true;
    
    try {
      final result = await _authService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
      
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
      
      // Navegar a home
      Get.offAllNamed('/home');
      
      // Mostrar mensaje de éxito
      Get.snackbar(
        'Bienvenido',
        'Has iniciado sesión correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        margin: const EdgeInsets.all(16),
      );
      
    } catch (e) {
      // Mostrar error
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
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
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
