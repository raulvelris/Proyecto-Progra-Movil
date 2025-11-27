import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'profile_controller.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: colorScheme.primary,
            ),
          );
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // Profile Picture or Initials
              Builder(
                builder: (context) {
                  final photoUrl = controller.profilePicture;
                  ImageProvider? imageProvider;

                  if (photoUrl != null && photoUrl.isNotEmpty) {
                    if (photoUrl.startsWith('data:image')) {
                      try {
                        final base64String = photoUrl.split(',').last;
                        imageProvider = MemoryImage(base64Decode(base64String));
                      } catch (e) {
                        print('Error decoding base64 image: $e');
                      }
                    } else {
                      imageProvider = NetworkImage(photoUrl);
                    }
                  }

                  return imageProvider != null
                      ? CircleAvatar(
                          radius: 50,
                          backgroundImage: imageProvider,
                          onBackgroundImageError: (_, __) {},
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.transparent,
                            ),
                          ),
                        )
                      : CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Text(
                            controller.initials,
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onPrimaryContainer,
                              letterSpacing: 1,
                            ),
                          ),
                        );
                }
              ),
              const SizedBox(height: 20),
              Text(
                controller.fullName,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                controller.email,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 40),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildMenuItem(
                      title: 'Editar Perfil',
                      onTap: () async {
                        await Get.toNamed('/edit-profile-options');
                        // Recargar perfil al volver
                        controller.loadProfile();
                      },
                      showDivider: true,
                      colorScheme: colorScheme,
                    ),
                    _buildMenuItem(
                      title: 'Cerrar sesión',
                      onTap: () {
                        controller.sessionService.logout();
                        Get.offAllNamed('/welcome');
                      },
                      showDivider: true,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required VoidCallback onTap,
    required bool showDivider,
    required ColorScheme colorScheme,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: colorScheme.onSurfaceVariant,
          ),
      ],
    );
  }
}