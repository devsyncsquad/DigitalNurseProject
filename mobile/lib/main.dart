import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'app/routes.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/caregiver_provider.dart';
import 'core/providers/medication_provider.dart';
import 'core/providers/health_provider.dart';
import 'core/providers/lifestyle_provider.dart';
import 'core/providers/document_provider.dart';
import 'core/providers/notification_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  runApp(const DigitalNurseApp());
}

class DigitalNurseApp extends StatelessWidget {
  const DigitalNurseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
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
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Wait for theme provider to initialize
          if (!themeProvider.isInitialized) {
            return const MaterialApp(
              home: Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return ScaffoldMessenger(
            child: MaterialApp.router(
              title: 'Digital Nurse',
              debugShowCheckedModeBanner: false,
              supportedLocales: FLocalizations.supportedLocales,
              localizationsDelegates: const [
                ...FLocalizations.localizationsDelegates,
              ],
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
