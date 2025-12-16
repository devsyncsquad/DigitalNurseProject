import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/lifestyle_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/diet_plan_model.dart';
import '../../../core/models/exercise_plan_model.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/modern_scaffold.dart';
import '../widgets/apply_plan_dialog.dart';

class WeeklyPlansScreen extends StatefulWidget {
  const WeeklyPlansScreen({super.key});

  @override
  State<WeeklyPlansScreen> createState() => _WeeklyPlansScreenState();
}

class _WeeklyPlansScreenState extends State<WeeklyPlansScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPlans();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPlans() async {
    final authProvider = context.read<AuthProvider>();
    final lifestyleProvider = context.read<LifestyleProvider>();
    final userId = authProvider.currentUser?.id;

    if (userId != null) {
      await lifestyleProvider.loadDietPlans();
      await lifestyleProvider.loadExercisePlans();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final onPrimary = colorScheme.onPrimary;

    return ModernScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Weekly Plans',
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
                  Tab(text: 'Diet Plans'),
                  Tab(text: 'Workout Plans'),
                ],
              ),
            ),

            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _DietPlansTab(onRefresh: _loadPlans),
                  _ExercisePlansTab(onRefresh: _loadPlans),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DietPlansTab extends StatelessWidget {
  final VoidCallback onRefresh;

  const _DietPlansTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final lifestyleProvider = context.watch<LifestyleProvider>();
    final plans = lifestyleProvider.dietPlans;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/lifestyle/plans/diet/create'),
              icon: const Icon(FIcons.plus),
              label: const Text('Create Diet Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.appleGreen,
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
          child: lifestyleProvider.isLoading && plans.isEmpty
              ? Center(child: CircularProgressIndicator())
              : plans.isEmpty
                  ? _buildEmptyState(
                      context,
                      icon: FIcons.utensils,
                      title: 'No diet plans yet',
                      message: 'Create your first weekly diet plan to get started',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    )
                  : RefreshIndicator(
                      onRefresh: () async => onRefresh(),
                      child: ListView.builder(
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          return _PlanCard(
                            plan: plan,
                            isDietPlan: true,
                            onApply: () => _showApplyDialog(context, plan.id, true),
                            onEdit: () => context.push('/lifestyle/plans/diet/edit/${plan.id}'),
                            onDelete: () => _showDeleteDialog(context, plan.id, plan.planName, true),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  void _showApplyDialog(BuildContext context, String planId, bool isDietPlan) {
    showDialog(
      context: context,
      builder: (context) => ApplyPlanDialog(
        planId: planId,
        isDietPlan: isDietPlan,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String planId, String planName, bool isDietPlan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "$planName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final lifestyleProvider = context.read<LifestyleProvider>();
              final success = await lifestyleProvider.deleteDietPlan(planId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Plan deleted successfully'),
                      backgroundColor: AppTheme.getSuccessColor(context),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete plan: ${lifestyleProvider.error}'),
                      backgroundColor: AppTheme.getErrorColor(context),
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

class _ExercisePlansTab extends StatelessWidget {
  final VoidCallback onRefresh;

  const _ExercisePlansTab({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final lifestyleProvider = context.watch<LifestyleProvider>();
    final plans = lifestyleProvider.exercisePlans;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/lifestyle/plans/exercise/create'),
              icon: const Icon(FIcons.plus),
              label: const Text('Create Workout Plan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.appleGreen,
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
          child: lifestyleProvider.isLoading && plans.isEmpty
              ? Center(child: CircularProgressIndicator())
              : plans.isEmpty
                  ? _buildEmptyState(
                      context,
                      icon: FIcons.activity,
                      title: 'No workout plans yet',
                      message: 'Create your first weekly workout plan to get started',
                      colorScheme: colorScheme,
                      textTheme: textTheme,
                    )
                  : RefreshIndicator(
                      onRefresh: () async => onRefresh(),
                      child: ListView.builder(
                        itemCount: plans.length,
                        itemBuilder: (context, index) {
                          final plan = plans[index];
                          return _PlanCard(
                            plan: plan,
                            isDietPlan: false,
                            onApply: () => _showApplyDialog(context, plan.id, false),
                            onEdit: () => context.push('/lifestyle/plans/exercise/edit/${plan.id}'),
                            onDelete: () => _showDeleteDialog(context, plan.id, plan.planName, false),
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }

  void _showApplyDialog(BuildContext context, String planId, bool isDietPlan) {
    showDialog(
      context: context,
      builder: (context) => ApplyPlanDialog(
        planId: planId,
        isDietPlan: isDietPlan,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String planId, String planName, bool isDietPlan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "$planName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final lifestyleProvider = context.read<LifestyleProvider>();
              final success = await lifestyleProvider.deleteExercisePlan(planId);
              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Plan deleted successfully'),
                      backgroundColor: AppTheme.getSuccessColor(context),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete plan: ${lifestyleProvider.error}'),
                      backgroundColor: AppTheme.getErrorColor(context),
                    ),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
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

class _PlanCard extends StatelessWidget {
  final dynamic plan; // DietPlanModel or ExercisePlanModel
  final bool isDietPlan;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.isDietPlan,
    required this.onApply,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final itemCount = isDietPlan
        ? (plan as DietPlanModel).items.length
        : (plan as ExercisePlanModel).items.length;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        decoration: ModernSurfaceTheme.glassCard(
          context,
          accent: isDietPlan ? ModernSurfaceTheme.primaryTeal : ModernSurfaceTheme.accentBlue,
        ),
        padding: ModernSurfaceTheme.cardPadding(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: ModernSurfaceTheme.iconBadge(
                    context,
                    isDietPlan ? ModernSurfaceTheme.primaryTeal : ModernSurfaceTheme.accentBlue,
                  ),
                  child: Icon(
                    isDietPlan ? FIcons.utensils : FIcons.activity,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.planName,
                        style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                      ),
                      if (plan.description.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          plan.description,
                          style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Text(
                        '$itemCount ${isDietPlan ? 'meals' : 'workouts'}',
                        style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onApply,
                  icon: const Icon(FIcons.calendar, size: 16),
                  label: const Text('Apply'),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(FIcons.pencil, size: 16),
                  label: const Text('Edit'),
                ),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(FIcons.trash, size: 16),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

