import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class LocationPickerController extends GetxController {
  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();
  
  // Estado
  final Rx<LatLng> selectedLocation = const LatLng(-12.0464, -77.0428).obs; // Default Lima
  final RxString selectedAddress = ''.obs;
  final RxList<dynamic> searchResults = <dynamic>[].obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingAddress = false.obs;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Si se pasan argumentos iniciales (lat, lng)
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args['lat'] != null && args['lng'] != null) {
        final lat = args['lat'] as double;
        final lng = args['lng'] as double;
        selectedLocation.value = LatLng(lat, lng);
        
        if (args['address'] != null && args['address'].toString().isNotEmpty) {
           selectedAddress.value = args['address'];
           searchController.text = args['address'];
        } else {
           // If no address provided but we have coords, try reverse geocoding immediately
           onMapTap(TapPosition(Offset.zero, Offset.zero), selectedLocation.value);
        }

        // Esperar un poco para mover el mapa porque el controlador puede no estar listo
        Future.delayed(const Duration(milliseconds: 500), () {
          mapController.move(selectedLocation.value, 15);
        });
      }
    }
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        searchPlaces(query);
      } else {
        searchResults.clear();
      }
    });
  }

  Future<void> searchPlaces(String query) async {
    try {
      isSearching.value = true;
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5&addressdetails=1');
      
      final response = await http.get(url, headers: {
        'User-Agent': 'EventMasterApp/1.0'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        searchResults.assignAll(data);
      }
    } catch (e) {
      print('Error searching places: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void selectSearchResult(dynamic result) {
    final lat = double.parse(result['lat']);
    final lon = double.parse(result['lon']);
    final displayName = result['display_name'];

    selectedLocation.value = LatLng(lat, lon);
    selectedAddress.value = displayName;
    searchController.text = displayName;
    searchResults.clear();
    
    mapController.move(selectedLocation.value, 15);
    FocusManager.instance.primaryFocus?.unfocus();
  }

  Future<void> onMapTap(TapPosition tapPosition, LatLng point) async {
    selectedLocation.value = point;
    searchResults.clear();
    FocusManager.instance.primaryFocus?.unfocus();
    
    // Reverse geocoding
    try {
      isLoadingAddress.value = true;
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?lat=${point.latitude}&lon=${point.longitude}&format=json');
      
      final response = await http.get(url, headers: {
        'User-Agent': 'EventMasterApp/1.0'
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final address = data['display_name'];
        selectedAddress.value = address;
        searchController.text = address;
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
      selectedAddress.value = '${point.latitude}, ${point.longitude}';
    } finally {
      isLoadingAddress.value = false;
    }
  }

  void confirmSelection() {
    Get.back(result: {
      'address': selectedAddress.value.isNotEmpty 
          ? selectedAddress.value 
          : '${selectedLocation.value.latitude}, ${selectedLocation.value.longitude}',
      'lat': selectedLocation.value.latitude,
      'lng': selectedLocation.value.longitude,
    });
  }
}
