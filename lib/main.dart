import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'configs/env.dart';
import 'configs/theme.dart';
import 'services/session_service.dart';
import '/pages/welcome/welcome_page.dart';
import 'pages/welcome/splash_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/sign_in/sign_in_page.dart';
import 'pages/home/home_page.dart';
import '/pages/event_details/event_details_page.dart';
import 'pages/sign_up/verify_email_page.dart';
import 'pages/sign_up/account_activated_page.dart';
import 'pages/profile/edit_profile_options_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Env.load();
  
  await SessionService().init();
  
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
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashPage()),
        GetPage(name: '/welcome', page: () => WelcomePage()),
        GetPage(name: '/sign-up', page: () => SignUpPage()),
        GetPage(name: '/sign-in', page: () => SignInPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/event-details', page: () => EventDetailsPage()),
        GetPage(name: '/verify-email', page: () => const VerifyEmailPage()),
        GetPage(name: '/account-activated', page: () => const AccountActivatedPage()),
        GetPage(name: '/edit-profile-options', page: () => const EditProfilePage()),
      ],
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}