import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'location_picker_controller.dart';

class LocationPickerPage extends StatelessWidget {
  const LocationPickerPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LocationPickerController());

    return Scaffold(
      body: Stack(
        children: [
          // Mapa
          Obx(() => FlutterMap(
            mapController: controller.mapController,
            options: MapOptions(
              initialCenter: controller.selectedLocation.value,
              initialZoom: 15,
              onTap: controller.onMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.eventmaster.app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: controller.selectedLocation.value,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          )),

          // Barra de búsqueda y resultados
          SafeArea(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Buscar ubicación...',
                      prefixIcon: IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Get.back(),
                      ),
                      suffixIcon: Obx(() => controller.isSearching.value
                          ? const Padding(
                              padding: EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              ),
                            )
                          : const Icon(Icons.search)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
                
                // Lista de resultados
                Obx(() {
                  if (controller.searchResults.isEmpty) return const SizedBox.shrink();
                  
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: controller.searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final result = controller.searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined, color: Colors.grey),
                          title: Text(
                            result['display_name'].toString().split(',')[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            result['display_name'],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                          onTap: () => controller.selectSearchResult(result),
                        );
                      },
                    ),
                  );
                }),
              ],
            ),
          ),

          // Botón de confirmar
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SafeArea(
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoadingAddress.value 
                    ? null 
                    : controller.confirmSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
                child: controller.isLoadingAddress.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Confirmar Ubicación',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}
