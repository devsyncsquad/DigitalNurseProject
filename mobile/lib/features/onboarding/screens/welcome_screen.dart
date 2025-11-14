import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
          child: Column(
            children: [
              SizedBox(height: 12.h),

              // App logo/icon
              Icon(
                FIcons.heartPulse,
                size: 80.h,
                color: context.theme.colors.primary,
              ),
              SizedBox(height: 20.h),

              // App name
              Text(
                'app.name'.tr(),
                style: context.theme.typography.xl3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.theme.colors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Tagline
              Text(
                'app.tagline'.tr(),
                style: context.theme.typography.lg.copyWith(
                  color: context.theme.colors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Description
              Text(
                'app.description'.tr(),
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),

              // Features list - individual cards
              Flexible(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _FeatureItem(
                      icon: FIcons.pill,
                      title: 'onboarding.welcome.features.medicineReminders.title'.tr(),
                      description: 'onboarding.welcome.features.medicineReminders.description'.tr(),
                    ),
                    SizedBox(height: 6.h),
                    _FeatureItem(
                      icon: FIcons.activity,
                      title: 'onboarding.welcome.features.healthTracking.title'.tr(),
                      description: 'onboarding.welcome.features.healthTracking.description'.tr(),
                    ),
                    SizedBox(height: 6.h),
                    _FeatureItem(
                      icon: FIcons.users,
                      title: 'onboarding.welcome.features.caregiverCoordination.title'.tr(),
                      description: 'onboarding.welcome.features.caregiverCoordination.description'.tr(),
                    ),
                    SizedBox(height: 6.h),
                    _FeatureItem(
                      icon: FIcons.fileText,
                      title: 'onboarding.welcome.features.documentManagement.title'.tr(),
                      description: 'onboarding.welcome.features.documentManagement.description'.tr(),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 14.h),

              // Get started button
              FButton(
                onPress: () => context.go('/register'),
                child: Text('onboarding.welcome.getStarted'.tr()),
              ),
              SizedBox(height: 6.h),

              // Login button
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'onboarding.welcome.hasAccount'.tr(),
                  style: TextStyle(color: context.theme.colors.primary),
                ),
              ),

              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.theme.colors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: context.theme.colors.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: Row(
        children: [
          Icon(icon, color: context.theme.colors.primary, size: 20.h),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.theme.colors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: context.theme.typography.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
