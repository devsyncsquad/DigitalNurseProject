import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/register_screen.dart';
import '../features/auth/screens/email_verification_screen.dart';
import '../features/onboarding/screens/welcome_screen.dart';
import '../features/onboarding/screens/profile_setup_screen.dart';
import '../features/onboarding/screens/subscription_plans_screen.dart';
import '../features/dashboard/screens/main_navigation_screen.dart';
import '../features/medication/screens/add_medicine_screen.dart';
import '../features/medication/screens/medicine_detail_screen.dart';
import '../features/health/screens/add_vital_screen.dart';
import '../features/health/screens/health_trends_screen.dart';
import '../features/caregiver/screens/add_caregiver_screen.dart';
import '../features/caregiver/screens/invitation_accept_screen.dart';
import '../features/lifestyle/screens/diet_exercise_log_screen.dart';
import '../features/lifestyle/screens/add_meal_screen.dart';
import '../features/lifestyle/screens/add_workout_screen.dart';
import '../features/documents/screens/upload_document_screen.dart';
import '../features/documents/screens/document_viewer_screen.dart';
import '../features/profile/screens/settings_screen.dart';
import '../core/services/notification_test.dart';

final goRouter = GoRouter(
  initialLocation: '/welcome',
  redirect: (context, state) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isLoggedIn = authProvider.isLoggedIn;

    // Public routes that don't require authentication
    final publicRoutes = [
      '/welcome',
      '/login',
      '/register',
      '/email-verification',
      '/invitation-accept',
    ];

    final isPublicRoute = publicRoutes.any(
      (route) => state.matchedLocation.startsWith(route),
    );

    // If user is not logged in and trying to access a private route
    if (!isLoggedIn && !isPublicRoute) {
      return '/welcome';
    }

    // If user is logged in and on a public route, redirect to dashboard
    if (isLoggedIn && isPublicRoute) {
      return '/home';
    }

    return null;
  },
  routes: [
    // Authentication routes
    GoRoute(
      path: '/welcome',
      builder: (context, state) => const WelcomeScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/email-verification',
      builder: (context, state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return EmailVerificationScreen(email: email);
      },
    ),

    // Onboarding routes
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/subscription-plans',
      builder: (context, state) => const SubscriptionPlansScreen(),
    ),

    // Main navigation with bottom bar
    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 0),
    ),
    GoRoute(
      path: '/medications',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 1),
    ),
    GoRoute(
      path: '/health',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 2),
    ),
    GoRoute(
      path: '/documents',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 3),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const MainNavigationScreen(initialIndex: 4),
    ),

    // Medicine routes
    GoRoute(
      path: '/medicine/add',
      builder: (context, state) => const AddMedicineScreen(),
    ),
    GoRoute(
      path: '/medicine/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return MedicineDetailScreen(medicineId: id);
      },
    ),

    // Health/Vitals routes
    GoRoute(
      path: '/vitals/add',
      builder: (context, state) => const AddVitalScreen(),
    ),
    GoRoute(
      path: '/health/trends',
      builder: (context, state) => const HealthTrendsScreen(),
    ),

    // Caregiver routes
    GoRoute(
      path: '/caregiver/add',
      builder: (context, state) => const AddCaregiverScreen(),
    ),
    GoRoute(
      path: '/invitation-accept/:caregiverId',
      builder: (context, state) {
        final caregiverId = state.pathParameters['caregiverId']!;
        return InvitationAcceptScreen(caregiverId: caregiverId);
      },
    ),

    // Lifestyle routes
    GoRoute(
      path: '/lifestyle',
      builder: (context, state) => const DietExerciseLogScreen(),
    ),
    GoRoute(
      path: '/lifestyle/meal/add',
      builder: (context, state) => const AddMealScreen(),
    ),
    GoRoute(
      path: '/lifestyle/workout/add',
      builder: (context, state) => const AddWorkoutScreen(),
    ),

    // Document routes
    GoRoute(
      path: '/documents/upload',
      builder: (context, state) => const UploadDocumentScreen(),
    ),
    GoRoute(
      path: '/documents/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DocumentViewerScreen(documentId: id);
      },
    ),

    // Settings
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    // Notification Test (for debugging)
    GoRoute(
      path: '/notification-test',
      builder: (context, state) => const NotificationTestWidget(),
    ),
  ],
);
