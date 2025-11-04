import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/diet_log_model.dart';
import '../../../core/providers/lifestyle_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();

  MealType _mealType = MealType.breakfast;

  @override
  void dispose() {
    _descriptionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser!.id;

    final meal = DietLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mealType: _mealType,
      description: _descriptionController.text.trim(),
      calories: int.parse(_caloriesController.text.trim()),
      timestamp: DateTime.now(),
      userId: userId,
    );

    final success = await context.read<LifestyleProvider>().addDietLog(meal);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Meal logged successfully'),
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
          title: const Text('Add Meal'),
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
                  // Meal type dropdown
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meal Type',
                            style: context.theme.typography.sm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Material(
                            child: DropdownButton<MealType>(
                              value: _mealType,
                              isExpanded: true,
                              items: MealType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(type.displayName),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _mealType = value;
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
                    hint: 'What did you eat?',
                    maxLines: 3,
                  ),
                  SizedBox(height: 16.h),

                  FTextField(
                    controller: _caloriesController,
                    label: const Text('Calories'),
                    hint: 'Estimated calories',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 24.h),

                  FButton(onPress: _handleSave, child: const Text('Save Meal')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
