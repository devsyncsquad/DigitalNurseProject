import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/models/user_model.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;

    if (user == null) {
      return const FScaffold(child: Center(child: CircularProgressIndicator()));
    }

    return FScaffold(
      header: FHeader(
        title: const Text('Profile'),
        suffixes: [
          FHeaderAction(
            icon: const Icon(FIcons.settings),
            onPress: () => context.push('/settings'),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile header
            FCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: context.theme.colors.primary.withValues(
                        alpha: 0.2,
                      ),
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: context.theme.typography.xl3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.theme.colors.primary,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      user.name,
                      style: context.theme.typography.xl2.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      user.email,
                      style: context.theme.typography.sm,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    Center(
                      child: FBadge(
                        child: Text(
                          user.subscriptionTier == SubscriptionTier.premium
                              ? 'Premium Member'
                              : 'Free Plan',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Personal information
            Text(
              'Personal Information',
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            FCard(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    // Check if all personal info fields are null
                    if (user.age == null &&
                        user.phone == null &&
                        user.emergencyContact == null &&
                        user.medicalConditions == null)
                      // Empty state
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(
                              FIcons.userPen,
                              size: 48,
                              color: context.theme.colors.mutedForeground,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No personal information added yet',
                              style: context.theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w500,
                                color: context.theme.colors.foreground,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap "Edit Profile" to add your details',
                              style: context.theme.typography.sm.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else ...[
                      // Show personal information fields
                      if (user.age != null)
                        _ProfileInfoRow(
                          icon: FIcons.calendar,
                          label: 'Age',
                          value: user.age!,
                        ),
                      if (user.phone != null) ...[
                        if (user.age != null) const Divider(height: 24),
                        _ProfileInfoRow(
                          icon: FIcons.phone,
                          label: 'Phone',
                          value: user.phone!,
                        ),
                      ],
                      if (user.emergencyContact != null) ...[
                        if (user.age != null || user.phone != null)
                          const Divider(height: 24),
                        _ProfileInfoRow(
                          icon: FIcons.phone,
                          label: 'Emergency Contact',
                          value: user.emergencyContact!,
                        ),
                      ],
                      if (user.medicalConditions != null) ...[
                        if (user.age != null ||
                            user.phone != null ||
                            user.emergencyContact != null)
                          const Divider(height: 24),
                        _ProfileInfoRow(
                          icon: FIcons.heartPulse,
                          label: 'Medical Conditions',
                          value: user.medicalConditions!,
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Quick actions
            Text(
              'Quick Actions',
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),

            FCard(
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        FIcons.userPen,
                        color: context.theme.colors.mutedForeground,
                      ),
                      title: Text(
                        'Edit Profile',
                        style: context.theme.typography.sm.copyWith(
                          color: context.theme.colors.foreground,
                        ),
                      ),
                      trailing: Icon(
                        FIcons.chevronsRight,
                        color: context.theme.colors.mutedForeground,
                      ),
                      onTap: () {
                        context.push('/profile-setup');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        FIcons.creditCard,
                        color: context.theme.colors.mutedForeground,
                      ),
                      title: Text(
                        'Subscription',
                        style: context.theme.typography.sm.copyWith(
                          color: context.theme.colors.foreground,
                        ),
                      ),
                      subtitle: Text(
                        user.subscriptionTier == SubscriptionTier.premium
                            ? 'Manage your premium subscription'
                            : 'Upgrade to Premium',
                        style: context.theme.typography.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                      trailing: Icon(
                        FIcons.chevronsRight,
                        color: context.theme.colors.mutedForeground,
                      ),
                      onTap: () {
                        context.push('/subscription-plans');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        FIcons.users,
                        color: context.theme.colors.mutedForeground,
                      ),
                      title: Text(
                        'Manage Caregivers',
                        style: context.theme.typography.sm.copyWith(
                          color: context.theme.colors.foreground,
                        ),
                      ),
                      trailing: Icon(
                        FIcons.chevronsRight,
                        color: context.theme.colors.mutedForeground,
                      ),
                      onTap: () {
                        // Navigate to caregiver list (would need a separate route)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Navigate to Caregivers tab'),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _ThemeSelectorTile(),
                    const Divider(height: 1),
                    ListTile(
                      leading: Icon(
                        FIcons.settings,
                        color: context.theme.colors.mutedForeground,
                      ),
                      title: Text(
                        'Settings',
                        style: context.theme.typography.sm.copyWith(
                          color: context.theme.colors.foreground,
                        ),
                      ),
                      trailing: Icon(
                        FIcons.chevronsRight,
                        color: context.theme.colors.mutedForeground,
                      ),
                      onTap: () {
                        context.push('/settings');
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),

            // Logout button
            FButton(
              onPress: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await context.read<AuthProvider>().logout();
                  if (context.mounted) {
                    context.go('/welcome');
                  }
                }
              },
              prefix: const Icon(FIcons.logOut),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: context.theme.colors.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.theme.typography.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeSelectorTile extends StatelessWidget {
  const _ThemeSelectorTile();

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return ListTile(
      leading: Icon(
        FIcons.palette,
        color: context.theme.colors.mutedForeground,
      ),
      title: Text(
        'Theme',
        style: context.theme.typography.sm.copyWith(
          color: context.theme.colors.foreground,
        ),
      ),
      subtitle: Text(
        themeProvider.themeModeDisplayName,
        style: context.theme.typography.xs.copyWith(
          color: context.theme.colors.mutedForeground,
        ),
      ),
      trailing: Icon(
        FIcons.chevronsRight,
        color: context.theme.colors.mutedForeground,
      ),
      onTap: () => _showThemeSelector(context, themeProvider),
    );
  }

  void _showThemeSelector(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themeProvider.themeModeOptions.map((option) {
            return RadioListTile<ThemeMode>(
              title: Text(option.name),
              subtitle: Text(option.description),
              value: option.mode,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
