import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../../../core/models/vital_measurement_model.dart';
import '../../../core/theme/app_theme.dart';

class VitalStatusBadge extends StatelessWidget {
  final VitalHealthStatus status;

  const VitalStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getBorderColor(context), width: 1),
      ),
      child: Text(
        _getStatusText(),
        style: context.theme.typography.xs.copyWith(
          color: _getTextColor(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _getStatusText() {
    switch (status) {
      case VitalHealthStatus.normal:
        return 'Normal';
      case VitalHealthStatus.warning:
        return 'Warning';
      case VitalHealthStatus.danger:
        return 'Danger';
    }
  }

  Color _getBackgroundColor(BuildContext context) {
    switch (status) {
      case VitalHealthStatus.normal:
        return AppTheme.getSuccessColor(context).withOpacity(0.1);
      case VitalHealthStatus.warning:
        return AppTheme.getWarningColor(context).withOpacity(0.1);
      case VitalHealthStatus.danger:
        return AppTheme.getErrorColor(context).withOpacity(0.1);
    }
  }

  Color _getBorderColor(BuildContext context) {
    switch (status) {
      case VitalHealthStatus.normal:
        return AppTheme.getSuccessColor(context).withOpacity(0.3);
      case VitalHealthStatus.warning:
        return AppTheme.getWarningColor(context).withOpacity(0.3);
      case VitalHealthStatus.danger:
        return AppTheme.getErrorColor(context).withOpacity(0.3);
    }
  }

  Color _getTextColor(BuildContext context) {
    switch (status) {
      case VitalHealthStatus.normal:
        return AppTheme.getSuccessColor(context);
      case VitalHealthStatus.warning:
        return AppTheme.getWarningColor(context);
      case VitalHealthStatus.danger:
        return AppTheme.getErrorColor(context);
    }
  }
}
