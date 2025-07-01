import 'package:flutter/material.dart';
import 'presentation/pages/public/splash_screen.dart';
import 'presentation/pages/public/landing_page.dart';
import 'presentation/pages/public/login_page.dart';
import 'presentation/pages/public/register_type_selection_page.dart';
import 'presentation/pages/public/register_owner_page.dart';
import 'presentation/pages/public/register_veterinarian_page.dart';
import 'presentation/pages/public/email_verification_page.dart';
import 'presentation/pages/owner/dashboard/owner_dashboard_page.dart';
import 'presentation/pages/veterinarian/dashboard/veterinarian_dashboard_page.dart';
import 'presentation/widgets/common/bottom_navigation_bar.dart';

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
        '/email-verification': (context) => const EmailVerificationPage(),
        '/professional-verification': (context) => const Placeholder(),
        '/reset-password': (context) => const Placeholder(),
        '/dashboard': (context) => const DashboardWrapper(),
        '/dashboard/owner': (context) => const MainScreenOwner(),
        '/dashboard/veterinarian': (context) => const MainScreenVeterinarian(),
      },
    );
  }
}

class DashboardWrapper extends StatelessWidget {
  const DashboardWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isVeterinarian = true; // Cambiar a true para probar veterinario

    // ignore: dead_code
    return isVeterinarian
        // ignore: dead_code
        ? const MainScreenVeterinarian()
        : const MainScreenOwner();
  }
}

// Screen principal para dueños con navegación
class MainScreenOwner extends StatefulWidget {
  const MainScreenOwner({super.key});

  @override
  State<MainScreenOwner> createState() => _MainScreenOwnerState();
}

class _MainScreenOwnerState extends State<MainScreenOwner> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const OwnerDashboardPage(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        isVeterinarian: false,
      ),
    );
  }
}

class MainScreenVeterinarian extends StatefulWidget {
  const MainScreenVeterinarian({super.key});

  @override
  State<MainScreenVeterinarian> createState() => _MainScreenVeterinarianState();
}

class _MainScreenVeterinarianState extends State<MainScreenVeterinarian> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const VeterinarianDashboardPage(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
    const Placeholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        isVeterinarian: true,
      ),
    );
  }
}
