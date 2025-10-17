import 'package:get/get.dart';

class InviteUsersController extends GetxController {
  final candidates = <String>['Aaron Lobo','Aaron Tello','Aaron Pérez','Harry'].obs;
  final selected = <String>{}.obs;

  void toggle(String name, bool v) {
    if (v) { selected.add(name); } else { selected.remove(name); }
  }

  Future<void> send() async {
    if (selected.isEmpty) {
      Get.snackbar('Nada que enviar', 'Selecciona al menos un usuario');
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
    Get.back();
    Get.snackbar('Invitaciones enviadas', '${selected.length} usuario(s)');
  }
}
