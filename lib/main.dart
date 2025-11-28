import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'configs/env.dart';
import 'configs/theme.dart';
import 'services/session_service.dart';

// Servicios y controladores
import 'services/event_service.dart';
import 'controllers/event_controller.dart';

// Páginas
import 'pages/welcome/welcome_page.dart';
import 'pages/welcome/splash_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/sign_in/sign_in_page.dart';
import 'pages/home/home_page.dart';
import 'pages/event_details/event_details_page.dart';
import 'pages/sign_up/verify_email_page.dart';
import 'pages/sign_up/account_activated_page.dart';
import 'pages/profile/edit_profile_options_page.dart';
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
      themeMode: ThemeMode.light,
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/welcome', page: () => WelcomePage()),
        GetPage(name: '/sign-up', page: () => SignUpPage()),
        GetPage(name: '/sign-in', page: () => SignInPage()),
        GetPage(name: '/home', page: () => HomePage()),

        // Ruta con parámetro eventId
        GetPage(
          name: '/event-details',
          page: () {
            final args = Get.arguments as Map<String, dynamic>;
            return EventDetailsPage(eventId: args['eventId'] as int);
          },
        ),

        // Otras páginas
        GetPage(name: '/verify-email', page: () => const VerifyEmailPage()),
        GetPage(
          name: '/account-activated',
          page: () => const AccountActivatedPage(),
        ),
        GetPage(
          name: '/edit-profile-options',
          page: () => EditProfilePage(),
        ),
        GetPage(name: '/invite-users', page: () => const InviteUsersPage()),
        GetPage(name: '/invite-list', page: () => const InviteListPage()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
