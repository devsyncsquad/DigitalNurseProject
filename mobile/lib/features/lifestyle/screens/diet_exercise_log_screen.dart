import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/lifestyle_provider.dart';
import '../../../core/extensions/meal_type_extensions.dart';
import '../../../core/extensions/activity_type_extensions.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/widgets/modern_scaffold.dart';

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

    return ModernScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Diet & Exercise',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            decoration: ModernSurfaceTheme.glassCard(),
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: TabBar(
              controller: _tabController,
              indicatorColor: ModernSurfaceTheme.primaryTeal,
              labelColor: ModernSurfaceTheme.primaryTeal,
              unselectedLabelColor: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.5),
              tabs: const [
                Tab(text: 'Meals'),
                Tab(text: 'Workouts'),
              ],
            ),
          ),

          // Daily summary
          if (summary != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: ModernSurfaceTheme.glassCard(highlighted: true),
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    _SummaryMetric(
                      icon: FIcons.utensils,
                      label: 'Calories In',
                      value: '${summary['caloriesIn']}',
                    ),
                    _SummaryMetric(
                      icon: FIcons.activity,
                      label: 'Calories Out',
                      value: '${summary['caloriesOut']}',
                    ),
                    _SummaryMetric(
                      icon: FIcons.trendingUp,
                      label: 'Net',
                      value: '${summary['netCalories']}',
                    ),
                  ],
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
          child: ElevatedButton.icon(
            onPressed: () => context.push('/lifestyle/meal/add'),
            icon: const Icon(FIcons.plus),
            label: const Text('Add Meal'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernSurfaceTheme.primaryTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
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
                      child: Container(
                        decoration: ModernSurfaceTheme.glassCard(
                          accent: ModernSurfaceTheme.primaryTeal,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration:
                                  ModernSurfaceTheme.iconBadge(ModernSurfaceTheme.primaryTeal),
                              child: const Icon(FIcons.utensils, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.mealType.displayName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: ModernSurfaceTheme.deepTeal,
                                        ),
                                  ),
                                  Text(
                                    meal.description,
                                    style: Theme.of(context).textTheme.bodySmall,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                    Text(
                                      DateFormat('h:mm a').format(meal.timestamp),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: ModernSurfaceTheme.deepTeal
                                                .withValues(alpha: 0.6),
                                          ),
                                    ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${meal.calories}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ModernSurfaceTheme.primaryTeal,
                                      ),
                                ),
                                Text(
                                  'cal',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: ModernSurfaceTheme.deepTeal
                                          .withValues(alpha: 0.6),
                                      ),
                                ),
                              ],
                            ),
                          ],
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
          child: ElevatedButton.icon(
            onPressed: () => context.push('/lifestyle/workout/add'),
            icon: const Icon(FIcons.plus),
            label: const Text('Add Workout'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ModernSurfaceTheme.accentBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
            ),
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
                      child: Container(
                        decoration: ModernSurfaceTheme.glassCard(
                          accent: ModernSurfaceTheme.accentBlue,
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: ModernSurfaceTheme.iconBadge(
                                ModernSurfaceTheme.accentBlue,
                              ),
                              child: const Icon(FIcons.activity, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workout.activityType.displayName,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: ModernSurfaceTheme.deepTeal,
                                        ),
                                  ),
                                  Text(
                                    '${workout.durationMinutes} min',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    DateFormat('h:mm a').format(workout.timestamp),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: ModernSurfaceTheme.deepTeal
                                              .withValues(alpha: 0.6),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${workout.caloriesBurned}',
                                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ModernSurfaceTheme.accentBlue,
                                      ),
                                ),
                              Text(
                                'cal',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: ModernSurfaceTheme.deepTeal
                                          .withValues(alpha: 0.6),
                                    ),
                              ),
                              ],
                            ),
                          ],
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

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
          ),
        ],
      ),
    );
  }
}
