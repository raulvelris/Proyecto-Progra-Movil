import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/profile_service.dart';
import '../../services/session_service.dart';

class ProfileController extends GetxController {
  final _profileService = ProfileService();
  final sessionService = SessionService();

  final isLoading = false.obs;
  final profileData = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  /// Carga el perfil del usuario desde el backend
  Future<void> loadProfile() async {
    isLoading.value = true;

    try {
      final data = await _profileService.getProfile();
      profileData.value = data;

      // Actualizar SessionService con datos frescos
      await sessionService.saveUserData(
        sessionService.userToken!,
        data['usuario_id'].toString(),
        data['correo'],
        firstName: data['nombre'],
        lastName: data['apellido'],
        profilePicture: data['foto_perfil'],
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String get firstName => profileData.value?['nombre'] ?? '';
  String get lastName => profileData.value?['apellido'] ?? '';
  String get email => profileData.value?['correo'] ?? '';
  String? get profilePicture => profileData.value?['foto_perfil'];

  String get fullName {
    final first = firstName;
    final last = lastName;
    if (first.isEmpty && last.isEmpty) return 'Usuario';
    return '$first $last'.trim();
  }

  String get initials {
    final first = firstName;
    final last = lastName;
    if (first.isEmpty && last.isEmpty) {
      final emailPart = email.split('@')[0];
      return emailPart.substring(0, 2).toUpperCase();
    }
    final firstInitial = first.isNotEmpty ? first[0] : '';
    final lastInitial = last.isNotEmpty ? last[0] : '';
    return '$firstInitial$lastInitial'.toUpperCase();
  }
}
