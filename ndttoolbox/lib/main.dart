import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'firebase_options.dart';
import 'screens/home_screen_updated.dart' as updated;
import 'screens/exposure_calculator_screen.dart';
import 'screens/geometric_unsharpness_screen.dart';
import 'screens/exposure_correction_screen.dart';
import 'screens/radioactive_decay_screen.dart';
import 'screens/safety_barrier_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/device_management_screen.dart';
import 'screens/film_development_screen.dart';
import 'screens/overtime_tracking_screen.dart';
import 'screens/bath_tracking_screen.dart';
import 'providers/app_provider.dart';
import 'providers/ndt_calculator_provider.dart';
import 'providers/device_provider.dart';
import 'utils/theme.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase'i initialize et
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  // Notification service'i non-blocking olarak initialize et
  NotificationService().initialize().then((_) {
    print('Notification service initialized');

    // Permission request'i de background'da yap
    NotificationService().requestPermissions().then((hasPermission) {
      print('Notification permission result: $hasPermission');
    }).catchError((e) {
      print('Permission request error: $e');
    });
  }).catchError((e) {
    print('Error initializing notifications: $e');
  });

  runApp(const NDTCalculatorApp());
}

class NDTCalculatorApp extends StatelessWidget {
  const NDTCalculatorApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => NDTCalculatorProvider()),
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, child) {
          return MaterialApp(
            title: 'NDT Toolbox',
            debugShowCheckedModeBanner: false,
            navigatorKey: NotificationService.navigatorKey,
            navigatorObservers: [observer],

            // Localization desteği
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('tr', 'TR'), // Türkçe
              Locale('en', 'US'), // İngilizce
            ],

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                appProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const updated.HomeScreen(),
            routes: {
              '/home': (context) => const updated.HomeScreen(),
              '/exposure': (context) => const ExposureCalculatorScreen(),
              '/geometric': (context) => const GeometricUnsharpnessScreen(),
              '/correction': (context) => const ExposureCorrectionScreen(),
              '/decay': (context) => const RadioactiveDecayScreen(),
              '/safety': (context) => const SafetyBarrierScreen(),
              '/settings': (context) => const SettingsScreen(),
              '/film-development': (context) => const FilmDevelopmentScreen(),
              '/overtime': (context) => const OvertimeTrackingScreen(),
              '/bath-tracking': (context) => const BathTrackingScreen(),
              DeviceManagementScreen.routeName: (context) =>
                  const DeviceManagementScreen(),
            },
          );
        },
      ),
    );
  }
}
