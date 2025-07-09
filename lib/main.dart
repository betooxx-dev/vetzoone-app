import 'package:flutter/material.dart';
// Páginas públicas
import 'presentation/pages/public/splash_screen.dart';
import 'presentation/pages/public/landing_page.dart';
import 'presentation/pages/public/login_page.dart';
import 'presentation/pages/public/register_type_selection_page.dart';
import 'presentation/pages/public/register_owner_page.dart';
import 'presentation/pages/public/register_veterinarian_page.dart';
import 'presentation/pages/public/email_verification_page.dart';

// Dashboards y navegación
import 'presentation/pages/owner/dashboard/owner_dashboard_page.dart';
import 'presentation/pages/veterinarian/dashboard/veterinarian_dashboard_page.dart';
import 'presentation/widgets/common/bottom_navigation_bar.dart';

// Páginas del dueño
import 'presentation/pages/owner/pets/my_pets_page.dart';
import 'presentation/pages/owner/pets/add_pet_page.dart';
import 'presentation/pages/owner/pets/pet_detail_page.dart';
import 'presentation/pages/owner/veterinarians/search_veterinarians_page.dart';
import 'presentation/pages/owner/veterinarians/veterinarians_list_page.dart';
import 'presentation/pages/owner/veterinarians/veterinarian_profile_page.dart';
import 'presentation/pages/owner/appointments/schedule_appointment_page.dart';
import 'presentation/pages/owner/appointments/my_appointments_page.dart';
import 'presentation/pages/owner/appointments/appointment_detail_page.dart';
import 'presentation/pages/owner/medical_records/medical_record_page.dart';
import 'presentation/pages/owner/medical_records/consultation_detail_page.dart';
import 'presentation/pages/owner/medical_records/vaccination_history_page.dart';
import 'presentation/pages/owner/medical_records/active_treatments_page.dart';
import 'presentation/pages/common/notifications/notifications_page.dart';
import 'presentation/pages/owner/profile/owner_profile_page.dart';

// Páginas del veterinario
import 'presentation/pages/veterinarian/schedule/my_schedule_page.dart';
import 'presentation/pages/veterinarian/appointments/appointment_detail_vet_page.dart';
import 'presentation/pages/veterinarian/medical_records/create_medical_record_page.dart';
import 'presentation/pages/veterinarian/medical_records/prescribe_treatment_page.dart';
import 'presentation/pages/veterinarian/medical_records/register_vaccination_page.dart';
import 'presentation/pages/veterinarian/patients/patients_list_page.dart';
import 'presentation/pages/veterinarian/patients/patient_history_page.dart';
import 'presentation/pages/veterinarian/profile/professional_profile_page.dart';
import 'presentation/pages/veterinarian/schedule/configure_schedule_page.dart';
import 'presentation/pages/veterinarian/settings/vet_settings_page.dart';
import 'presentation/pages/veterinarian/analytics/statistics_page.dart';

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
        // Rutas públicas
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterTypeSelectionPage(),
        '/register/owner': (context) => const RegisterOwnerPage(),
        '/register/veterinarian': (context) => const RegisterVeterinarianPage(),
        '/email-verification': (context) => const EmailVerificationPage(),
        '/professional-verification': (context) => const Placeholder(),
        '/reset-password': (context) => const Placeholder(),

        // Dashboards principales
        '/dashboard': (context) => const DashboardWrapper(),
        '/dashboard/owner': (context) => const MainScreenOwner(),
        '/dashboard/veterinarian': (context) => const MainScreenVeterinarian(),

        // Rutas del dueño - Mascotas
        '/my-pets': (context) => const MyPetsPage(),
        '/add-pet': (context) => const AddPetPage(),
        '/pet-detail': (context) => const PetDetailPage(),

        // Rutas del dueño - Veterinarios
        '/search-veterinarians': (context) => const SearchVeterinariansPage(),
        '/veterinarians-list': (context) => const VeterinariansListPage(),
        '/veterinarian-profile': (context) => const VeterinarianProfilePage(),

        // Rutas del dueño - Citas
        '/schedule-appointment': (context) => const ScheduleAppointmentPage(),
        '/my-appointments': (context) => const MyAppointmentsPage(),
        '/appointment-detail': (context) => const AppointmentDetailPage(),

        // Rutas del dueño - Registros médicos
        '/medical-record': (context) => const MedicalRecordPage(),
        '/consultation-detail': (context) => const ConsultationDetailPage(),
        '/vaccination-history': (context) => const VaccinationHistoryPage(),
        '/active-treatments': (context) => const ActiveTreatmentsPage(),

        // Rutas del veterinario - Agenda
        '/my-schedule': (context) => const MySchedulePage(),
        '/appointment-detail-vet':
            (context) => const AppointmentDetailVetPage(),

        // Rutas del veterinario - Registros médicos
        '/create-medical-record': (context) => const CreateMedicalRecordPage(),
        '/prescribe-treatment': (context) => const PrescribeTreatmentPage(),
        '/register-vaccination': (context) => const RegisterVaccinationPage(),

        // Rutas del veterinario - Pacientes
        '/patients-list': (context) => const PatientsListPage(),
        '/patient-history': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          return PatientHistoryPage(patient: args);
        },

        // Rutas de notificaciones
        '/notifications': (context) => const NotificationsPage(),

        // Rutas de perfil
        '/owner-profile': (context) => const OwnerProfilePage(),
        '/professional-profile': (context) => const ProfessionalProfilePage(),

        // Rutas de configuración
        '/configure-schedule': (context) => const ConfigureSchedulePage(),
        '/vet-settings': (context) => const VetSettingsPage(),
        '/statistics': (context) => const StatisticsPage(),
      },
    );
  }
}

class DashboardWrapper extends StatelessWidget {
  const DashboardWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isVeterinarian = true; //true para probar veterinario

    return isVeterinarian
        ? const MainScreenVeterinarian()
        // ignore: dead_code
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
    const OwnerProfilePage(),
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

// Screen principal para veterinarios con navegación
class MainScreenVeterinarian extends StatefulWidget {
  const MainScreenVeterinarian({super.key});

  @override
  State<MainScreenVeterinarian> createState() => _MainScreenVeterinarianState();
}

class _MainScreenVeterinarianState extends State<MainScreenVeterinarian> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const VeterinarianDashboardPage(),
    const MySchedulePage(),
    const PatientsListPage(),
    const NotificationsPage(),
    const VetSettingsPage(),
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
