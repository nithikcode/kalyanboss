import 'package:get_it/get_it.dart';
import 'package:kalyanboss/features/auth/domain/usecases/send_otp_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/sign_up_use_case.dart';
import '../../config/constants.dart';
import '../../features/auth/data/datasource/auth_remote_data_source.dart';
import '../../features/auth/data/repository/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/auth_use_cases.dart';
import '../../features/auth/domain/usecases/login_use_case.dart';
import '../../features/auth/domain/usecases/verify_use_case.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/base/presentation/bloc/theme_bloc.dart';
import '../../services/connection_manager.dart';
import '../../services/notification_manager.dart';
import '../../services/session_manager.dart';
import '../../services/socket_service.dart';
import '../network/network_api_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ============================================================================
  // CORE SERVICES
  // ============================================================================

  // Session Manager (singleton)
  sl.registerLazySingleton<SessionManager>(() => SessionManager.instance);
  await sl<SessionManager>().initialize();

  // Network API Service
  sl.registerLazySingleton<NetworkServicesApi>(
        () => NetworkServicesApi(baseUrl: AppUrl.baseUrl),
  );

  sl.registerFactory(() => NotificationService());
  sl.registerFactory(() => SocketService());
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService());
  // ============================================================================
  // BASE / THEME FEATURE
  // ============================================================================

  // Register ThemeBloc as a LazySingleton
  // (Using LazySingleton ensures the same instance is used when
  // calling LoadTheme in main.dart and ToggleTheme in settings)
  sl.registerLazySingleton(() => ThemeBloc());


  // ============================================================================
  // AUTH FEATURE
  // ============================================================================
  sl.registerLazySingleton(() => AuthRemoteDataSource(api: sl<NetworkServicesApi>()));
  sl.registerLazySingleton(() => AuthRepositoryImpl(sl<AuthRemoteDataSource>()));
  sl.registerLazySingleton(() => LoginUseCase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => VerifyUseCase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => SignUpUseCase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => SendOtpUseCase(authRepository: sl<AuthRepositoryImpl>()));

  sl.registerLazySingleton(() => AuthUseCases(
    loginUseCase: sl<LoginUseCase>(),
    verifyUseCase: sl<VerifyUseCase>(),
    signUpUseCase: sl<SignUpUseCase>(), sendOtpUseCase: sl<SendOtpUseCase>(),
  ));

  sl.registerLazySingleton(() => AuthBloc(
    authUseCases: sl<AuthUseCases>(),
    sessionManager: sl<SessionManager>(),
  ));


}



