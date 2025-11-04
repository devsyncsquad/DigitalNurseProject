import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import '../../../core/theme/app_theme.dart';
import 'animated_heart_icon.dart';

class AdherenceStreakCard extends StatelessWidget {
  final int streakDays;
  final double adherencePercentage;
  final VoidCallback? onSetupPressed;

  const AdherenceStreakCard({
    super.key,
    required this.streakDays,
    required this.adherencePercentage,
    this.onSetupPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.theme.colors.primary,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Row(
          children: [
            // Left side - Streak info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Adherence Streak',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      // TextButton(
                      //   onPressed:
                      //       onSetupPressed ?? () => context.go('/settings'),
                      //   style: TextButton.styleFrom(
                      //     foregroundColor: Colors.white,
                      //     padding: EdgeInsets.symmetric(
                      //       horizontal: 6.w,
                      //       vertical: 3.h,
                      //     ),
                      //     minimumSize: Size.zero,
                      //     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      //   ),
                      //   child: Row(
                      //     mainAxisSize: MainAxisSize.min,
                      //     children: [
                      //       const Icon(Icons.settings, size: 14),
                      //       SizedBox(width: 2.w),
                      //       Text(
                      //         'Setup',
                      //         style: Theme.of(context).textTheme.bodySmall
                      //             ?.copyWith(
                      //               color: Colors.white,
                      //               fontSize: 12.sp,
                      //             ),
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$streakDays',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32.sp,
                            ),
                      ),
                      SizedBox(width: 4.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 3.h),
                        child: Text(
                          streakDays == 1 ? 'day' : 'days',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white, fontSize: 14.sp),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            // Right side - Heart icon
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedHeartIcon(
                  percentage: adherencePercentage,
                  size: 55.0,
                  fillColor: AppTheme.getErrorColor(context),
                  strokeColor: Colors.white,
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    '${adherencePercentage.toInt()}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
