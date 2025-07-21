import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../interceptors/auth_interceptor.dart';
import '../services/user_service.dart';
import '../../data/datasources/auth/auth_remote_datasource.dart';
import '../../data/datasources/user/user_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../data/datasources/pet/pet_remote_datasource.dart';
import '../../data/repositories/pet_repository_impl.dart';
import '../../domain/repositories/pet_repository.dart';
import '../../domain/usecases/pet/get_pets_usecase.dart';
import '../../domain/usecases/pet/add_pet_usecase.dart';
import '../../domain/usecases/pet/update_pet_usecase.dart';
import '../../domain/usecases/pet/delete_pet_usecase.dart';
import '../../presentation/blocs/pet/pet_bloc.dart';
import '../../data/datasources/vet/vet_remote_datasource.dart';
import '../../data/datasources/appointment/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repository_impl.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../../domain/usecases/appointment/get_upcoming_appointments_usecase.dart';
import '../../presentation/blocs/appointment/appointment_bloc.dart';
import '../../data/datasources/medical_records/medical_records_remote_datasource.dart';
import '../../data/repositories/medical_records_repository_impl.dart';
import '../../domain/repositories/medical_records_repository.dart';
import '../../domain/usecases/medical_records/get_medical_records_usecase.dart';
import '../../presentation/blocs/medical_records/medical_records_bloc.dart';
import '../../domain/usecases/medical_records/get_vaccinations_usecase.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  final gatewayDio = Dio();
  gatewayDio.options.connectTimeout = const Duration(minutes: 5);
  gatewayDio.options.sendTimeout = const Duration(minutes: 5);
  gatewayDio.options.receiveTimeout = const Duration(minutes: 5);
  gatewayDio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  gatewayDio.interceptors.add(AuthInterceptor());

  sl.registerLazySingleton<Dio>(() => gatewayDio);

  sl.registerLazySingleton<ApiClient>(() => ApiClient(dio: sl<Dio>()));
  sl.registerLazySingleton<UserService>(() => UserService());

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<PetRemoteDataSource>(
    () => PetRemoteDataSourceImpl(dio: sl<Dio>()),
  );

  sl.registerLazySingleton<VetRemoteDataSource>(
    () => VetRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AppointmentRemoteDataSource>(
    () => AppointmentRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<MedicalRecordsRemoteDataSource>(
    () => MedicalRecordsRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(remoteDataSource: sl<PetRemoteDataSource>()),
  );

  sl.registerLazySingleton<AppointmentRepository>(
    () => AppointmentRepositoryImpl(
      remoteDataSource: sl<AppointmentRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton<MedicalRecordsRepository>(
    () => MedicalRecordsRepositoryImpl(
      remoteDataSource: sl<MedicalRecordsRemoteDataSource>(),
    ),
  );

  sl.registerLazySingleton(
    () => LoginUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => LogoutUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => RegisterUseCase(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton(
    () => GetPetsUseCase(repository: sl<PetRepository>()),
  );
  sl.registerLazySingleton(
    () => AddPetUseCase(repository: sl<PetRepository>()),
  );
  sl.registerLazySingleton(
    () => UpdatePetUseCase(repository: sl<PetRepository>()),
  );
  sl.registerLazySingleton(
    () => DeletePetUseCase(repository: sl<PetRepository>()),
  );

  sl.registerLazySingleton(
    () => GetUpcomingAppointmentsUseCase(sl<AppointmentRepository>()),
  );
  sl.registerLazySingleton(
    () => GetPastAppointmentsUseCase(sl<AppointmentRepository>()),
  );
  sl.registerLazySingleton(
    () => GetAllAppointmentsUseCase(sl<AppointmentRepository>()),
  );

  sl.registerLazySingleton(
    () => GetMedicalRecordsUseCase(sl<MedicalRecordsRepository>()),
  );
  sl.registerLazySingleton(
    () => GetVaccinationsUseCase(sl<MedicalRecordsRepository>()),
  );

  sl.registerFactory(
    () => PetBloc(
      petRepository: sl<PetRepository>(),
      appointmentRepository: sl<AppointmentRepository>(),
    ),
  );
  sl.registerFactory(
    () => AppointmentBloc(
      getUpcomingAppointmentsUseCase: sl<GetUpcomingAppointmentsUseCase>(),
      getPastAppointmentsUseCase: sl<GetPastAppointmentsUseCase>(),
      getAllAppointmentsUseCase: sl<GetAllAppointmentsUseCase>(),
    ),
  );

  sl.registerFactory(
    () => MedicalRecordsBloc(
      getMedicalRecordsUseCase: sl<GetMedicalRecordsUseCase>(),
      getVaccinationsUseCase: sl<GetVaccinationsUseCase>(),
    ),
  );
}
