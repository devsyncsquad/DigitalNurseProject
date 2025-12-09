import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/care_recipient_model.dart';
import '../dashboard_theme.dart';

class PatientCard extends StatelessWidget {
  final CareRecipientModel patient;
  final VoidCallback? onTap;
  final VoidCallback? onCall;
  final VoidCallback? onChat;

  const PatientCard({
    super.key,
    required this.patient,
    this.onTap,
    this.onCall,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final isStable = patient.status == PatientStatus.stable;
    final statusColor = isStable
        ? CaregiverDashboardTheme.primaryTeal
        : CaregiverDashboardTheme.accentCoral;
    final statusText = isStable ? 'Stable' : 'Needs Attention';
    final statusIcon = isStable ? Icons.check_circle : Icons.warning_amber_rounded;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: CaregiverDashboardTheme.cardRadius(),
        child: Container(
          padding: CaregiverDashboardTheme.cardPadding(),
          decoration: CaregiverDashboardTheme.glassCard(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with photo and status
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Patient photo
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CaregiverDashboardTheme.primaryTeal.withOpacity(0.1),
                      border: Border.all(
                        color: CaregiverDashboardTheme.primaryTeal.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: patient.avatarUrl != null && patient.avatarUrl!.isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              patient.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildPlaceholderAvatar(context),
                            ),
                          )
                        : _buildPlaceholderAvatar(context),
                  ),
                  SizedBox(width: 12.w),
                  // Name and age
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (patient.age != null) ...[
                          SizedBox(height: 4.h),
                          Text(
                            '${patient.age} years old',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          statusText,
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              // Last activity
              if (patient.lastActivityTime != null) ...[
                Row(
                  children: [
                    Icon(
                      FIcons.clock,
                      size: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      _formatLastActivity(patient.lastActivityTime!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
              ],
              // Quick action buttons
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'View Details',
                      icon: FIcons.eye,
                      onTap: onTap ?? () {},
                      color: CaregiverDashboardTheme.primaryTeal,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  if (patient.phone != null) ...[
                    _ActionButton(
                      label: 'Call',
                      icon: FIcons.phone,
                      onTap: onCall ?? () {},
                      color: CaregiverDashboardTheme.accentBlue,
                      isCompact: true,
                    ),
                    SizedBox(width: 8.w),
                  ],
                  _ActionButton(
                    label: 'Chat',
                    icon: FIcons.messageCircle,
                    onTap: onChat ?? () {},
                    color: CaregiverDashboardTheme.accentYellow,
                    isCompact: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderAvatar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            CaregiverDashboardTheme.primaryTeal,
            CaregiverDashboardTheme.primaryTeal.withOpacity(0.7),
          ],
        ),
      ),
      child: Icon(
        FIcons.user,
        color: Colors.white,
        size: 30.w,
      ),
    );
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(lastActivity);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final bool isCompact;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              size: 18,
              color: color,
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              SizedBox(width: 6.w),
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

