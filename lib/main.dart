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
import 'presentation/pages/owner/pets/my_pets_page.dart';
import 'presentation/pages/owner/pets/add_pet_page.dart';
import 'presentation/pages/owner/pets/pet_detail_page.dart';
import 'presentation/pages/owner/veterinarians/search_veterinarians_page.dart';
import 'presentation/pages/owner/veterinarians/veterinarians_list_page.dart';
import 'presentation/pages/owner/veterinarians/veterinarian_profile_page.dart';
import 'presentation/pages/owner/appointments/schedule_appointment_page.dart';
import 'presentation/pages/owner/appointments/my_appointments_page.dart';
import 'presentation/pages/owner/appointments/appointment_detail_page.dart';
import 'presentation/pages/veterinarian/schedule/my_schedule_page.dart';
import 'presentation/pages/veterinarian/appointments/appointment_detail_vet_page.dart';
import 'presentation/pages/owner/medical_records/medical_record_page.dart';
import 'presentation/pages/owner/medical_records/consultation_detail_page.dart';

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

        // Owner routes
        '/my-pets': (context) => const MyPetsPage(),
        '/add-pet': (context) => const AddPetPage(),
        '/pet-detail': (context) => const PetDetailPage(),
        '/search-veterinarians': (context) => const SearchVeterinariansPage(),
        '/veterinarians-list': (context) => const VeterinariansListPage(),
        '/veterinarian-profile': (context) => const VeterinarianProfilePage(),
        '/schedule-appointment': (context) => const ScheduleAppointmentPage(),
        '/my-appointments': (context) => const MyAppointmentsPage(),
        '/appointment-detail': (context) => const AppointmentDetailPage(),
        '/medical-record': (context) => const MedicalRecordPage(),
        '/consultation-detail': (context) => const ConsultationDetailPage(),

        // Veterinarian routes
        '/my-schedule': (context) => const MySchedulePage(),
        '/appointment-detail-vet':
            (context) => const AppointmentDetailVetPage(),
      },
    );
  }
}

class DashboardWrapper extends StatelessWidget {
  const DashboardWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isVeterinarian = false; // Cambiar a true para probar veterinario

    return isVeterinarian
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
    const MyPetsPage(),
    const SearchVeterinariansPage(),
    const MyAppointmentsPage(),
    const Placeholder(), // Profile page
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
    const MySchedulePage(), // Vista 26 - Agenda del veterinario
    const Placeholder(), // Patients list
    const Placeholder(), // Statistics
    const Placeholder(), // Settings
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
