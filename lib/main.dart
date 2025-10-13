import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'configs/env.dart';
import 'configs/theme.dart';
import 'services/session_service.dart';
import '/pages/welcome/welcome_page.dart';
import 'pages/sign_up/sign_up_page.dart';
import 'pages/sign_in/sign_in_page.dart';
import 'pages/home/home_page.dart';
import '/pages/event_details/event_details_page.dart';

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
      initialRoute: '/welcome',
      getPages: [
        GetPage(name: '/welcome', page: () => WelcomePage()),
        GetPage(name: '/sign-up', page: () => SignUpPage()),
        GetPage(name: '/sign-in', page: () => SignInPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/event-details', page: () => EventDetailsPage()),
      ],
      home: WelcomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}