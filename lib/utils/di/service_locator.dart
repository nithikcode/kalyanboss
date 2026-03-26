import 'package:get_it/get_it.dart';
import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:kalyanboss/features/auth/data/repository/auth_repository_impl.dart';
import 'package:kalyanboss/features/auth/domain/usecases/auth_use_cases.dart';
import 'package:kalyanboss/features/auth/domain/usecases/fetch_profile_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/fetch_settings_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/login_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/send_otp_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/sign_up_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/update_user_use_case.dart';
import 'package:kalyanboss/features/auth/domain/usecases/verify_use_case.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/base/data/datasource/base_remote_data_source.dart';
import 'package:kalyanboss/features/base/presentation/bloc/base_bloc.dart';
import 'package:kalyanboss/features/base/presentation/bloc/theme_bloc.dart';
import 'package:kalyanboss/features/betting/data/datasource/betting_remote_data_source.dart';
import 'package:kalyanboss/features/betting/data/repositoryimpl/betting_repository_impl.dart';
import 'package:kalyanboss/features/betting/domain/usecases/betting_use_cases.dart';
import 'package:kalyanboss/features/betting/domain/usecases/submit_bet_use_case.dart';
import 'package:kalyanboss/features/betting/presentation/bloc/unified_game_bloc.dart';
import 'package:kalyanboss/features/gali_desawar/presentation/bloc/gali_desawar_game_bloc.dart';
import 'package:kalyanboss/features/game/data/datasource/game_remote_data_source.dart';
import 'package:kalyanboss/features/game/data/repository/game_screen_repository_impl.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_all_market_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_bet_history_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_game_modes_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_market_result_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/fetch_transaction_use_case.dart';
import 'package:kalyanboss/features/game/domain/usecases/game_screen_use_cases.dart';
import 'package:kalyanboss/features/game/presentation/bloc/game_bloc.dart';
import 'package:kalyanboss/services/connection_manager.dart';
import 'package:kalyanboss/services/notification_manager.dart';
import 'package:kalyanboss/services/session_manager.dart';
import 'package:kalyanboss/services/socket_service.dart';
import 'package:kalyanboss/utils/network/network_api_service.dart';


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

  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => SocketService());
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
  sl.registerLazySingleton(() => FetchProfileUseCase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => UpdateUserUseCase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => FetchSettingsUseCase(authRepository: sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => AuthUseCases(
    loginUseCase: sl<LoginUseCase>(),
    verifyUseCase: sl<VerifyUseCase>(),
    signUpUseCase: sl<SignUpUseCase>(),
    sendOtpUseCase: sl<SendOtpUseCase>(),
    fetchProfileUseCase: sl<FetchProfileUseCase>(),
    updateUserUseCase: sl<UpdateUserUseCase>(),
    fetchSettingsUseCase: sl<FetchSettingsUseCase>()
  ));

  sl.registerLazySingleton(() => AuthBloc(
    authUseCases: sl<AuthUseCases>(),
    sessionManager: sl<SessionManager>(),
  ));


  // ============================================================================
  // BASE FEATURE
  // ============================================================================


  sl.registerLazySingleton(() => BaseBloc());



  // ============================================================================
  // Game FEATURE
  // ============================================================================
  sl.registerLazySingleton(() => GameRemoteDataSource(api: sl<NetworkServicesApi>()));
  sl.registerLazySingleton(() => GameScreenRepositoryImpl(gameRemoteDataSource: sl<GameRemoteDataSource>()));
  sl.registerLazySingleton(() => FetchAllMarketUseCase(gameScreenRepository: sl<GameScreenRepositoryImpl>()));
  sl.registerLazySingleton(() => FetchGameModesUseCase(gameScreenRepository: sl<GameScreenRepositoryImpl>()));
  sl.registerLazySingleton(() => FetchMarketResultUseCase(gameScreenRepository: sl<GameScreenRepositoryImpl>()));
  sl.registerLazySingleton(() => FetchBetHistoryUseCase(gameScreenRepository: sl<GameScreenRepositoryImpl>()));
  sl.registerLazySingleton(() => FetchTransactionUseCase(gameScreenRepository: sl<GameScreenRepositoryImpl>()));
  sl.registerLazySingleton(() => GameScreenUseCases( fetchAllMarketUseCase: sl<FetchAllMarketUseCase>(), fetchGameModesUseCase: sl<FetchGameModesUseCase>(), fetchMarketResultUseCase: sl<FetchMarketResultUseCase>(), fetchBetHistoryUseCase: sl<FetchBetHistoryUseCase>(), fetchTransactionUseCase: sl<FetchTransactionUseCase>()));

  sl.registerFactory(() => GameBloc(
    gameScreenUseCases: sl(),
    sessionManager: sl(),
  ));


  // ============================================================================
  // Unified Game FEATURE
  // ============================================================================
  sl.registerLazySingleton(() => BettingRemoteDataSource(api: sl<NetworkServicesApi>()));
  sl.registerLazySingleton(() => BettingRepositoryImpl(bettingRemoteDataSource: sl<BettingRemoteDataSource>()));
  sl.registerLazySingleton(() => SubmitBetUseCase(bettingRepository: sl<BettingRepositoryImpl>()));
  sl.registerLazySingleton(() => BettingUseCases(submitBetUseCase: sl<SubmitBetUseCase>()));

  sl.registerFactory(() => UnifiedGameBloc(
 bettingUseCases: sl(), authBloc: sl()
  ));

  // ============================================================================
  // Unified Game FEATURE
  // ============================================================================
  // sl.registerLazySingleton(() => BettingRemoteDataSource(api: sl<NetworkServicesApi>()));
  // sl.registerLazySingleton(() => BettingRepositoryImpl(bettingRemoteDataSource: sl<BettingRemoteDataSource>()));
  // sl.registerLazySingleton(() => SubmitBetUseCase(bettingRepository: sl<BettingRepositoryImpl>()));
  // sl.registerLazySingleton(() => BettingUseCases(submitBetUseCase: sl<SubmitBetUseCase>()));

  sl.registerFactory(() => GaliDesawarGameBloc(
 bettingUseCases: sl(), authBloc: sl()
  ));

}



