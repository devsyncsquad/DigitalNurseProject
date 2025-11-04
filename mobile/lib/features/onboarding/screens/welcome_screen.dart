import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            children: [
              // Top spacer
              Expanded(flex: 1, child: Container()),

              // App logo/icon
              Icon(
                FIcons.heartPulse,
                size: 80.h,
                color: context.theme.colors.primary,
              ),
              SizedBox(height: 16.h),

              // App name
              Text(
                'My Digital Nurse',
                style: context.theme.typography.xl3.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.theme.colors.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Tagline
              Text(
                'Your Personal Health Companion',
                style: context.theme.typography.lg.copyWith(
                  color: context.theme.colors.foreground,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // Description
              Text(
                'Manage medications, track vitals, coordinate care, and take control of your health journey.',
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10.h),

              // Features list - made more compact
              Expanded(
                flex: 3,
                child: FCard(
                  child: Padding(
                    padding: EdgeInsets.all(8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _FeatureItem(
                          icon: FIcons.pill,
                          title: 'Medicine Reminders',
                          description: 'Never miss a dose',
                        ),
                        _FeatureItem(
                          icon: FIcons.activity,
                          title: 'Health Tracking',
                          description: 'Monitor your vitals',
                        ),
                        _FeatureItem(
                          icon: FIcons.users,
                          title: 'Caregiver Coordination',
                          description: 'Stay connected with care team',
                        ),
                        _FeatureItem(
                          icon: FIcons.fileText,
                          title: 'Document Management',
                          description: 'Keep all records organized',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Get started button
              FButton(
                onPress: () => context.go('/register'),
                child: const Text('Get Started'),
              ),
              SizedBox(height: 8.h),

              // Login button
              TextButton(
                onPressed: () => context.go('/login'),
                child: Text(
                  'I already have an account',
                  style: TextStyle(color: context.theme.colors.primary),
                ),
              ),

              // Bottom spacer
              Expanded(flex: 1, child: Container()),
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
    return Row(
      children: [
        Icon(icon, color: context.theme.colors.primary, size: 24.h),
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
                  color: context.theme.colors.foreground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: context.theme.typography.sm.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
