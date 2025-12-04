import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/activity_type_extensions.dart';
import '../../../../core/extensions/meal_type_extensions.dart';
import '../../../../core/providers/lifestyle_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../dashboard_theme.dart';
import 'expandable_patient_card.dart';

class PatientLifestyleCard extends StatelessWidget {
  const PatientLifestyleCard({super.key});

  @override
  Widget build(BuildContext context) {
    final lifestyleProvider = context.watch<LifestyleProvider>();
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = todayStart.add(const Duration(days: 1));

    final todayDietLogs = lifestyleProvider.dietLogs.where((log) {
      return log.timestamp.isAfter(todayStart) &&
          log.timestamp.isBefore(todayEnd);
    }).toList();

    final todayExerciseLogs = lifestyleProvider.exerciseLogs.where((log) {
      return log.timestamp.isAfter(todayStart) &&
          log.timestamp.isBefore(todayEnd);
    }).toList();

    final todayTotalLogs = todayDietLogs.length + todayExerciseLogs.length;

    final brightness = Theme.of(context).brightness;

    return ExpandablePatientCard(
      icon: Icons.directions_run_outlined,
      title: 'Your Lifestyle',
      subtitle: 'Track your diet and exercise activities.',
      count: '$todayTotalLogs',
      accentColor: CaregiverDashboardTheme.accentBlue,
      routeForViewDetails: '/lifestyle',
      expandedChild: todayTotalLogs == 0
          ? Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 18.h,
              ),
              decoration: CaregiverDashboardTheme.tintedCard(
                context,
                CaregiverDashboardTheme.primaryTeal,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: CaregiverDashboardTheme.iconBadge(
                      context,
                      CaregiverDashboardTheme.primaryTeal,
                    ),
                    child: const Icon(
                      Icons.check_circle_outline_rounded,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                child: Text(
                  'No diet or exercise logs for today.',
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                    color: CaregiverDashboardTheme.tintedForegroundColor(
                      CaregiverDashboardTheme.primaryTeal,
                      brightness: brightness,
                    ),
                  ),
                ),
                  ),
                ],
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (todayDietLogs.isNotEmpty) ...[
                  Text(
                    'Meals',
                    style: context.theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CaregiverDashboardTheme.deepTeal,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...todayDietLogs.take(2).map((log) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _LifestyleLogRow(
                        icon: Icons.restaurant,
                        title: log.mealType.displayName,
                        subtitle: log.description,
                        value: '${log.calories} cal',
                        accent: AppTheme.getSuccessColor(context),
                        onTap: () => context.push('/lifestyle'),
                      ),
                    );
                  }),
                  if (todayDietLogs.length > 2) SizedBox(height: 12.h),
                ],
                if (todayExerciseLogs.isNotEmpty) ...[
                  Text(
                    'Exercise',
                    style: context.theme.typography.sm.copyWith(
                      fontWeight: FontWeight.w700,
                      color: CaregiverDashboardTheme.deepTeal,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  ...todayExerciseLogs.take(2).map((log) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _LifestyleLogRow(
                        icon: Icons.fitness_center,
                        title: log.activityType.displayName,
                        subtitle: '${log.durationMinutes} min, ${log.caloriesBurned} cal',
                        value: DateFormat('h:mm a').format(log.timestamp),
                        accent: context.theme.colors.secondary,
                        onTap: () => context.push('/lifestyle'),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}

class _LifestyleLogRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final Color accent;
  final VoidCallback onTap;

  const _LifestyleLogRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final onTint = CaregiverDashboardTheme.tintedForegroundColor(
      accent,
      brightness: brightness,
    );
    final onTintMuted = CaregiverDashboardTheme.tintedMutedColor(
      accent,
      brightness: brightness,
    );

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: CaregiverDashboardTheme.tintedCard(context, accent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: CaregiverDashboardTheme.iconBadge(context, accent),
            child: Icon(
              icon,
              color: Colors.white,
              size: 22,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: onTint,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: context.theme.typography.xs.copyWith(
                    color: onTintMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onTap,
            style: TextButton.styleFrom(
              foregroundColor: accent,
              textStyle: context.theme.typography.xs.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
