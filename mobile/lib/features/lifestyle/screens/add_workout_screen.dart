import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/exercise_log_model.dart';
import '../../../core/providers/lifestyle_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  ActivityType _activityType = ActivityType.walking;

  @override
  void dispose() {
    _descriptionController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser!.id;

    final workout = ExerciseLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      activityType: _activityType,
      description: _descriptionController.text.trim(),
      durationMinutes: int.parse(_durationController.text.trim()),
      caloriesBurned: int.parse(_caloriesController.text.trim()),
      timestamp: DateTime.now(),
      userId: userId,
    );

    final success = await context.read<LifestyleProvider>().addExerciseLog(
      workout,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Workout logged successfully'),
            backgroundColor: AppTheme.getSuccessColor(context),
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.pop();
        }
      },
      child: FScaffold(
        header: FHeader.nested(
          title: const Text('Add Workout'),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Activity type dropdown
                  FCard(
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Activity Type',
                            style: context.theme.typography.sm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Material(
                            child: DropdownButton<ActivityType>(
                              value: _activityType,
                              isExpanded: true,
                              items: ActivityType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _activityType = value;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  FTextField(
                    controller: _descriptionController,
                    label: const Text('Description'),
                    hint: 'Additional details',
                  ),
                  SizedBox(height: 16.h),

                  FTextField(
                    controller: _durationController,
                    label: const Text('Duration (minutes)'),
                    hint: 'How long did you exercise?',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),

                  FTextField(
                    controller: _caloriesController,
                    label: const Text('Calories Burned'),
                    hint: 'Estimated calories',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24.h),

                  FButton(
                    onPress: _handleSave,
                    child: const Text('Save Workout'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
