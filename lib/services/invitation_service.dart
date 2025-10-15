import 'dart:math';
import 'package:get/get.dart';
import '../models/invitation.dart';

class InvitationService extends GetxService {
  // Mantenemos un mapa reactivo: eventId -> lista reactiva de invitados
  final RxMap<int, RxList<Invitee>> _invitesByEvent = <int, RxList<Invitee>>{}.obs;

  // Pool de personas ficticias para buscar/invitar
  final List<Invitee> _peoplePool = [
    Invitee(id: 1, name: 'Aaron Lobo',    email: 'aaron.lobo@email.com'),
    Invitee(id: 2, name: 'Beatriz Silva', email: 'bea.silva@email.com'),
    Invitee(id: 3, name: 'Camila Ramos',  email: 'camila.r@email.com'),
    Invitee(id: 4, name: 'Diego Quispe',  email: 'd.quispe@email.com'),
    Invitee(id: 5, name: 'Elena Torres',  email: 'elena.t@email.com'),
    Invitee(id: 6, name: 'Fiorella Vega', email: 'fio.vega@email.com'),
    Invitee(id: 7, name: 'Gustavo León',  email: 'gus.leon@email.com'),
    Invitee(id: 8, name: 'Héctor Poma',   email: 'hpoma@email.com'),
    Invitee(id: 9, name: 'Iris Medina',   email: 'iris.m@email.com'),
  ];

  /// Devuelve la RxList de invitados para un evento (crea y siembra si no existe)
  RxList<Invitee> invitesRx(int eventId) {
    if (!_invitesByEvent.containsKey(eventId)) {
      _invitesByEvent[eventId] = _seed(eventId).obs;
    }
    return _invitesByEvent[eventId]!;
  }

  /// Búsqueda en el pool de personas (para "Invitar usuarios")
  List<Invitee> peoplePool([String query = '']) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return List.of(_peoplePool);
    return _peoplePool.where((p) => p.name.toLowerCase().contains(q)).toList();
  }

  Future<void> updateStatus({
    required int eventId,
    required int inviteeId,
    required InviteStatus status,
  }) async {
    final list = invitesRx(eventId);
    final idx = list.indexWhere((i) => i.id == inviteeId);
    if (idx != -1) {
      list[idx].status = status;
      list.refresh();
    }
  }

  Future<void> sendInvites({
    required int eventId,
    required List<int> inviteeIds,
  }) async {
    final list = invitesRx(eventId);
    final existingIds = list.map((e) => e.id).toSet();
    final toAdd = _peoplePool
        .where((p) => inviteeIds.contains(p.id) && !existingIds.contains(p.id))
        .map((p) => Invitee(id: p.id, name: p.name, email: p.email))
        .toList();
    list.addAll(toAdd);
    list.refresh();
  }

  // Siembra inicial con estados aleatorios, para que la lista no esté vacía
  List<Invitee> _seed(int eventId) {
    final rnd = Random(eventId);
    final base = [
      Invitee(id: 1, name: 'Aaron Lobo',    email: 'aaron.lobo@email.com'),
      Invitee(id: 2, name: 'Beatriz Silva', email: 'bea.silva@email.com'),
      Invitee(id: 3, name: 'Camila Ramos',  email: 'camila.r@email.com'),
    ];
    for (final p in base) {
      p.status = InviteStatus.values[rnd.nextInt(InviteStatus.values.length)];
    }
    return base;
  }
}
