import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      header: FHeader.nested(
        title: Text('settings.title'.tr()),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Notifications section
          Text(
            'settings.notifications.title'.tr(),
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
                      'settings.notifications.medicineReminders.title'.tr(),
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    subtitle: Text(
                      'settings.notifications.medicineReminders.description'.tr(),
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
                      'settings.notifications.healthAlerts.title'.tr(),
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    subtitle: Text(
                      'settings.notifications.healthAlerts.description'.tr(),
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
                      'settings.notifications.caregiverUpdates.title'.tr(),
                      style: context.theme.typography.sm.copyWith(
                        color: context.theme.colors.foreground,
                      ),
                    ),
                    subtitle: Text(
                      'settings.notifications.caregiverUpdates.description'.tr(),
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

          // Language section
          Text(
            'settings.language.title'.tr(),
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),

          FCard(
            child: Material(
              color: Colors.transparent,
              child: Consumer<LocaleProvider>(
                builder: (context, localeProvider, child) {
                  return Column(
                    children: localeProvider.localeOptions.map((option) {
                      final isSelected = localeProvider.locale == option.locale;
                      return Column(
                        children: [
                          ListTile(
                            leading: Icon(
                              FIcons.languages,
                              color: context.theme.colors.mutedForeground,
                            ),
                            title: Text(
                              option.name,
                              style: context.theme.typography.sm.copyWith(
                                color: context.theme.colors.foreground,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
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
                              // Sync EasyLocalization with LocaleProvider
                              context.setLocale(option.locale);
                            },
                          ),
                          if (option != localeProvider.localeOptions.last)
                            const Divider(height: 1),
                        ],
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Privacy section
          Text(
            'settings.privacy.title'.tr(),
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
                      'settings.privacy.changePassword'.tr(),
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
                      'settings.privacy.privacyPolicy'.tr(),
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
                      'settings.privacy.termsOfService'.tr(),
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
            'settings.about.title'.tr(),
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
                      'settings.about.appVersion'.tr(),
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
                      'settings.about.helpSupport'.tr(),
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
                      'settings.about.sendFeedback'.tr(),
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
              'settings.debug.title'.tr(),
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
                    'settings.debug.testNotifications.title'.tr(),
                    style: context.theme.typography.sm.copyWith(
                      color: context.theme.colors.foreground,
                    ),
                  ),
                  subtitle: Text(
                    'settings.debug.testNotifications.description'.tr(),
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
