import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/theme/app_theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: const Text('Settings'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Notifications section
          Text(
            'Notifications',
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          FCard(
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(
                      'Medicine Reminders',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    subtitle: Text(
                      'Get notified for medicine times',
                      style: context.theme.typography.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    value: true,
                    onChanged: (value) {
                      // Mock toggle
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      'Health Alerts',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    subtitle: Text(
                      'Alerts for abnormal vitals',
                      style: context.theme.typography.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    value: true,
                    onChanged: (value) {
                      // Mock toggle
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: Text(
                      'Caregiver Updates',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    subtitle: Text(
                      'Notifications from caregivers',
                      style: context.theme.typography.xs.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                    value: false,
                    onChanged: (value) {
                      // Mock toggle
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Privacy section
          Text(
            'Privacy & Security',
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          FCard(
            child: Material(
              color: Colors.transparent,

              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      FIcons.lock,
                      color: context.theme.colors.mutedForeground,
                    ),
                    title: Text(
                      'Change Password',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    trailing: Icon(
                      FIcons.chevronsRight,
                      color: context.theme.colors.mutedForeground,
                    ),
                    onTap: () {
                      // Mock action
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Password change (mock)')),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      FIcons.shield,
                      color: context.theme.colors.mutedForeground,
                    ),
                    title: Text(
                      'Privacy Policy',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    trailing: Icon(
                      FIcons.chevronsRight,
                      color: context.theme.colors.mutedForeground,
                    ),
                    onTap: () {
                      // Mock action
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      FIcons.fileText,
                      color: context.theme.colors.mutedForeground,
                    ),
                    title: Text(
                      'Terms of Service',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    trailing: Icon(
                      FIcons.chevronsRight,
                      color: context.theme.colors.mutedForeground,
                    ),
                    onTap: () {
                      // Mock action
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // App section
          Text(
            'About',
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          FCard(
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      FIcons.info,
                      color: context.theme.colors.mutedForeground,
                    ),
                    title: Text(
                      'App Version',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    trailing: Text(
                      '1.0.0 (Phase 1)',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.mutedForeground,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      FIcons.info,
                      color: context.theme.colors.mutedForeground,
                    ),
                    title: Text(
                      'Help & Support',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    trailing: Icon(
                      FIcons.chevronsRight,
                      color: context.theme.colors.mutedForeground,
                    ),
                    onTap: () {
                      // Mock action
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      FIcons.messageCircle,
                      color: context.theme.colors.mutedForeground,
                    ),
                    title: Text(
                      'Send Feedback',
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    trailing: Icon(
                      FIcons.chevronsRight,
                      color: context.theme.colors.mutedForeground,
                    ),
                    onTap: () {
                      // Mock action
                    },
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Debug section (only in debug mode)
          if (const bool.fromEnvironment('dart.vm.product') == false) ...[
            Text(
              'Debug',
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.getWarningColor(context),
              ),
            ),
            SizedBox(height: 12.h),
            FCard(
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  leading: Icon(FIcons.bell, color: AppTheme.getWarningColor(context)),
                  title: Text(
                    'Test Notifications',
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.foreground,
                    ),
                  ),
                  subtitle: Text(
                    'Test push notification functionality',
                    style: context.theme.typography.xs.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                  trailing: Icon(
                    FIcons.chevronsRight,
                    color: context.theme.colors.mutedForeground,
                  ),
                  onTap: () {
                    context.push('/notification-test');
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
