import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/invitation.dart';
import '../../services/invitation_service.dart';

class InviteUsersController extends GetxController {
  final InvitationService _invitationService = InvitationService();
  
  // Estado reactivo
  final RxList<Invitee> searchResults = <Invitee>[].obs;
  final RxSet<int> selectedUserIds = <int>{}.obs;
  final RxMap<int, String> nonEligibleUsers = <int, String>{}.obs; // ID -> tipo
  final RxInt pendingCount = 0.obs;
  final RxInt pendingLimit = 0.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingNonEligible = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  // Event ID (se debe pasar al crear el controller)
  final int? eventId;

  InviteUsersController({this.eventId});

  // Text Controller para el campo de búsqueda
  final TextEditingController searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // Cargar usuarios no elegibles y conteo al iniciar
    if (eventId != null) {
      loadNonEligibleUsers();
      loadPendingCount();
    }
  }

  /// Carga el conteo de invitaciones pendientes
  Future<void> loadPendingCount() async {
    if (eventId == null) return;

    try {
      final data = await _invitationService.getPendingInvitationsCount(eventId!);
      pendingCount.value = data['pendientes'] ?? 0;
      pendingLimit.value = data['limite'] ?? 0;
      print('Pending count loaded: ${pendingCount.value}/${pendingLimit.value}');
    } catch (e) {
      print('Error loading pending count: $e');
    }
  }

  /// Carga la lista de usuarios no elegibles
  Future<void> loadNonEligibleUsers() async {
    if (eventId == null) return;

    try {
      isLoadingNonEligible.value = true;
      final nonEligibleMap = await _invitationService.getNonEligibleUsers(eventId!);
      nonEligibleUsers.assignAll(nonEligibleMap);
      print('Non-eligible users loaded: ${nonEligibleMap.length}');
    } catch (e) {
      print('Error loading non-eligible users: $e');
      // No mostramos error al usuario, solo lo logueamos
    } finally {
      isLoadingNonEligible.value = false;
    }
  }

  /// Busca usuarios con debounce
  Future<void> searchUsers(String query) async {
    searchQuery.value = query;
    
    if (query.trim().isEmpty) {
      searchResults.clear();
      error.value = '';
      return;
    }

    try {
      isSearching.value = true;
      error.value = '';
      
      final results = await _invitationService.searchUsersDebounced(query);
      searchResults.assignAll(results);
      
      if (results.isEmpty) {
        error.value = 'No se encontraron usuarios';
      }
    } catch (e) {
      error.value = e.toString().replaceAll('Exception: ', '');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  /// Verifica si un usuario es elegible para ser invitado
  bool isEligible(int userId) {
    return !nonEligibleUsers.containsKey(userId);
  }

  /// Obtiene el label para mostrar según el tipo de usuario no elegible
  String getNonEligibleLabel(int userId) {
    final tipo = nonEligibleUsers[userId];
    if (tipo == null) return '';
    
    switch (tipo) {
      case 'participante':
        return 'Participante';
      case 'pendiente_asistente':
        return 'Pendiente';
      default:
        return 'No disponible';
    }
  }

  /// Alterna la selección de un usuario (solo si es elegible)
  void toggleSelection(int userId) {
    // No permitir seleccionar usuarios no elegibles
    if (!isEligible(userId)) {
      final label = getNonEligibleLabel(userId);
      Get.snackbar(
        'Usuario no disponible',
        label == 'Participante' 
            ? 'Este usuario ya es participante del evento'
            : 'Este usuario ya tiene una invitación pendiente',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Verificar límite de invitaciones
    if (!selectedUserIds.contains(userId)) {
      final currentPending = pendingCount.value;
      final selectedCount = selectedUserIds.length;
      final limit = pendingLimit.value;
      
      if (limit > 0 && (currentPending + selectedCount + 1) > limit) {
        Get.snackbar(
          'Límite alcanzado',
          'No puedes enviar más invitaciones. El límite es $limit pendientes.',
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
        return;
      }
    }

    if (selectedUserIds.contains(userId)) {
      selectedUserIds.remove(userId);
    } else {
      selectedUserIds.add(userId);
    }
  }

  /// Verifica si un usuario está seleccionado
  bool isSelected(int userId) {
    return selectedUserIds.contains(userId);
  }

  /// Envía las invitaciones
  Future<void> sendInvitations() async {
    if (selectedUserIds.isEmpty) {
      Get.snackbar(
        'Nada que enviar',
        'Selecciona al menos un usuario',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (eventId == null) {
      Get.snackbar(
        'Error',
        'No se ha especificado el evento',
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    try {
      isLoading.value = true;
      
      await _invitationService.sendInvites(
        eventId: eventId!,
        userIds: selectedUserIds.toList(),
      );

      Get.snackbar(
        'Éxito',
        'Invitaciones enviadas a ${selectedUserIds.length} usuario(s)',
        snackPosition: SnackPosition.TOP,
      );

      // Limpiar estado después de enviar
      selectedUserIds.clear();
      searchQuery.value = '';
      searchResults.clear();
      searchController.clear();
      
      // Recargar datos
      await Future.wait([
        loadNonEligibleUsers(),
        loadPendingCount(),
      ]);

    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    _invitationService.onClose();
    super.onClose();
  }
}
