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
import '../../../core/providers/care_context_provider.dart';
import '../../../core/models/care_recipient_model.dart';
import '../../../core/models/user_model.dart';
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
    final careRecipients = careContextProvider.careRecipients;
    final selectedRecipient = careContextProvider.selectedRecipient;

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isCaregiver) ...[
                CareRecipientSelector(
                  isLoading: careContextProvider.isLoading,
                  recipients: careRecipients,
                  selectedRecipient: selectedRecipient,
                  error: careContextProvider.error,
                  onSelect: (elderId) {
                    careContextProvider.selectRecipient(elderId);
                    _loadData(force: true);
                  },
                ),
                SizedBox(height: 16.h),
              ],
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
          ),
        ),
      ),
    );
  }
}

class CareRecipientSelector extends StatelessWidget {
  final bool isLoading;
  final List<CareRecipientModel> recipients;
  final CareRecipientModel? selectedRecipient;
  final String? error;
  final ValueChanged<String> onSelect;

  const CareRecipientSelector({
    super.key,
    required this.isLoading,
    required this.recipients,
    required this.selectedRecipient,
    required this.error,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading && recipients.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: SizedBox(
            height: 32,
            width: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor:
                  AlwaysStoppedAnimation<Color>(context.theme.colors.primary),
            ),
          ),
        ),
      );
    }

    if (error != null && recipients.isEmpty) {
      final errorColor = AppTheme.getErrorColor(context);
      return FCard(
        style: (cardStyle) => cardStyle.copyWith(
          decoration: cardStyle.decoration.copyWith(
            border: Border.all(color: errorColor),
            color: errorColor.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unable to load assigned elders',
              style: context.theme.typography.sm.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: context.theme.typography.xs,
            ),
          ],
        ),
      );
    }

    if (recipients.isEmpty) {
      final highlightColor = context.theme.colors.primary;
      return FCard(
        style: (cardStyle) => cardStyle.copyWith(
          decoration: cardStyle.decoration.copyWith(
            border: Border.all(color: highlightColor),
            color: highlightColor.withOpacity(0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No elders assigned yet',
              style: context.theme.typography.sm.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Once an elder invites you as a caregiver, their profile will appear here.',
              style: context.theme.typography.xs,
            ),
          ],
        ),
      );
    }

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Managing care for',
            style: context.theme.typography.xs.copyWith(
              color: context.theme.colors.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: selectedRecipient?.elderId,
            items: recipients
                .map(
                  (recipient) => DropdownMenuItem<String>(
                    value: recipient.elderId,
                    child: Text(
                      recipient.name,
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onSelect(value);
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          if (selectedRecipient?.relationship != null) ...[
            const SizedBox(height: 8),
            Text(
              selectedRecipient!.relationship!,
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ],
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
