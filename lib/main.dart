import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/injection/injection.dart';
import 'core/storage/shared_preferences_helper.dart';
import 'core/services/image_picker_service.dart';

import 'domain/entities/veterinarian.dart';

import 'presentation/blocs/pet/pet_bloc.dart';
import 'presentation/blocs/pet/pet_event.dart';
import 'presentation/blocs/appointment/index.dart';

import 'presentation/pages/public/splash_screen.dart';
import 'presentation/pages/public/landing_page.dart';
import 'presentation/pages/public/login_page.dart';
import 'presentation/pages/public/register_type_selection_page.dart';
import 'presentation/pages/public/unified_register_page.dart';

import 'presentation/pages/owner/dashboard/owner_dashboard_page.dart';
import 'presentation/pages/veterinarian/dashboard/veterinarian_dashboard_page.dart';
import 'presentation/widgets/common/bottom_navigation_bar.dart';

import 'presentation/pages/owner/pets/my_pets_page.dart';
import 'presentation/pages/owner/pets/add_pet_page.dart';
import 'presentation/pages/owner/pets/edit_pet_page.dart';
import 'presentation/pages/owner/pets/pet_detail_page.dart';
import 'presentation/pages/owner/veterinarians/search_veterinarians_page.dart';
import 'presentation/pages/owner/veterinarians/veterinarians_list_page.dart';
import 'presentation/pages/owner/veterinarians/veterinarian_profile_page.dart';
import 'presentation/pages/owner/appointments/schedule_appointment_page.dart';
import 'presentation/pages/owner/appointments/my_appointments_page.dart';
import 'presentation/pages/owner/appointments/appointment_detail_page.dart';
import 'presentation/pages/owner/medical_records/medical_record_page.dart';
import 'presentation/pages/common/notifications/notifications_page.dart';
import 'presentation/pages/owner/profile/owner_profile_page.dart';

import 'presentation/pages/veterinarian/schedule/my_schedule_page.dart';
import 'presentation/pages/veterinarian/appointments/appointment_detail_vet_page.dart';
import 'presentation/pages/veterinarian/medical_records/create_medical_record_page.dart';
import 'presentation/pages/veterinarian/medical_records/prescribe_treatment_page.dart';
import 'presentation/pages/veterinarian/medical_records/register_vaccination_page.dart';
import 'presentation/pages/veterinarian/medical_records/edit_vaccination_page.dart';
import 'presentation/pages/veterinarian/patients/patients_list_page.dart';
import 'presentation/pages/veterinarian/patients/patient_history_page.dart';
import 'presentation/pages/veterinarian/profile/professional_profile_page.dart';
import 'presentation/pages/veterinarian/schedule/configure_schedule_page.dart';
import 'presentation/pages/veterinarian/settings/vet_settings_page.dart';
import 'presentation/pages/veterinarian/analytics/statistics_page.dart';
import 'domain/entities/pet.dart';
import 'data/models/pet/pet_model.dart';
import 'data/models/medical_records/vaccination_model.dart';
import 'data/models/medical_records/medical_record_with_treatments_model.dart';
import 'data/models/medical_records/treatment_model.dart';
import 'dart:async';
import 'package:intl/date_symbol_data_local.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() async {
  // Mantenemos el manejador de errores por si acaso, es una buena práctica.
  runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await initializeDateFormatting('es', null);

      await init();

      try {
        await ImagePickerService.cleanOldImages();
      } catch (e) {
        print('⚠️ Error durante la limpieza de archivos: $e');
      }

      runApp(const MyApp());
    },
    (error, stack) {
      print('==================== ERROR CAPTURADO ====================');
      print('MENSAJE DE ERROR ORIGINAL: $error');
      print('STACK TRACE DETALLADO: $stack');
      print('=======================================================');
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PetBloc>(create: (context) => sl<PetBloc>()),
        BlocProvider<AppointmentBloc>(
          create: (context) => sl<AppointmentBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'VetZoone',
        debugShowCheckedModeBanner: false,
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const AuthWrapper(),
        routes: {
          '/landing': (context) => const LandingPage(),
          '/login': (context) => const LoginPage(),
          '/register': (context) => const RegisterTypeSelectionPage(),
          '/register/owner':
              (context) => const UnifiedRegisterPage(userRole: 'PET_OWNER'),
          '/register/veterinarian':
              (context) => const UnifiedRegisterPage(userRole: 'VETERINARIAN'),
          '/professional-verification': (context) => const Placeholder(),
          '/reset-password': (context) => const Placeholder(),

          '/dashboard': (context) => const DashboardWrapper(),
          '/dashboard/owner': (context) => const MainScreenOwner(),
          '/dashboard/veterinarian':
              (context) => const MainScreenVeterinarian(),

          '/my-pets': (context) => const MyPetsPage(),
          '/add-pet': (context) => const AddPetPage(),
          '/edit-pet': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is Pet) {
              return EditPetPage(pet: args);
            }
            return _buildErrorScreen('Datos de mascota no válidos');
          },
          '/pet-detail': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is String) {
              return PetDetailPage(petId: args);
            }
            return _buildErrorScreen('ID de mascota no válido');
          },

          '/search-veterinarians': (context) => const SearchVeterinariansPage(),
          '/veterinarians-list': (context) => const VeterinariansListPage(),
          '/veterinarian-profile': (context) => const VeterinarianProfilePage(),

          '/schedule-appointment': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          Veterinarian? selectedVeterinarian;
          
          if (args != null) {
            if (args.containsKey('veterinarian')) {
              selectedVeterinarian = args['veterinarian'] as Veterinarian?;
            }
          }
          
          return MultiBlocProvider(
            providers: [
              BlocProvider<PetBloc>(
                create: (context) => sl<PetBloc>(),
              ),
              BlocProvider<AppointmentBloc>(
                create: (context) => sl<AppointmentBloc>(),
              ),
            ],
            child: ScheduleAppointmentPage(selectedVeterinarian: selectedVeterinarian),
          );
        },
          '/my-appointments': (context) => const MyAppointmentsPage(),
          '/appointment-detail': (context) => const AppointmentDetailPage(),

          '/medical-record': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is Map<String, dynamic>) {
              return MedicalRecordPage(
                petId: args['petId'],
                petName: args['petName'],
              );
            }
            return _buildErrorScreen(
              'Argumentos de historial médico no válidos',
            );
          },

          '/my-schedule': (context) => const MySchedulePage(),
          '/appointment-detail-vet':
              (context) => const AppointmentDetailVetPage(),

          '/create-medical-record': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is MedicalRecordWithTreatmentsModel) {
              return CreateMedicalRecordPage(medicalRecordToEdit: args);
            } else if (args is Map<String, dynamic>) {
              if (args.containsKey('medicalRecord')) {
                return CreateMedicalRecordPage(medicalRecordToEdit: args['medicalRecord']);
              }
            }
            return const CreateMedicalRecordPage();
          },
          '/prescribe-treatment': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is TreatmentModel) {
              return PrescribeTreatmentPage(treatmentToEdit: args);
            } else if (args is Map<String, dynamic>) {
              if (args.containsKey('treatmentToEdit')) {
                return PrescribeTreatmentPage(treatmentToEdit: args['treatmentToEdit']);
              }
            }
            return const PrescribeTreatmentPage();
          },
          '/register-vaccination': (context) => const RegisterVaccinationPage(),
          '/edit-vaccination': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is VaccinationModel) {
              return EditVaccinationPage(vaccination: args);
            }
            return _buildErrorScreen('Datos de vacuna no válidos');
          },

          '/patients-list': (context) => const PatientsListPage(),
          '/patient-history': (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            if (args is PetModel) {
              return PatientHistoryPage(patient: args);
            }
            return _buildErrorScreen('Datos de paciente no válidos');
          },

          '/notifications': (context) => const NotificationsPage(),

          '/owner-profile': (context) => const OwnerProfilePage(),
          '/professional-profile': (context) => const ProfessionalProfilePage(),

          '/configure-schedule': (context) => const ConfigureSchedulePage(),
          '/vet-settings': (context) => const VetSettingsPage(),
          '/statistics': (context) => const StatisticsPage(),
        },
      ),
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error de Navegación')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: SharedPreferencesHelper.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return FutureBuilder<String?>(
            future: SharedPreferencesHelper.getUserRole(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (roleSnapshot.data == 'PET_OWNER') {
                return const MainScreenOwner();
              } else if (roleSnapshot.data == 'VETERINARIAN') {
                return const MainScreenVeterinarian();
              }

              return const LoginPage();
            },
          );
        }

        return const SplashScreen();
      },
    );
  }
}

class DashboardWrapper extends StatelessWidget {
  const DashboardWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SharedPreferencesHelper.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == 'PET_OWNER') {
          return const MainScreenOwner();
        } else if (snapshot.data == 'VETERINARIAN') {
          return const MainScreenVeterinarian();
        }

        return const LoginPage();
      },
    );
  }
}

class MainScreenOwner extends StatefulWidget {
  const MainScreenOwner({super.key});

  @override
  State<MainScreenOwner> createState() => _MainScreenOwnerState();
}

class _MainScreenOwnerState extends State<MainScreenOwner> {
  int _currentIndex = 0;
  late final PetBloc petBloc;

  final List<Widget> _pages = [
    const OwnerDashboardPage(),
    const MyPetsPage(),
    const SearchVeterinariansPage(),
    const MyAppointmentsPage(),
    const OwnerProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    print('🏠 [MAIN-SCREEN] Inicializando MainScreenOwner...');
    petBloc = context.read<PetBloc>();
  }

  Future<void> _reloadPetsIfNeeded() async {
    if (_currentIndex == 0 || _currentIndex == 1) {
      final userId = await SharedPreferencesHelper.getUserId();
      if (userId != null && mounted) {
        petBloc.add(LoadPetsEvent(userId: userId));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          print('🏠 [MAIN-SCREEN] Navegando a tab $index');
          if (index == 2) {
            print('🏠 [MAIN-SCREEN] ⭐ Navegando a SearchVeterinariansPage');
          }
          setState(() {
            _currentIndex = index;
          });
          _reloadPetsIfNeeded();
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
    const MySchedulePage(),
    const PatientsListPage(),
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
