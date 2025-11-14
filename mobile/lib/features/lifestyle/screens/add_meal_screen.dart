import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/diet_log_model.dart';
import '../../../core/providers/lifestyle_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/widgets/modern_scaffold.dart';

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
      child: ModernScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Add Meal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          padding: ModernSurfaceTheme.screenPadding(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: ModernSurfaceTheme.glassCard(context),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meal Type',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ModernSurfaceTheme.deepTeal,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<MealType>(
                        value: _mealType,
                        isExpanded: true,
                        items: MealType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _mealType = value;
                            });
                          }
                        },
                      ),
                    ],
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
                ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernSurfaceTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text('Save Meal'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
