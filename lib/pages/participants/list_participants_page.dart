import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/event_participants_service.dart';
import '../../services/session_service.dart';

class ListParticipantsPage extends StatefulWidget {
  final int eventId;
  final String eventName;

  const ListParticipantsPage({
    super.key,
    required this.eventId,
    required this.eventName,
  });

  @override
  State<ListParticipantsPage> createState() => _ListParticipantsPageState();
}

class _ListParticipantsPageState extends State<ListParticipantsPage> {
  final EventParticipantsService _participantsService =
      EventParticipantsService();
  final SessionService _sessionService = SessionService();

  List<Participant> _participants = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _isOrganizer = false;

  @override
  void initState() {
    super.initState();
    _loadParticipants();
  }

  Future<void> _loadParticipants() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final participants = await _participantsService.getEventParticipants(
        widget.eventId,
      );
      final isOrganizer = await _participantsService.isUserOrganizer(
        widget.eventId,
      );

      setState(() {
        _participants = participants;
        _isOrganizer = isOrganizer;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar participantes: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildAvatarImage(Participant participant, String displayName) {
    final foto = participant.fotoPerfil;

    if (foto != null && foto.isNotEmpty) {
      // data URL (base64)
      if (foto.startsWith('data:')) {
        try {
          final uriData = UriData.parse(foto);
          final bytes = uriData.contentAsBytes();
          return ClipOval(child: Image.memory(bytes, fit: BoxFit.cover));
        } catch (_) {
          // Si falla el parseo, caemos al fallback de iniciales
        }
      } else {
        // URL normal
        return ClipOval(
          child: Image.network(
            foto,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Text(
                  _getInitials(displayName),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              );
            },
          ),
        );
      }
    }

    // Fallback: iniciales
    return Center(
      child: Text(
        _getInitials(displayName),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Participantes',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Text(
              widget.eventName,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadParticipants,
            tooltip: 'Actualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadParticipants,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_participants.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay participantes aún',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Header stats
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${_participants.length}',
                  Colors.black,
                  Icons.people,
                  isTotal: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Organizador',
                  '${_participants.where((p) => p.rol.toLowerCase().contains('organizador')).length}',
                  Colors.red,
                  Icons.admin_panel_settings,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Asistente',
                  '${_participants.where((p) => p.rol.toLowerCase() == 'asistente').length}',
                  Colors.blue,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Participants list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadParticipants,
            color: Colors.black,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _participants.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final participant = _participants[i];
                return _buildParticipantCard(participant);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon, {
    bool isTotal = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isTotal ? color : color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isTotal ? color : color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: isTotal ? Colors.white : color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: isTotal ? Colors.white : color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : Colors.grey.shade700,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantCard(Participant participant) {
    final fullName = '${participant.nombre} ${participant.apellido}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : participant.correo;
    final currentUserId = _sessionService.userId;
    final isCurrentUser = currentUserId == participant.usuarioId.toString();

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrentUser ? Colors.black : Colors.grey.shade200,
              width: isCurrentUser ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Avatar con foto real si existe (URL o data:), o iniciales como fallback
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _getRoleColor(participant.rol),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: _getRoleColor(participant.rol).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: _buildAvatarImage(participant, displayName),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        participant.correo,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Delete button (only for organizers)
                if (_isOrganizer &&
                    !participant.rol.toLowerCase().contains('organizador') &&
                    !isCurrentUser)
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 24),
                    onPressed: () => _showDeleteConfirmation(participant),
                    tooltip: 'Eliminar participante',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
          ),
        ),

        // Floating badges at the top
        Positioned(
          top: 0,
          left: 16,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentUser) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'Tú',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              _buildFloatingRoleBadge(participant.rol),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingRoleBadge(String rol) {
    late final String label;
    late final Color bg, fg;
    late final IconData icon;

    final rolLower = rol.toLowerCase();

    if (rolLower.contains('organizador')) {
      label = 'Organizador';
      bg = Colors.red;
      fg = Colors.white;
      icon = Icons.admin_panel_settings;
    } else if (rolLower.contains('coorganizador')) {
      label = 'Co-org';
      bg = Colors.red;
      fg = Colors.white;
      icon = Icons.supervisor_account;
    } else {
      label = 'Asistente';
      bg = Colors.blue;
      fg = Colors.white;
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: bg.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String rol) {
    late final String label;
    late final Color bg, fg;
    late final IconData icon;

    final rolLower = rol.toLowerCase();

    if (rolLower.contains('organizador')) {
      label = 'Organizador';
      bg = Colors.purple.shade50;
      fg = Colors.purple.shade700;
      icon = Icons.admin_panel_settings;
    } else if (rolLower.contains('coorganizador')) {
      label = 'Co-org';
      bg = Colors.purple.shade50;
      fg = Colors.purple.shade700;
      icon = Icons.supervisor_account;
    } else {
      label = 'Asistente';
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade700;
      icon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: fg.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String rol) {
    final rolLower = rol.toLowerCase();
    if (rolLower.contains('organizador')) {
      return Colors.red;
    } else if (rolLower.contains('coorganizador')) {
      return Colors.red;
    } else {
      return Colors.blue;
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final a = parts.isNotEmpty ? parts.first : '';
    final b = parts.length > 1 ? parts.last : '';
    final i1 = a.isNotEmpty ? a[0] : '';
    final i2 = b.isNotEmpty ? b[0] : '';
    return (i1 + i2).toUpperCase();
  }

  void _showDeleteConfirmation(Participant participant) {
    final fullName = '${participant.nombre} ${participant.apellido}'.trim();
    final displayName = fullName.isNotEmpty ? fullName : participant.correo;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.red.shade700,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '¿Eliminar participante?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro de eliminar a este asistente del evento?',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getRoleColor(participant.rol),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _getInitials(displayName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            participant.rol,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esta acción no se puede deshacer.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteParticipant(participant);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Eliminar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteParticipant(Participant participant) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.black),
                  SizedBox(height: 16),
                  Text('Eliminando participante...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      final result = await _participantsService.deleteParticipant(
        widget.eventId,
        participant.usuarioId,
      );

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (result['success'] == true) {
        // Show success message
        Get.snackbar(
          'Éxito',
          result['message'] ?? 'Participante eliminado correctamente',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        // Reload participants list
        _loadParticipants();
      } else {
        // Show error message
        Get.snackbar(
          'Error',
          result['message'] ?? 'Error al eliminar participante',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 4),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      // Show error message
      Get.snackbar(
        'Error',
        'Error: $e',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
