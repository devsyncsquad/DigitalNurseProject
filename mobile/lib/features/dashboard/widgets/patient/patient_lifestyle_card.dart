import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/extensions/activity_type_extensions.dart';
import '../../../../core/extensions/meal_type_extensions.dart';
import '../../../../core/providers/lifestyle_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../dashboard_theme.dart';

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

    return Container(
      padding: CaregiverDashboardTheme.cardPadding(),
      decoration: CaregiverDashboardTheme.glassCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: CaregiverDashboardTheme.iconBadge(
                  CaregiverDashboardTheme.accentBlue,
                ),
                child: const Icon(
                  Icons.directions_run_outlined,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Today\'s activity',
                      style: CaregiverDashboardTheme.sectionTitleStyle(
                        context,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Track your diet and exercise for today.',
                      style: CaregiverDashboardTheme.sectionSubtitleStyle(
                        context,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          if (todayTotalLogs == 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 18.h,
              ),
              decoration: CaregiverDashboardTheme.tintedCard(
                CaregiverDashboardTheme.primaryTeal,
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: CaregiverDashboardTheme.iconBadge(
                      CaregiverDashboardTheme.primaryTeal,
                    ),
                    child: const Icon(
                      Icons.track_changes_outlined,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'No activities logged for today yet.',
                      style: context.theme.typography.sm.copyWith(
                        fontWeight: FontWeight.w600,
                        color: CaregiverDashboardTheme.deepTeal,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            if (todayDietLogs.isNotEmpty) ...[
              ...todayDietLogs.take(3).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;
                final isLast = index == todayDietLogs.take(3).toList().length - 1 &&
                    todayExerciseLogs.isEmpty;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
                  child: _DietRow(log: log),
                );
              }).toList(),
            ],
            if (todayExerciseLogs.isNotEmpty) ...[
              ...todayExerciseLogs.take(3).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final log = entry.value;
                final isLast = index == todayExerciseLogs.take(3).toList().length - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
                  child: _ExerciseRow(log: log),
                );
              }).toList(),
            ],
          ],
          if (todayTotalLogs > 0) ...[
            SizedBox(height: 16.h),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push('/lifestyle'),
                style: TextButton.styleFrom(
                  foregroundColor: CaregiverDashboardTheme.accentBlue,
                  textStyle: context.theme.typography.xs.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('View all activities'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DietRow extends StatelessWidget {
  final dynamic log;

  const _DietRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.getSuccessColor(context);
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: CaregiverDashboardTheme.tintedCard(accent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: CaregiverDashboardTheme.iconBadge(accent),
            child: const Icon(
              Icons.restaurant,
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
                  log.mealType.displayName,
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CaregiverDashboardTheme.deepTeal,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  log.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.xs.copyWith(
                    color: CaregiverDashboardTheme.deepTeal.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${log.calories} cal',
            style: context.theme.typography.xs.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  final dynamic log;

  const _ExerciseRow({required this.log});

  @override
  Widget build(BuildContext context) {
    final accent = CaregiverDashboardTheme.accentBlue;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: CaregiverDashboardTheme.tintedCard(accent),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: CaregiverDashboardTheme.iconBadge(accent),
            child: const Icon(
              Icons.fitness_center,
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
                  log.activityType.displayName,
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w700,
                    color: CaregiverDashboardTheme.deepTeal,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  log.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.theme.typography.xs.copyWith(
                    color: CaregiverDashboardTheme.deepTeal.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${log.durationMinutes}m',
                style: context.theme.typography.xs.copyWith(
                  fontWeight: FontWeight.w700,
                  color: accent,
                ),
              ),
              Text(
                '${log.caloriesBurned} cal',
                style: context.theme.typography.xs.copyWith(
                  fontWeight: FontWeight.w600,
                  color: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

