import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/lifestyle_provider.dart';
import '../../../core/extensions/meal_type_extensions.dart';
import '../../../core/extensions/activity_type_extensions.dart';
import '../../../core/theme/app_theme.dart';

class DietExerciseLogScreen extends StatefulWidget {
  const DietExerciseLogScreen({super.key});

  @override
  State<DietExerciseLogScreen> createState() => _DietExerciseLogScreenState();
}

class _DietExerciseLogScreenState extends State<DietExerciseLogScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lifestyleProvider = context.watch<LifestyleProvider>();
    final summary = lifestyleProvider.dailySummary;

    return FScaffold(
      header: FHeader.nested(
        title: const Text('Diet & Exercise'),
        prefixes: [FHeaderAction.back(onPress: () => context.pop())],
      ),
      child: Column(
        children: [
          // Tab bar
          Material(
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Meals'),
                Tab(text: 'Workouts'),
              ],
            ),
          ),

          // Daily summary
          if (summary != null)
            Container(
              padding: const EdgeInsets.all(16),
              child: FCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              FIcons.utensils,
                              color: context.theme.colors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${summary['caloriesIn']}',
                              style: context.theme.typography.xl.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Calories In',
                              style: context.theme.typography.xs,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              FIcons.activity,
                              color: context.theme.colors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${summary['caloriesOut']}',
                              style: context.theme.typography.xl.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Calories Out',
                              style: context.theme.typography.xs,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Icon(
                              FIcons.trendingUp,
                              color: context.theme.colors.primary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${summary['netCalories']}',
                              style: context.theme.typography.xl.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Net', style: context.theme.typography.xs),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_MealsTab(), _WorkoutsTab()],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lifestyleProvider = context.watch<LifestyleProvider>();
    final meals = lifestyleProvider.dietLogs;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FButton(
            onPress: () => context.push('/lifestyle/meal/add'),
            prefix: const Icon(FIcons.plus),
            child: const Text('Add Meal'),
          ),
        ),
        Expanded(
          child: meals.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FIcons.utensils,
                        size: 48,
                        color: context.theme.colors.mutedForeground,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No meals logged today',
                        style: context.theme.typography.base,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.theme.colors.primary
                                      .withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  FIcons.utensils,
                                  color: context.theme.colors.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      meal.mealType.displayName,
                                      style: context.theme.typography.sm
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      meal.description,
                                      style: context.theme.typography.xs,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      DateFormat(
                                        'h:mm a',
                                      ).format(meal.timestamp),
                                      style: context.theme.typography.xs
                                          .copyWith(
                                            color: context
                                                .theme
                                                .colors
                                                .mutedForeground,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${meal.calories}',
                                style: context.theme.typography.base.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.theme.colors.primary,
                                ),
                              ),
                              Text(' cal', style: context.theme.typography.xs),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _WorkoutsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lifestyleProvider = context.watch<LifestyleProvider>();
    final workouts = lifestyleProvider.exerciseLogs;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: FButton(
            onPress: () => context.push('/lifestyle/workout/add'),
            prefix: const Icon(FIcons.plus),
            child: const Text('Add Workout'),
          ),
        ),
        Expanded(
          child: workouts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FIcons.activity,
                        size: 48,
                        color: context.theme.colors.mutedForeground,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No workouts logged today',
                        style: context.theme.typography.base,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.getSuccessColor(context).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  FIcons.activity,
                                  color: AppTheme.getSuccessColor(context),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      workout.activityType.displayName,
                                      style: context.theme.typography.sm
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    Text(
                                      '${workout.durationMinutes} min',
                                      style: context.theme.typography.xs,
                                    ),
                                    Text(
                                      DateFormat(
                                        'h:mm a',
                                      ).format(workout.timestamp),
                                      style: context.theme.typography.xs
                                          .copyWith(
                                            color: context
                                                .theme
                                                .colors
                                                .mutedForeground,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${workout.caloriesBurned}',
                                style: context.theme.typography.base.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.getSuccessColor(context),
                                ),
                              ),
                              Text(' cal', style: context.theme.typography.xs),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
