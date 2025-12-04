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
import '../../../core/services/openai_service.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({super.key});

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _openAIService = OpenAIService();

  MealType _mealType = MealType.breakfast;
  bool _isAnalyzing = false;
  String? _analysisError;

  @override
  void initState() {
    super.initState();
    // Clear error when user types in description
    _descriptionController.addListener(() {
      if (_analysisError != null && mounted) {
        setState(() {
          _analysisError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _handleAnalyze() async {
    final description = _descriptionController.text.trim();
    
    if (description.isEmpty) {
      setState(() {
        _analysisError = 'Please enter a food description first';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisError = null;
    });

    try {
      final calories = await _openAIService.analyzeFoodCalories(description);
      
      if (mounted) {
        if (calories != null && calories > 0) {
          setState(() {
            _caloriesController.text = calories.toString();
            _analysisError = null;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Calculated: $calories calories'),
              backgroundColor: AppTheme.getSuccessColor(context),
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          setState(() {
            _analysisError = 'Unable to calculate calories. Please enter manually.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _analysisError = 'Analysis failed: ${e.toString().replaceAll('Exception: ', '')}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _handleSave() async {
    // Validate calories
    final caloriesText = _caloriesController.text.trim();
    if (caloriesText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter calories'),
          backgroundColor: AppTheme.getErrorColor(context),
        ),
      );
      return;
    }

    final calories = int.tryParse(caloriesText);
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid calorie amount'),
          backgroundColor: AppTheme.getErrorColor(context),
        ),
      );
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser!.id;

    final meal = DietLogModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      mealType: _mealType,
      description: _descriptionController.text.trim(),
      calories: calories,
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;

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
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            'Add Meal',
            style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: onPrimary,
                ),
          ),
        ),
        body: SingleChildScrollView(
          padding: ModernSurfaceTheme.screenPadding(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Meal Type Card
                Container(
                  decoration: ModernSurfaceTheme.glassCard(
                    context,
                    accent: ModernSurfaceTheme.primaryTeal,
                  ),
                  padding: ModernSurfaceTheme.cardPadding(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meal Type',
                        style: ModernSurfaceTheme.sectionTitleStyle(context),
                      ),
                      SizedBox(height: 12.h),
                      DropdownButtonFormField<MealType>(
                        value: _mealType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                        items: MealType.values
                            .map(
                              (type) => DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type.displayName,
                                  style: textTheme.bodyMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                      ),
                                ),
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
                SizedBox(height: 20.h),

                // Description Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FTextField(
                      controller: _descriptionController,
                      label: const Text('Description'),
                      hint: 'What did you eat? (e.g., "Grilled chicken breast with rice and vegetables")',
                      maxLines: 3,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                // Analyze Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _isAnalyzing ? null : _handleAnalyze,
                    icon: _isAnalyzing
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ModernSurfaceTheme.primaryTeal,
                              ),
                            ),
                          )
                        : const Icon(FIcons.sparkles),
                    label: Text(_isAnalyzing ? 'Analyzing...' : 'Analyze with AI'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      side: BorderSide(
                        color: ModernSurfaceTheme.primaryTeal,
                        width: 1.5,
                      ),
                      foregroundColor: ModernSurfaceTheme.primaryTeal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),

                // Analysis Error Message
                if (_analysisError != null) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppTheme.getErrorColor(context).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getErrorColor(context).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          FIcons.info,
                          color: AppTheme.getErrorColor(context),
                          size: 20,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            _analysisError!,
                            style: textTheme.bodySmall?.copyWith(
                                  color: AppTheme.getErrorColor(context),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 20.h),

                // Calories Field
                FTextField(
                  controller: _caloriesController,
                  label: const Text('Calories'),
                  hint: 'Enter calories or use AI analysis above',
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 32.h),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ModernSurfaceTheme.primaryTeal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Save Meal',
                      style: textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
