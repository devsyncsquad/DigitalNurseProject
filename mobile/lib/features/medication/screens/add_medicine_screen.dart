import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/medicine_form_provider.dart';
import '../widgets/medicine_form_shared/form_step_container.dart';
import '../widgets/medicine_form_steps/step_medicine_name.dart';
import '../widgets/medicine_form_steps/step_medicine_form.dart';
import '../widgets/medicine_form_steps/step_frequency.dart';
import '../widgets/medicine_form_steps/step_schedule_times.dart';
import '../widgets/medicine_form_steps/step_start_date.dart';
import '../widgets/medicine_form_steps/step_dose_strength.dart';
import '../widgets/medicine_form_steps/step_summary.dart';

class AddMedicineScreen extends StatefulWidget {
  const AddMedicineScreen({super.key});

  @override
  State<AddMedicineScreen> createState() => _AddMedicineScreenState();
}

class _AddMedicineScreenState extends State<AddMedicineScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MedicineFormProvider(),
      child: Consumer<MedicineFormProvider>(
        builder: (context, formProvider, child) {
          return FScaffold(
            header: FHeader.nested(
              title: const Text('Add Medicine'),
              prefixes: [
                FHeaderAction.back(
                  onPress: () => _handleBack(context, formProvider),
                ),
              ],
            ),
            child: Column(
              children: [
                // Progress indicator
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${formProvider.currentStep + 1} of ${formProvider.totalSteps}',
                        style: context.theme.typography.sm.copyWith(
                          fontWeight: FontWeight.w600,
                          color: context.theme.colors.mutedForeground,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4.r),
                        child: LinearProgressIndicator(
                          value: formProvider.progress,
                          minHeight: 8.h,
                          backgroundColor: context.theme.colors.muted,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            context.theme.colors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error message
                if (formProvider.errorMessage != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                      child: Text(
                        formProvider.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),

                // Step content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: _buildStepContent(formProvider),
                  ),
                ),

                // Navigation buttons
                _buildNavigationButtons(context, formProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(MedicineFormProvider formProvider) {
    switch (formProvider.currentStep) {
      case 0:
        return FormStepContainer(
          title: 'Medicine Name',
          description: 'Let\'s start with the basics',
          stepNumber: 0,
          child: const StepMedicineName(),
        );
      case 1:
        return FormStepContainer(
          title: 'Medicine Form',
          description: 'What form is your medicine in?',
          stepNumber: 1,
          child: const StepMedicineForm(),
        );
      case 2:
        return FormStepContainer(
          title: 'Frequency',
          description: 'How often do you take it?',
          stepNumber: 2,
          child: const StepFrequency(),
        );
      case 3:
        return FormStepContainer(
          title: 'Reminder Times',
          description: 'Set your reminder times',
          stepNumber: 3,
          child: const StepScheduleTimes(),
        );
      case 4:
        return FormStepContainer(
          title: 'Start Date',
          description: 'When do you start?',
          stepNumber: 4,
          child: const StepStartDate(),
        );
      case 5:
        return FormStepContainer(
          title: 'Dosage & Strength',
          description: 'Dosage and strength details',
          stepNumber: 5,
          child: const StepDoseStrength(),
        );
      case 6:
        return FormStepContainer(
          title: 'Review',
          description: 'Review before saving',
          stepNumber: 6,
          child: const StepSummary(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavigationButtons(
    BuildContext context,
    MedicineFormProvider formProvider,
  ) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (!formProvider.isFirstStep)
              Expanded(
                child: FButton(
                  style: FButtonStyle.outline(),
                  onPress: () => formProvider.previousStep(),
                  child: const Text('Back'),
                ),
              ),

            if (!formProvider.isFirstStep) SizedBox(width: 12.w),

            Expanded(
              child: FButton(
                onPress: formProvider.isLastStep
                    ? () => _handleSave(context, formProvider)
                    : () => formProvider.nextStep(),
                child: Text(formProvider.isLastStep ? 'Save Medicine' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBack(BuildContext context, MedicineFormProvider formProvider) {
    if (formProvider.isFirstStep) {
      context.pop();
    } else {
      formProvider.previousStep();
    }
  }

  Future<void> _handleSave(
    BuildContext context,
    MedicineFormProvider formProvider,
  ) async {
    if (!formProvider.validateCurrentStep()) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('User not authenticated'),
          backgroundColor: AppTheme.getErrorColor(context),
        ),
      );
      return;
    }

    final medicine = formProvider.generateMedicineModel(userId);
    if (medicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please complete all required fields'),
          backgroundColor: AppTheme.getErrorColor(context),
        ),
      );
      return;
    }

    final success = await context.read<MedicationProvider>().addMedicine(
      medicine,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Medicine added successfully!'),
            backgroundColor: AppTheme.getSuccessColor(context),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to add medicine'),
            backgroundColor: AppTheme.getErrorColor(context),
          ),
        );
      }
    }
  }
}
