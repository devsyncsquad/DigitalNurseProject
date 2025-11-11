import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';

class CaregiverActionShortcuts extends StatelessWidget {
  const CaregiverActionShortcuts({super.key});

  void _showComingSoon(BuildContext context, String action) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$action coming soon'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = [
      _ActionShortcut(
        icon: Icons.phone,
        label: 'Call patient',
        onTap: () => _showComingSoon(context, 'Calling'),
      ),
      _ActionShortcut(
        icon: Icons.notifications_active_outlined,
        label: 'Send reminder',
        onTap: () => _showComingSoon(context, 'Reminder'),
      ),
      _ActionShortcut(
        icon: Icons.note_alt,
        label: 'Log observation',
        onTap: () => context.push('/documents'),
      ),
      _ActionShortcut(
        icon: Icons.calendar_month,
        label: 'View schedule',
        onTap: () => context.push('/medications'),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final crossAxisSpacing = 12.w;
        final itemWidth = isWide
            ? (constraints.maxWidth - crossAxisSpacing) / 2
            : constraints.maxWidth;

        return FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick actions',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Wrap(
                spacing: crossAxisSpacing,
                runSpacing: 12.h,
                children: actions
                    .map(
                      (action) => SizedBox(
                        width: itemWidth,
                        child: action,
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ActionShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Ink(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.theme.colors.muted.withOpacity(0.4),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.theme.colors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: context.theme.colors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

