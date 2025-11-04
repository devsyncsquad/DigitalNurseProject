import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
import '../widgets/adherence_streak_card.dart';
import '../widgets/medicine_reminder_section.dart';
import '../widgets/vitals_section.dart';
import '../widgets/documents_section.dart';
import '../widgets/diet_exercise_section.dart';

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
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      await Future.wait([
        context.read<MedicationProvider>().loadMedicines(userId),
        context.read<HealthProvider>().loadVitals(userId),
        context.read<CaregiverProvider>().loadCaregivers(userId),
        context.read<NotificationProvider>().loadNotifications(),
        context.read<LifestyleProvider>().loadAll(userId),
        context.read<DocumentProvider>().loadDocuments(userId),
      ]);
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
    final notificationProvider = context.watch<NotificationProvider>();

    final user = authProvider.currentUser;
    final unreadNotifications = notificationProvider.unreadCount;

    return FScaffold(
      header: FHeader(
        title: Text('dashboard.hello'.tr(namedArgs: {'name': user?.name ?? 'dashboard.user'.tr()})),
        suffixes: [
          // Language switcher
          FHeaderAction(
            icon: const Icon(FIcons.languages),
            onPress: () => _showLanguageDialog(context),
          ),
          // Notifications
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
        onRefresh: _loadData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Adherence Streak Card
              Consumer<MedicationProvider>(
                builder: (context, medicationProvider, child) {
                  return AdherenceStreakCard(
                    streakDays: medicationProvider.adherenceStreak,
                    adherencePercentage: medicationProvider.adherencePercentage,
                  );
                },
              ),
              SizedBox(height: 24.h),

              // Section Tiles
              const MedicineReminderSection(),
              SizedBox(height: 16.h),
              const VitalsSection(),
              SizedBox(height: 16.h),
              const DocumentsSection(),
              SizedBox(height: 16.h),
              const DietExerciseSection(),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationsSheet extends StatelessWidget {
  const _NotificationsSheet();

  @override
  Widget build(BuildContext context) {
    final notificationProvider = context.watch<NotificationProvider>();
    final notifications = notificationProvider.notifications;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'dashboard.notifications'.tr(),
                    style: context.theme.typography.xl.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (notifications.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        notificationProvider.markAllAsRead();
                      },
                      child: Text('dashboard.markAllRead'.tr()),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FIcons.bell,
                              size: 48.r,
                              color: context.theme.colors.mutedForeground,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'dashboard.noNotifications'.tr(),
                              style: context.theme.typography.base,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final notification = notifications[index];
                          return Dismissible(
                            key: Key(notification.id),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) {
                              notificationProvider.deleteNotification(
                                notification.id,
                              );
                            },
                            background: Container(
                              color: AppTheme.getErrorColor(context),
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 16.w),
                              child: const Icon(
                                FIcons.trash,
                                color: Colors.white,
                              ),
                            ),
                            child: FCard(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    if (!notification.isRead) {
                                      notificationProvider.markAsRead(
                                        notification.id,
                                      );
                                    }
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.all(12.w),
                                    child: Row(
                                      children: [
                                        if (!notification.isRead)
                                          Container(
                                            width: 8.w,
                                            height: 8.h,
                                            decoration: BoxDecoration(
                                              color:
                                                  context.theme.colors.primary,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        SizedBox(width: 12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                notification.title,
                                                style: context
                                                    .theme
                                                    .typography
                                                    .sm
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                notification.body,
                                                style:
                                                    context.theme.typography.xs,
                                              ),
                                              SizedBox(height: 4.h),
                                              Text(
                                                DateFormat(
                                                  'MMM d, h:mm a',
                                                ).format(
                                                  notification.timestamp,
                                                ),
                                                style: context
                                                    .theme
                                                    .typography
                                                    .xs
                                                    .copyWith(
                                                      color: context
                                                          .theme
                                                          .colors
                                                          .mutedForeground,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
