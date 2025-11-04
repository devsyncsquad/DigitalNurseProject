import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/models/vital_measurement_model.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';

class HealthTrendsScreen extends StatefulWidget {
  const HealthTrendsScreen({super.key});

  @override
  State<HealthTrendsScreen> createState() => _HealthTrendsScreenState();
}

class _HealthTrendsScreenState extends State<HealthTrendsScreen> {
  VitalType _selectedType = VitalType.bloodPressure;
  int _selectedDays = 7;
  Map<String, dynamic>? _trends;

  @override
  void initState() {
    super.initState();
    _loadTrends();
  }

  Future<void> _loadTrends() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser!.id;

    final trends = await context.read<HealthProvider>().calculateTrends(
      userId,
      _selectedType,
      days: _selectedDays,
    );

    setState(() {
      _trends = trends;
    });
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
          title: const Text('Health Trends'),
          prefixes: [FHeaderAction.back(onPress: () => context.pop())],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Type selector
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Vital Type',
                          style: context.theme.typography.sm.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          child: DropdownButton<VitalType>(
                            value: _selectedType,
                            isExpanded: true,
                            items: VitalType.values.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(type.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                });
                                _loadTrends();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Period selector
                FCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time Period',
                          style: context.theme.typography.sm.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Material(
                          child: Wrap(
                            spacing: 8,
                            children: [7, 14, 30].map((days) {
                              return FilterChip(
                                label: Text('$days days'),
                                selected: _selectedDays == days,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedDays = days;
                                    });
                                    _loadTrends();
                                  }
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Trends summary
                if (_trends == null)
                  const Center(child: CircularProgressIndicator())
                else if (_trends!['count'] == 0)
                  FCard(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No data available for this period',
                          style: context.theme.typography.base,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Summary',
                        style: context.theme.typography.lg.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Stats cards
                      Row(
                        children: [
                          Expanded(
                            child: FCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Average',
                                      style: context.theme.typography.sm,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_trends!['average'].toStringAsFixed(1)} ${_selectedType.unit}',
                                      style: context.theme.typography.xl
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: context.theme.colors.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Readings',
                                      style: context.theme.typography.sm,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '${_trends!['count']}',
                                      style: context.theme.typography.xl
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: context.theme.colors.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Alert if abnormal
                      if (_trends!['hasAbnormal'])
                        FCard(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.getWarningColor(context).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(FIcons.info, color: AppTheme.getWarningColor(context)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Some readings are outside normal range. Consider consulting your healthcare provider.',
                                    style: context.theme.typography.sm,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
