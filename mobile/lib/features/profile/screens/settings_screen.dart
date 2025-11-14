import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/widgets/modern_scaffold.dart';
import '../../../core/providers/locale_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ModernScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'settings.title'.tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: ModernSurfaceTheme.screenPadding(),
        children: [
          // Notifications section
          Text(
            'settings.notifications.title'.tr(),
            style: ModernSurfaceTheme.sectionTitleStyle(context),
          ),
          SizedBox(height: 12.h),

          Container(
            decoration: ModernSurfaceTheme.glassCard(),
            child: Column(
              children: [
                _ModernSwitchTile(
                  title: 'settings.notifications.medicineReminders.title'.tr(),
                  subtitle:
                      'settings.notifications.medicineReminders.description'.tr(),
                  value: true,
                  onChanged: (_) {},
                ),
                const Divider(height: 1),
                _ModernSwitchTile(
                  title: 'settings.notifications.healthAlerts.title'.tr(),
                  subtitle: 'settings.notifications.healthAlerts.description'.tr(),
                  value: true,
                  onChanged: (_) {},
                ),
                const Divider(height: 1),
                _ModernSwitchTile(
                  title: 'settings.notifications.caregiverUpdates.title'.tr(),
                  subtitle:
                      'settings.notifications.caregiverUpdates.description'.tr(),
                  value: false,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Language section
          Text(
            'settings.language.title'.tr(),
            style: ModernSurfaceTheme.sectionTitleStyle(context),
          ),
          SizedBox(height: 12.h),

          Container(
            decoration: ModernSurfaceTheme.glassCard(),
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
                            color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.7),
                          ),
                          title: Text(
                            option.name,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: ModernSurfaceTheme.deepTeal,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  FIcons.check,
                                  color: ModernSurfaceTheme.primaryTeal,
                                )
                              : null,
                          onTap: () async {
                            await localeProvider.setLocale(option.locale);
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
          SizedBox(height: 24.h),

          // Privacy section
          Text(
            'settings.privacy.title'.tr(),
            style: ModernSurfaceTheme.sectionTitleStyle(context),
          ),
          SizedBox(height: 12.h),

          Container(
            decoration: ModernSurfaceTheme.glassCard(),
            child: Column(
              children: [
                _ModernListTile(
                  icon: FIcons.lock,
                  title: 'settings.privacy.changePassword'.tr(),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Password change (mock)')),
                    );
                  },
                ),
                const Divider(height: 1),
                _ModernListTile(
                  icon: FIcons.shield,
                  title: 'settings.privacy.privacyPolicy'.tr(),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _ModernListTile(
                  icon: FIcons.fileText,
                  title: 'settings.privacy.termsOfService'.tr(),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // App section
          Text(
            'settings.about.title'.tr(),
            style: ModernSurfaceTheme.sectionTitleStyle(context),
          ),
          SizedBox(height: 12.h),

          Container(
            decoration: ModernSurfaceTheme.glassCard(),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    FIcons.info,
                    color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.7),
                  ),
                  title: Text(
                    'settings.about.appVersion'.tr(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: ModernSurfaceTheme.deepTeal,
                        ),
                  ),
                  trailing: Text(
                    '1.0.0 (Phase 1)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.6),
                        ),
                  ),
                ),
                const Divider(height: 1),
                _ModernListTile(
                  icon: FIcons.info,
                  title: 'settings.about.helpSupport'.tr(),
                  onTap: () {},
                ),
                const Divider(height: 1),
                _ModernListTile(
                  icon: FIcons.messageCircle,
                  title: 'settings.about.sendFeedback'.tr(),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Debug section (only in debug mode)
          if (const bool.fromEnvironment('dart.vm.product') == false) ...[
            Text(
              'settings.debug.title'.tr(),
              style: ModernSurfaceTheme.sectionTitleStyle(context).copyWith(
                    color: AppTheme.getWarningColor(context),
                  ),
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: ModernSurfaceTheme.glassCard(
                accent: AppTheme.getWarningColor(context),
              ),
              child: ListTile(
                leading: Icon(
                  FIcons.bell,
                  color: AppTheme.getWarningColor(context),
                ),
                title: Text(
                  'settings.debug.testNotifications.title'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ModernSurfaceTheme.deepTeal,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                subtitle: Text(
                  'settings.debug.testNotifications.description'.tr(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.65),
                      ),
                ),
                trailing: Icon(
                  FIcons.chevronsRight,
                  color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.4),
                ),
                onTap: () => context.push('/notification-test'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ModernSwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ModernSwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      activeThumbColor: ModernSurfaceTheme.primaryTeal,
      activeTrackColor: ModernSurfaceTheme.primaryTeal.withValues(alpha: 0.4),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernSurfaceTheme.deepTeal,
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.65),
            ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}

class _ModernListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ModernListTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.7)),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: ModernSurfaceTheme.deepTeal,
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: Icon(
        FIcons.chevronsRight,
        color: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.4),
      ),
      onTap: onTap,
    );
  }
}
