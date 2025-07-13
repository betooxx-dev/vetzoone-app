import 'package:get_it/get_it.dart';
import '../network/api_client.dart';
import '../services/user_service.dart';
import '../../data/datasources/auth/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';

final sl = GetIt.instance;

Future<void> setupInjection() async {
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  sl.registerLazySingleton<UserService>(() => UserService());

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: sl<ApiClient>()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl<AuthRemoteDataSource>()),
  );

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(repository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(repository: sl<AuthRepository>()),
  );
}
