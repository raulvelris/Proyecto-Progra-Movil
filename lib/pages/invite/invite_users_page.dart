import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'invite_controller.dart';

class InviteUsersPage extends StatelessWidget {
  const InviteUsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Obtener el eventId de los argumentos
    final args = Get.arguments as Map<String, dynamic>?;
    final eventId = args?['eventId'] as int?;
    
    // Crear el controller con el eventId
    final controller = Get.put(
      InviteUsersController(eventId: eventId),
      tag: 'invite_${eventId ?? 0}',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invitar usuarios'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Campo de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                TextField(
                  controller: controller.searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por email o nombre',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (value) => controller.searchUsers(value),
                ),
                const SizedBox(height: 8),
                Obx(() {
                  final count = controller.pendingCount.value;
                  final limit = controller.pendingLimit.value;
                  
                  if (limit == 0) return const SizedBox.shrink();
                  
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline, 
                          size: 16, 
                          color: colorScheme.onSecondaryContainer
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Invitaciones pendientes: $count / $limit',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Resultados de búsqueda
          Expanded(
            child: Obx(() {
              // Mostrar indicador de carga
              if (controller.isSearching.value) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: colorScheme.primary),
                      const SizedBox(height: 16),
                      Text(
                        'Buscando usuarios...',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                );
              }

              // Mostrar mensaje de error
              if (controller.error.value.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, size: 64, color: colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        controller.error.value,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                );
              }

              // Mostrar mensaje inicial
              if (controller.searchQuery.value.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, size: 64, color: colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'Busca usuarios por email o nombre',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                );
              }

              // Mostrar resultados
              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 64, color: colorScheme.outline),
                      const SizedBox(height: 16),
                      Text(
                        'No se encontraron usuarios',
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                itemCount: controller.searchResults.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final user = controller.searchResults[index];
                  
                  return Obx(() {
                    final isSelected = controller.isSelected(user.id);
                    final isEligible = controller.isEligible(user.id);
                    
                    return ListTile(
                      enabled: isEligible,
                      leading: CircleAvatar(
                        backgroundColor: isEligible
                            ? colorScheme.primaryContainer.withOpacity(.35)
                            : colorScheme.surfaceContainerHighest,
                        child: Text(
                          user.initials,
                          style: TextStyle(
                            color: isEligible
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      title: Text(
                        user.name,
                        style: TextStyle(
                          color: isEligible
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      subtitle: Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.email,
                              style: TextStyle(
                                color: isEligible
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.outline,
                              ),
                            ),
                          ),
                          if (!isEligible)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                controller.getNonEligibleLabel(user.id),
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Icon(
                        isEligible
                            ? (isSelected
                                ? Icons.check_circle
                                : Icons.circle_outlined)
                            : Icons.lock_outline,
                        color: isEligible
                            ? (isSelected
                                ? colorScheme.primary
                                : colorScheme.outline)
                            : colorScheme.outline,
                      ),
                      onTap: () => controller.toggleSelection(user.id),
                    );
                  });
                },
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Obx(() {
            final selectedCount = controller.selectedUserIds.length;
            final isLoading = controller.isLoading.value;
            
            return ElevatedButton(
              onPressed: isLoading ? null : () => controller.sendInvitations(),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      selectedCount > 0
                          ? 'Enviar Invitación ($selectedCount)'
                          : 'Enviar Invitación',
                    ),
            );
          }),
        ),
      ),
    );
  }
}
