
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kalyanboss/config/constants.dart';
import 'package:kalyanboss/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:kalyanboss/features/base/presentation/bloc/base_bloc.dart';
import 'package:kalyanboss/services/notification_manager.dart';
import 'package:kalyanboss/utils/di/service_locator.dart' as di;
import 'package:responsive_framework/responsive_framework.dart';
import 'config/routes/routes.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'config/theme/theme.dart';
import 'features/base/presentation/bloc/theme_bloc.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await di.init();

  final notificationService = di.sl<NotificationService>();
  final authBloc = di.sl<AuthBloc>();
  await notificationService.init(authBloc: authBloc);
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        // Trigger LoadTheme immediately to get saved preferences from SharedPreferences
        BlocProvider(create: (context) => di.sl<ThemeBloc>()..add(LoadTheme())),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: AppStrings.appName,
            debugShowCheckedModeBanner: false,

            // Link to your external theme file
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,

            // Now 'state' is available from BlocBuilder
            themeMode: state.themeMode,

            routerConfig: AppRouter.router,
            builder: (context, widget) => ResponsiveBreakpoints.builder(
              child: ClampingScrollWrapper.builder(context, widget!),
              breakpoints: [
                const Breakpoint(start: 0, end: 450, name: MOBILE),
                const Breakpoint(start: 451, end: 800, name: TABLET),
                const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
              ],
            ),
          );
        },
      ),
    );
  }
}