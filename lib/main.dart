import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'configs/env.dart';
import 'configs/theme.dart';
import 'services/session_service.dart';

// NUEVO: inyectamos el servicio y el controlador
import 'services/event_service.dart';
import 'controllers/event_controller.dart';

// Páginas
import 'pages/welcome/welcome_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/sign_in/sign_in_page.dart';
import 'pages/home/home_page.dart';
import 'pages/event_details/event_details_page.dart';

import 'pages/invite/invite_users_page.dart';
import 'pages/invite/invite_list_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Env.load();
  await SessionService().init();

  // Inyección de dependencias para GetX
  Get.put(EventService());
  Get.put(EventController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final TextTheme baseTextTheme = Typography.material2021().englishLike;
    final MaterialTheme materialTheme = MaterialTheme(baseTextTheme);

    return GetMaterialApp(
      title: 'EventMaster',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: ThemeMode.system,
      initialRoute: '/welcome',
      getPages: [
        GetPage(name: '/invite-users', page: () => const InviteUsersPage()),
        GetPage(name: '/invite-list', page: () => const InviteListPage()),
        GetPage(name: '/welcome', page: () => WelcomePage()),
        GetPage(name: '/sign-up', page: () => SignUpPage()),
        GetPage(name: '/sign-in', page: () => SignInPage()),
        GetPage(name: '/home', page: () => HomePage()),
        // 👇 Ruta corregida: recibe un int (eventId)
        GetPage(
          name: '/event-details',
          page: () {
            final int id = (Get.arguments as int?) ?? 0;
            return EventDetailsPage(eventId: id);
          },
        ),
      ],
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
