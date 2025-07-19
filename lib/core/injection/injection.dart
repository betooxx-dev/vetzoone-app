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

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Dio para Auth (puerto 3000)
  final authDio = Dio();
  // authDio.options.baseUrl = 'http://192.168.0.22:3000';
  authDio.options.baseUrl = 'http://192.168.0.22:3000';
  authDio.options.connectTimeout = const Duration(minutes: 5); // 2 minutos
  authDio.options.sendTimeout = const Duration(minutes: 5); // 2 minutos
  authDio.options.receiveTimeout = const Duration(minutes: 5); // 2 minutos
  authDio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  authDio.interceptors.add(AuthInterceptor());

  // Dio para Pets (puerto 3001)
  final petDio = Dio();
  petDio.options.connectTimeout = const Duration(minutes: 2); // 2 minutos
  petDio.options.sendTimeout = const Duration(minutes: 2); // 2 minutos
  petDio.options.receiveTimeout = const Duration(minutes: 2); // 2 minutos
  petDio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  petDio.interceptors.add(AuthInterceptor());

  // Registrar con nombres específicos y tipos explícitos
  sl.registerLazySingleton<Dio>(() => authDio, instanceName: 'authDio');
  sl.registerLazySingleton<Dio>(() => petDio, instanceName: 'petDio');

  // Core
  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(dio: sl<Dio>(instanceName: 'authDio')),
  );
  sl.registerLazySingleton<UserService>(() => UserService());

  // Auth Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // User Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Pet Data sources
  sl.registerLazySingleton<PetRemoteDataSource>(
    () => PetRemoteDataSourceImpl(dio: sl<Dio>(instanceName: 'petDio')),
  );

  // Vet Data sources
  sl.registerLazySingleton<VetRemoteDataSource>(
    () => VetRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  // Auth Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  // Pet Repositories
  sl.registerLazySingleton<PetRepository>(
    () => PetRepositoryImpl(remoteDataSource: sl<PetRemoteDataSource>()),
  );

  // Auth Use cases
  sl.registerLazySingleton(
    () => LoginUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => LogoutUseCase(repository: sl<AuthRepository>()),
  );
  sl.registerLazySingleton(
    () => RegisterUseCase(repository: sl<AuthRepository>()),
  );

  // Pet Use cases
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

  // Blocs
  sl.registerFactory(() => PetBloc(petRepository: sl<PetRepository>()));
}
