import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;

    return ModernScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Diet & Exercise',
          style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onPrimary,
              ),
        ),
      ),
      body: Padding(
        padding: ModernSurfaceTheme.screenPadding(),
        child: Column(
          children: [
            // Daily summary
            if (summary != null) ...[
              _DailySummaryCard(summary: summary),
              SizedBox(height: 16.h),
            ],

            // Tab bar
            Container(
              decoration: ModernSurfaceTheme.glassCard(context),
              margin: EdgeInsets.only(bottom: 16.h),
              child: TabBar(
                controller: _tabController,
                indicatorColor: ModernSurfaceTheme.primaryTeal,
                labelColor: ModernSurfaceTheme.primaryTeal,
                unselectedLabelColor: ModernSurfaceTheme.deepTeal.withValues(alpha: 0.5),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Meals'),
                  Tab(text: 'Workouts'),
                ],
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
      ),
    );
  }
}

class _MealsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lifestyleProvider = context.watch<LifestyleProvider>();
    final meals = lifestyleProvider.dietLogs;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/lifestyle/meal/add'),
              icon: const Icon(FIcons.plus),
              label: const Text('Add Meal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernSurfaceTheme.primaryTeal,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: meals.isEmpty
              ? _buildEmptyState(
                  context,
                  icon: FIcons.utensils,
                  title: 'No meals logged today',
                  message: 'Tap the button above to add your first meal',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                )
              : ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Container(
                        decoration: ModernSurfaceTheme.glassCard(
                          context,
                          accent: ModernSurfaceTheme.primaryTeal,
                        ),
                        padding: ModernSurfaceTheme.cardPadding(),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: ModernSurfaceTheme.iconBadge(
                                context,
                                ModernSurfaceTheme.primaryTeal,
                              ),
                              child: const Icon(FIcons.utensils, color: Colors.white),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal.mealType.displayName,
                                    style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    meal.description,
                                    style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    DateFormat('h:mm a').format(meal.timestamp),
                                    style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${meal.calories}',
                                  style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ModernSurfaceTheme.primaryTeal,
                                      ),
                                ),
                                Text(
                                  'cal',
                                  style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
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

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      decoration: ModernSurfaceTheme.glassCard(context),
      padding: ModernSurfaceTheme.cardPadding(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: colorScheme.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lifestyleProvider = context.watch<LifestyleProvider>();
    final workouts = lifestyleProvider.exerciseLogs;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/lifestyle/workout/add'),
              icon: const Icon(FIcons.plus),
              label: const Text('Add Workout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ModernSurfaceTheme.accentBlue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: workouts.isEmpty
              ? _buildEmptyState(
                  context,
                  icon: FIcons.activity,
                  title: 'No workouts logged today',
                  message: 'Tap the button above to add your first workout',
                  colorScheme: colorScheme,
                  textTheme: textTheme,
                )
              : ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Container(
                        decoration: ModernSurfaceTheme.glassCard(
                          context,
                          accent: ModernSurfaceTheme.accentBlue,
                        ),
                        padding: ModernSurfaceTheme.cardPadding(),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: ModernSurfaceTheme.iconBadge(
                                context,
                                ModernSurfaceTheme.accentBlue,
                              ),
                              child: const Icon(FIcons.activity, color: Colors.white),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    workout.activityType.displayName,
                                    style: textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: colorScheme.onSurface,
                                        ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    workout.description,
                                    style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '${workout.durationMinutes} min • ${DateFormat('h:mm a').format(workout.timestamp)}',
                                    style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${workout.caloriesBurned}',
                                  style: textTheme.bodyLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: ModernSurfaceTheme.accentBlue,
                                      ),
                                ),
                                Text(
                                  'cal',
                                  style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
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

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String message,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    return Container(
      decoration: ModernSurfaceTheme.glassCard(context),
      padding: ModernSurfaceTheme.cardPadding(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 48,
            color: colorScheme.primary,
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _DailySummaryCard extends StatelessWidget {
  final Map<String, dynamic> summary;

  const _DailySummaryCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      decoration: ModernSurfaceTheme.heroDecoration(context),
      padding: ModernSurfaceTheme.heroPadding(),
      child: Row(
        children: [
          _SummaryMetric(
            icon: FIcons.utensils,
            label: 'Calories In',
            value: '${summary['caloriesIn']}',
            onPrimary: onPrimary,
            textTheme: textTheme,
          ),
          _SummaryMetric(
            icon: FIcons.activity,
            label: 'Calories Out',
            value: '${summary['caloriesOut']}',
            onPrimary: onPrimary,
            textTheme: textTheme,
          ),
          _SummaryMetric(
            icon: FIcons.trendingUp,
            label: 'Net',
            value: '${summary['netCalories']}',
            onPrimary: onPrimary,
            textTheme: textTheme,
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color onPrimary;
  final TextTheme textTheme;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
    required this.onPrimary,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: onPrimary),
          SizedBox(height: 8.h),
          Text(
            value,
            style: textTheme.headlineSmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
                  color: onPrimary.withValues(alpha: 0.85),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
