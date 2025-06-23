import 'package:flutter/material.dart';
import 'presentation/pages/public/splash_screen.dart';
import 'presentation/pages/public/landing_page.dart';
import 'presentation/pages/public/login_page.dart';
import 'presentation/pages/public/register_type_selection_page.dart';
import 'presentation/pages/public/register_owner_page.dart';
import 'presentation/pages/public/register_veterinarian_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VetZoone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterTypeSelectionPage(),
        '/register/owner': (context) => const RegisterOwnerPage(),
        '/register/veterinarian': (context) => const RegisterVeterinarianPage(),
        '/email-verification': (context) => const Placeholder(),
        '/professional-verification': (context) => const Placeholder(),
        '/reset-password': (context) => const Placeholder(),
        '/dashboard': (context) => const Placeholder(),
      },
    );
  }
}
