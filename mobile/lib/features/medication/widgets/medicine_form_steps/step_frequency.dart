import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/models/medicine_model.dart';
import '../../providers/medicine_form_provider.dart';
import '../medicine_form_shared/weekday_toggle_selector.dart';

class StepFrequency extends StatelessWidget {
  const StepFrequency({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineFormProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How often do you take this medicine?',
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 24.h),
            _buildFrequencyOptions(context, provider),
            if (provider.formData.frequency == MedicineFrequency.periodic) ...[
              SizedBox(height: 24.h),
              WeekdayToggleSelector(
                selectedDays: provider.formData.periodicDays,
                onDaysChanged: provider.setPeriodicDays,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFrequencyOptions(
    BuildContext context,
    MedicineFormProvider provider,
  ) {
    final frequencyOptions = [
      _FrequencyOption(
        MedicineFrequency.daily,
        'Once Daily',
        'Every day at the same time',
        FIcons.clock,
      ),
      _FrequencyOption(
        MedicineFrequency.twiceDaily,
        'Twice Daily',
        'Morning and evening',
        FIcons.sunrise,
      ),
      _FrequencyOption(
        MedicineFrequency.thriceDaily,
        '3 Times Daily',
        'Morning, afternoon, and evening',
        FIcons.sunset,
      ),
      _FrequencyOption(
        MedicineFrequency.periodic,
        'Periodic',
        'Choose specific days',
        FIcons.calendar,
      ),
    ];

    return Column(
      children: frequencyOptions.map((option) {
        final isSelected = provider.formData.frequency == option.frequency;

        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => provider.setFrequency(option.frequency),
              borderRadius: BorderRadius.circular(12.r),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? context.theme.colors.primary
                        : context.theme.colors.border,
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                  color: isSelected
                      ? context.theme.colors.primary.withValues(alpha: 0.1)
                      : context.theme.colors.muted,
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? context.theme.colors.primary
                              : context.theme.colors.muted,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          option.icon,
                          color: isSelected
                              ? context.theme.colors.primaryForeground
                              : context.theme.colors.mutedForeground,
                          size: 24.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.title,
                              style: context.theme.typography.lg.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? context.theme.colors.primary
                                    : context.theme.colors.foreground,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              option.description,
                              style: context.theme.typography.sm.copyWith(
                                color: context.theme.colors.mutedForeground,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          FIcons.check,
                          color: context.theme.colors.primary,
                          size: 24.r,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _FrequencyOption {
  final MedicineFrequency frequency;
  final String title;
  final String description;
  final IconData icon;

  _FrequencyOption(this.frequency, this.title, this.description, this.icon);
}
