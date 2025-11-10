import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/care_context_provider.dart';
import '../../../core/models/vital_measurement_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/user_model.dart';
import '../widgets/vitals_calendar_header.dart';
import '../widgets/vital_status_badge.dart';

class VitalsListScreen extends StatefulWidget {
  const VitalsListScreen({super.key});

  @override
  State<VitalsListScreen> createState() => _VitalsListScreenState();
}

class _VitalsListScreenState extends State<VitalsListScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _lastContextKey;

  Future<void> _reloadVitals() async {
    final authProvider = context.read<AuthProvider>();
    final healthProvider = context.read<HealthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return;
    }

    final isCaregiver = user.role == UserRole.caregiver;
    String? targetUserId = user.id;
    String? elderUserId;

    if (isCaregiver) {
      final careContext = context.read<CareContextProvider>();
      await careContext.ensureLoaded();
      targetUserId = careContext.selectedElderId;
      elderUserId = targetUserId;
      if (targetUserId == null) {
        return;
      }
    }

    await healthProvider.loadVitals(targetUserId, elderUserId: elderUserId);
  }

  void _ensureContextSync({
    required bool isCaregiver,
    required String? selectedElderId,
    required String? userId,
  }) {
    final key = isCaregiver
        ? 'caregiver-${selectedElderId ?? 'none'}'
        : 'patient-${userId ?? 'unknown'}';

    if (_lastContextKey == key) {
      return;
    }

    _lastContextKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _reloadVitals();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final isCaregiver = currentUser?.role == UserRole.caregiver;
    final careContext = isCaregiver
        ? context.watch<CareContextProvider>()
        : null;
    final selectedElderId = careContext?.selectedElderId;
    final hasAssignments =
        !isCaregiver || (careContext?.careRecipients.isNotEmpty ?? false);
    final isCareContextLoading = careContext?.isLoading ?? false;
    final careContextError = careContext?.error;

    _ensureContextSync(
      isCaregiver: isCaregiver,
      selectedElderId: selectedElderId,
      userId: currentUser?.id,
    );

    final healthProvider = context.watch<HealthProvider>();
    final vitals = healthProvider.getVitalsForDate(_selectedDate);
    final error = healthProvider.error;

    return FScaffold(
      header: FHeader(
        title: const Text('Health Vitals'),
        suffixes: [
          if (!isCaregiver)
            FHeaderAction(
              icon: const Icon(FIcons.plus),
              onPress: () => context.push('/vitals/add'),
            ),
        ],
      ),
      child: _buildBody(
        context,
        isCaregiver: isCaregiver,
        hasAssignments: hasAssignments,
        hasSelectedRecipient: selectedElderId != null,
        isCareContextLoading: isCareContextLoading,
        careContextError: careContextError,
        healthProvider: healthProvider,
        vitals: vitals,
        error: error,
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required bool isCaregiver,
    required bool hasAssignments,
    required bool hasSelectedRecipient,
    required bool isCareContextLoading,
    required String? careContextError,
    required HealthProvider healthProvider,
    required List<VitalMeasurementModel> vitals,
    required String? error,
  }) {
    if (isCaregiver) {
      if (isCareContextLoading && !hasAssignments) {
        return const Center(child: CircularProgressIndicator());
      }

      if (!hasAssignments) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.users,
          title: 'No patients assigned yet',
          message:
              'Once you are added as a caregiver, you can review vitals for your patients here.',
        );
      }

      if (careContextError != null && !hasSelectedRecipient) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.info,
          title: 'Unable to load patients',
          message: careContextError,
          onRetry: _reloadVitals,
        );
      }

      if (!hasSelectedRecipient) {
        return _buildCaregiverNotice(
          context,
          icon: FIcons.userSearch,
          title: 'Select a patient to continue',
          message:
              'Choose a patient from the dashboard to review their latest vitals.',
        );
      }
    }

    if (healthProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (error != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _ErrorBanner(message: error, onRetry: _reloadVitals),
          ),
        // Calendar Header
        VitalsCalendarHeader(
          selectedDate: _selectedDate,
          onDateChanged: (date) {
            setState(() {
              _selectedDate = date;
            });
          },
        ),

        // Quick stats
        Container(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: FButton(
                  onPress: () => context.push('/health/trends'),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(FIcons.trendingUp),
                      const SizedBox(width: 8),
                      const Text('View Trends'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Vitals list or empty state
        Expanded(
          child: vitals.isEmpty
              ? _buildEmptyState(context, isCaregiver: isCaregiver)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: vitals.length,
                  itemBuilder: (context, index) {
                    final vital = vitals[index];
                    final healthStatus = vital.getHealthStatus();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FCard(
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _getStatusBackgroundColor(
                                    healthStatus,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  FIcons.activity,
                                  color: _getStatusColor(healthStatus),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vital.type.displayName,
                                      style: context.theme.typography.base
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      DateFormat(
                                        'MMM d, yyyy - h:mm a',
                                      ).format(vital.timestamp),
                                      style: context.theme.typography.sm,
                                    ),
                                    if (vital.notes != null) ...[
                                      SizedBox(height: 4),
                                      Text(
                                        vital.notes!,
                                        style: context.theme.typography.xs
                                            .copyWith(
                                              color: context
                                                  .theme
                                                  .colors
                                                  .mutedForeground,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    vital.value,
                                    style: context.theme.typography.lg.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(healthStatus),
                                    ),
                                  ),
                                  Text(
                                    vital.type.unit,
                                    style: context.theme.typography.xs,
                                  ),
                                  const SizedBox(height: 4),
                                  VitalStatusBadge(status: healthStatus),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, {required bool isCaregiver}) {
    final healthProvider = context.watch<HealthProvider>();
    final allVitals = healthProvider.vitals;

    if (allVitals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FIcons.activity,
              size: 64.r,
              color: context.theme.colors.mutedForeground,
            ),
            SizedBox(height: 16.h),
            Text('No vitals logged yet', style: context.theme.typography.lg),
            SizedBox(height: 8.h),
            Text(
              isCaregiver
                  ? 'This patient has no vitals recorded yet.'
                  : 'Start tracking your health vitals',
              style: context.theme.typography.sm,
            ),
            if (!isCaregiver) ...[
              SizedBox(height: 24.h),
              FButton(
                onPress: () => context.push('/vitals/add'),
                child: const Text('Log Vitals'),
              ),
            ],
          ],
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              FIcons.calendar,
              size: 64.r,
              color: context.theme.colors.mutedForeground,
            ),
            SizedBox(height: 16.h),
            Text(
              'No vitals for ${_getFormattedDate(_selectedDate)}',
              style: context.theme.typography.lg,
            ),
            SizedBox(height: 8.h),
            Text(
              'Select another date or add vitals',
              style: context.theme.typography.sm.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ),
      );
    }
  }

  String _getFormattedDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getStatusColor(VitalHealthStatus status) {
    switch (status) {
      case VitalHealthStatus.normal:
        return AppTheme.getSuccessColor(context);
      case VitalHealthStatus.warning:
        return AppTheme.getWarningColor(context);
      case VitalHealthStatus.danger:
        return AppTheme.getErrorColor(context);
    }
  }

  Color _getStatusBackgroundColor(VitalHealthStatus status) {
    switch (status) {
      case VitalHealthStatus.normal:
        return AppTheme.getSuccessColor(context).withOpacity(0.1);
      case VitalHealthStatus.warning:
        return AppTheme.getWarningColor(context).withOpacity(0.1);
      case VitalHealthStatus.danger:
        return AppTheme.getErrorColor(context).withOpacity(0.1);
    }
  }

  Widget _buildCaregiverNotice(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: FCard(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: context.theme.colors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: context.theme.typography.lg.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 16),
                FButton(onPress: onRetry, child: const Text('Retry')),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.getErrorColor(context).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.getErrorColor(context).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(FIcons.info, color: AppTheme.getErrorColor(context)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: context.theme.typography.sm.copyWith(
                color: AppTheme.getErrorColor(context),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onRetry();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
