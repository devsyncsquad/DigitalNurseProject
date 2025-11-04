import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/routes.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/caregiver_provider.dart';
import 'core/providers/medication_provider.dart';
import 'core/providers/health_provider.dart';
import 'core/providers/lifestyle_provider.dart';
import 'core/providers/document_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Load saved locale preference
  final prefs = await SharedPreferences.getInstance();
  final savedLocaleCode = prefs.getString('app_locale') ?? 'en';
  final savedLocale = savedLocaleCode == 'ur' 
      ? const Locale('ur') 
      : const Locale('en');

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ur')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: savedLocale,
      child: const DigitalNurseApp(),
    ),
  );
}

class DigitalNurseApp extends StatelessWidget {
  const DigitalNurseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => CaregiverProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => HealthProvider()),
        ChangeNotifierProvider(create: (_) => LifestyleProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider()..initializeFCM(),
        ),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          // Wait for both providers to initialize
          if (!localeProvider.isInitialized || !themeProvider.isInitialized) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          // Sync EasyLocalization with LocaleProvider (only if different)
          if (context.locale != localeProvider.locale) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.setLocale(localeProvider.locale);
            });
          }

          return ScaffoldMessenger(
            child: MaterialApp.router(
              title: 'Digital Nurse',
              debugShowCheckedModeBanner: false,
              supportedLocales: context.supportedLocales,
              localizationsDelegates: context.localizationDelegates,
              locale: localeProvider.locale,
              theme: AppTheme.lightTheme.toApproximateMaterialTheme(),
              darkTheme: AppTheme.darkTheme.toApproximateMaterialTheme(),
              themeMode: themeProvider.themeMode,
              routerConfig: goRouter,
              builder: (context, child) {
                return ScreenUtilInit(
                  designSize: const Size(
                    375,
                    812,
                  ), // iPhone X/11 Pro design reference
                  minTextAdapt: true,
                  splitScreenMode: true,
                  builder: (context, child) {
                    // Use the appropriate theme based on current mode
                    final currentTheme = themeProvider.isDarkMode
                        ? AppTheme.darkTheme
                        : AppTheme.lightTheme;
                    return FAnimatedTheme(data: currentTheme, child: child!);
                  },
                  child: child!,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
