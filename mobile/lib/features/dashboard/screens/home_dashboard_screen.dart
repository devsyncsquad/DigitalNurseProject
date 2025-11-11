import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/providers/caregiver_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/lifestyle_provider.dart';
import '../../../core/providers/document_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/care_context_provider.dart';
import '../../../core/models/user_model.dart';
import '../widgets/adherence_streak_card.dart';
import '../widgets/medicine_reminder_section.dart';
import '../widgets/vitals_section.dart';
import '../widgets/documents_section.dart';
import '../widgets/diet_exercise_section.dart';
import '../widgets/caregiver_dashboard_view.dart';

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Defer data loading until after the build phase
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData(force: true);
    });
  }

  String? _lastLoadedContextKey;

  Future<void> _loadData({bool force = false}) async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isCaregiver = currentUser?.role == UserRole.caregiver;

    String? targetUserId = currentUser?.id;
    String? elderUserId;

    if (isCaregiver) {
      final careContext = context.read<CareContextProvider>();
      await careContext.ensureLoaded();
      if (!mounted) {
        return;
      }
      targetUserId = careContext.selectedElderId;
      elderUserId = targetUserId;

      if (targetUserId == null) {
        setState(() {
          _lastLoadedContextKey = null;
        });
        return;
      }
    }

    if (targetUserId == null) {
      return;
    }

    final contextKey = elderUserId ?? targetUserId;
    if (!force && contextKey == _lastLoadedContextKey) {
      return;
    }

    _lastLoadedContextKey = contextKey;

    await Future.wait([
      context
          .read<MedicationProvider>()
          .loadMedicines(targetUserId, elderUserId: elderUserId),
      context
          .read<HealthProvider>()
          .loadVitals(targetUserId, elderUserId: elderUserId),
      if (!isCaregiver)
        context.read<CaregiverProvider>().loadCaregivers(targetUserId),
      context.read<NotificationProvider>().loadNotifications(),
      context
          .read<LifestyleProvider>()
          .loadAll(targetUserId, elderUserId: elderUserId),
      context
          .read<DocumentProvider>()
          .loadDocuments(targetUserId, elderUserId: elderUserId),
    ]);
    if (!mounted) {
      return;
    }
  }

  void _showLanguageDialog(BuildContext buildContext) {
    showDialog(
      context: buildContext,
      builder: (BuildContext dialogContext) {
        return Consumer<LocaleProvider>(
          builder: (context, localeProvider, child) {
            return AlertDialog(
              title: Text('settings.language.title'.tr()),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: localeProvider.localeOptions.map((option) {
                  final isSelected = localeProvider.locale == option.locale;
                  return ListTile(
                    leading: Icon(
                      FIcons.languages,
                      color: isSelected
                          ? context.theme.colors.primary
                          : context.theme.colors.mutedForeground,
                    ),
                    title: Text(
                      option.name,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? context.theme.colors.primary
                            : context.theme.colors.foreground,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(
                            FIcons.check,
                            color: context.theme.colors.primary,
                          )
                        : null,
                    onTap: () async {
                      await localeProvider.setLocale(option.locale);
                      // Use the outer buildContext which is in the EasyLocalization widget tree
                      buildContext.setLocale(option.locale);
                      if (dialogContext.mounted) {
                        Navigator.of(dialogContext).pop();
                      }
                    },
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final careContextProvider = context.watch<CareContextProvider>();
    final notificationProvider = context.watch<NotificationProvider>();

    final user = authProvider.currentUser;
    final unreadNotifications = notificationProvider.unreadCount;
    final isCaregiver = user?.role == UserRole.caregiver;
    final headerTitle = isCaregiver
        ? Text(
            'Caregiver Dashboard',
            style: context.theme.typography.xl.copyWith(
              fontWeight: FontWeight.bold,
            ),
          )
        : Text(
            'dashboard.hello'.tr(
              namedArgs: {'name': user?.name ?? 'dashboard.user'.tr()},
            ),
          );

    return FScaffold(
      header: FHeader(
        title: headerTitle,
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.languages),
            onPress: () => _showLanguageDialog(context),
          ),
          FHeaderAction(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(FIcons.bell),
                if (unreadNotifications > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppTheme.getErrorColor(context),
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        unreadNotifications > 9 ? '9+' : '$unreadNotifications',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPress: () => context.push('/notifications'),
          ),
        ],
      ),
      child: RefreshIndicator(
        onRefresh: () => _loadData(force: true),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: isCaregiver
              ? CaregiverDashboardView(
                  careContext: careContextProvider,
                  onRecipientSelected: (elderId) {
                    careContextProvider.selectRecipient(elderId);
                    _loadData(force: true);
                  },
                )
              : _PatientDashboardContent(
                  onRefreshRequested: () => _loadData(force: true),
                ),
        ),
      ),
    );
  }
}

class _PatientDashboardContent extends StatelessWidget {
  final VoidCallback onRefreshRequested;

  const _PatientDashboardContent({
    required this.onRefreshRequested,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer<MedicationProvider>(
          builder: (context, medicationProvider, child) {
            return AdherenceStreakCard(
              streakDays: medicationProvider.adherenceStreak,
              adherencePercentage: medicationProvider.adherencePercentage,
            );
          },
        ),
        SizedBox(height: 24.h),
        const MedicineReminderSection(),
        SizedBox(height: 16.h),
        const VitalsSection(),
        SizedBox(height: 16.h),
        const DocumentsSection(),
        SizedBox(height: 16.h),
        const DietExerciseSection(),
      ],
    );
  }
}
