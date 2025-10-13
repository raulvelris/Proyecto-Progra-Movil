import '/models/event.dart';
import '/models/resource.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'event_details_controller.dart';

class EventDetailsPage extends StatelessWidget {
  final EventDetailsController controller = Get.put(EventDetailsController());

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoading();
        }

        if (controller.error.value.isNotEmpty) {
          return _buildError(context);
        }

        if (controller.event.value == null) {
          return _buildEmpty(context);
        }

        return _buildContent(context);
      }),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Cargando evento...'),
        ],
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Detalles del Evento', style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              controller.error.value,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.loadEvent(),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text('Detalles del Evento', style: TextStyle(color: colorScheme.onPrimary)),
        backgroundColor: colorScheme.primary,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No se encontró el evento',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final event = controller.event.value!;
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onPrimary),
            onPressed: () => Get.back(),
          ),
          title: Text(
            event.title,
            style: TextStyle(
              color: colorScheme.onPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: colorScheme.primary,
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            background: event.image.isNotEmpty
                ? Image.asset(
                    event.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage(colorScheme);
                    },
                  )
                : _buildPlaceholderImage(colorScheme),
          ),
          pinned: true,
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            _buildBasicInfo(event, colorScheme),
            _buildMap(event, colorScheme),
            _buildDescription(event, colorScheme),
            _buildResources(event, colorScheme),
            _buildAttendanceButton(event, colorScheme),
            const SizedBox(height: 20),
          ]),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage(ColorScheme colorScheme) {
    return Container(
      color: colorScheme.primaryContainer,
      child: Icon(Icons.event, size: 60, color: colorScheme.onPrimaryContainer),
    );
  }

  Widget _buildBasicInfo(Event event, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datos básicos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            icon: Icons.calendar_today,
            text: _formatDate(event.startDate),
            colorScheme: colorScheme,
          ),
          _buildInfoItem(
            icon: Icons.access_time,
            text: '${_formatTime(event.startDate)} - ${_formatTime(event.endDate)}',
            colorScheme: colorScheme,
          ),
          if (event.location != null)
            _buildInfoItem(
              icon: Icons.location_on,
              text: event.location!.address,
              colorScheme: colorScheme,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text, required ColorScheme colorScheme}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap(Event event, ColorScheme colorScheme) {
    if (event.location == null) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ubicación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    event.location!.latitude,
                    event.location!.longitude,
                  ),
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('event_location'),
                    position: LatLng(
                      event.location!.latitude,
                      event.location!.longitude,
                    ),
                    infoWindow: InfoWindow(
                      title: event.title,
                      snippet: event.location!.address,
                    ),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDescription(Event event, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            event.description,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResources(Event event, ColorScheme colorScheme) {
    if (event.resources.isEmpty) {
      return Container();
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recursos',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          ...event.resources.map((resource) => _buildResourceItem(resource, colorScheme)).toList(),
        ],
      ),
    );
  }

  Widget _buildResourceItem(Resource resource, ColorScheme colorScheme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          resource.isPDF ? Icons.picture_as_pdf : Icons.video_library,
          color: resource.isPDF ? colorScheme.error : colorScheme.primary,
        ),
        title: Text(resource.name),
        subtitle: Text(resource.isPDF ? 'Documento PDF' : 'Enlace de video'),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: colorScheme.onSurface),
        onTap: () {
          if (resource.isPDF) {
            controller.openPdf(resource.url, resource.name);
          } else {
            controller.openVideo(resource.url);
          }
        },
      ),
    );
  }

  Widget _buildAttendanceButton(Event event, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => controller.toggleAttendance(),
          style: ElevatedButton.styleFrom(
            backgroundColor: event.isAttending ? colorScheme.error : colorScheme.primary,
            foregroundColor: event.isAttending ? colorScheme.onError : colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            event.isAttending ? 'Cancelar asistencia' : 'Confirmar asistencia',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}