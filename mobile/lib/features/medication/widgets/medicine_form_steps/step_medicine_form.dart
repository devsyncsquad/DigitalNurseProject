import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/medicine_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/modern_surface_theme.dart';
import '../../providers/medicine_form_provider.dart';

class StepMedicineForm extends StatelessWidget {
  const StepMedicineForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineFormProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What form is your medicine?',
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildFormOptions(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildFormOptions(
    BuildContext context,
    MedicineFormProvider provider,
  ) {
    final formOptions = [
      _FormOption(
        MedicineForm.tablet,
        'Tablet',
        FIcons.square,
        'Solid form, usually round or oval',
      ),
      _FormOption(
        MedicineForm.capsule,
        'Capsule',
        FIcons.circle,
        'Gelatin shell containing medicine',
      ),
      _FormOption(
        MedicineForm.syrup,
        'Syrup',
        FIcons.beaker,
        'Liquid form, easy to swallow',
      ),
      _FormOption(
        MedicineForm.injection,
        'Injection',
        FIcons.activity,
        'Given through syringe',
      ),
      _FormOption(
        MedicineForm.drops,
        'Drops',
        FIcons.beaker,
        'Liquid drops (eyes, ears, mouth)',
      ),
      _FormOption(
        MedicineForm.inhaler,
        'Inhaler',
        FIcons.wind,
        'Spray or mist for breathing',
      ),
      _FormOption(
        MedicineForm.other,
        'Other',
        FIcons.file,
        'Any other form not listed',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: formOptions.length,
      itemBuilder: (context, index) {
        final option = formOptions[index];
        final isSelected = provider.formData.medicineForm == option.form;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => provider.setMedicineForm(option.form),
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? AppTheme.appleGreen
                      : context.theme.colors.border,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? AppTheme.appleGreen.withValues(alpha: 0.1)
                    : context.theme.colors.muted,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      option.icon,
                      size: 32,
                      color: isSelected
                          ? AppTheme.appleGreen
                          : context.theme.colors.mutedForeground,
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        option.title,
                        style: context.theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? ModernSurfaceTheme.deepTeal
                              : context.theme.colors.foreground,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Flexible(
                      child: Text(
                        option.description,
                        style: context.theme.typography.xs.copyWith(
                          color: context.theme.colors.mutedForeground,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FormOption {
  final MedicineForm form;
  final String title;
  final IconData icon;
  final String description;

  _FormOption(this.form, this.title, this.icon, this.description);
}
