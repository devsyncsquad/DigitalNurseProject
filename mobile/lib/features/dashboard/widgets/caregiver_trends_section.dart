import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/medicine_model.dart';
import '../../../core/models/vital_measurement_model.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/providers/medication_provider.dart';
import '../../../core/theme/app_theme.dart';

class CaregiverAdherenceAndVitalsRow extends StatelessWidget {
  const CaregiverAdherenceAndVitalsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final children = const [
          _VitalsTrendCard(),
          _AdherenceSparklineCard(),
        ];
        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(children.length, (index) {
              final child = children[index];
              final isLast = index == children.length - 1;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: isLast ? 0 : 12.w),
                  child: child,
                ),
              );
            }),
          );
        }
        return Column(
          children: List.generate(children.length, (index) {
            final child = children[index];
            final isLast = index == children.length - 1;
            return Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              child: child,
            );
          }),
        );
      },
    );
  }
}

class _VitalsTrendCard extends StatelessWidget {
  const _VitalsTrendCard();

  @override
  Widget build(BuildContext context) {
    final healthProvider = context.watch<HealthProvider>();

    final trendData = _TrendData.fromVitals(healthProvider.vitals);

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vitals trend',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          if (trendData == null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'Not enough data to display trends yet.',
                style: context.theme.typography.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            )
          else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  trendData.label,
                  style: context.theme.typography.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${trendData.points.last.value.toStringAsFixed(1)} ${trendData.unit}',
                  style: context.theme.typography.sm.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 120.h,
              child: SparklineChart(
                values: trendData.points.map((point) => point.value).toList(),
                color: context.theme.colors.primary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Last updated: ${DateFormat('MMM d, h:mm a').format(trendData.points.last.timestamp)}',
              style: context.theme.typography.xs.copyWith(
                color: context.theme.colors.mutedForeground,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AdherenceSparklineCard extends StatelessWidget {
  const _AdherenceSparklineCard();

  Future<List<_TrendPoint>> _loadAdherenceHistory(
    BuildContext context,
    List<MedicineModel> medicines,
  ) async {
    if (medicines.isEmpty) {
      return const [];
    }

    final medicationProvider = context.read<MedicationProvider>();
    final points = <_TrendPoint>[];

    for (final medicine in medicines.take(3)) {
      try {
        final history = await medicationProvider.getIntakeHistory(
          medicine.id,
          elderUserId: medicine.userId,
        );
        for (final intake in history) {
          final status = intake.status;
          final value = status == IntakeStatus.taken
              ? 1.0
              : status == IntakeStatus.skipped
                  ? 0.5
                  : 0.0;
          points.add(
            _TrendPoint(
              timestamp: intake.scheduledTime,
              value: value,
            ),
          );
        }
      } catch (e, stackTrace) {
        debugPrint(
          'Failed to load intake history for medicine ${medicine.id}: $e\n$stackTrace',
        );
      }
    }

    points.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return points.takeLast(14).toList();
  }

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationProvider>();

    return FutureBuilder<List<_TrendPoint>>(
      future: _loadAdherenceHistory(context, medicationProvider.medicines),
      builder: (context, snapshot) {
        final points = snapshot.data ?? [];
        return FCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Medication adherence',
                style: context.theme.typography.sm.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              if (snapshot.connectionState == ConnectionState.waiting)
                SizedBox(
                  height: 120.h,
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (points.length < 2)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: Text(
                    'Not enough adherence history yet.',
                    style: context.theme.typography.xs.copyWith(
                      color: context.theme.colors.mutedForeground,
                    ),
                  ),
                )
              else ...[
                SizedBox(
                  height: 120.h,
                  child: SparklineChart(
                    values: points.map((point) => point.value * 100).toList(),
                    color: AppTheme.getSuccessColor(context),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'Last 14 doses • ${points.last.value == 1.0 ? 'Taken' : points.last.value == 0.5 ? 'Skipped' : 'Missed'}',
                  style: context.theme.typography.xs.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class SparklineChart extends StatelessWidget {
  final List<double> values;
  final Color color;

  const SparklineChart({
    super.key,
    required this.values,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: color),
      ),
    );
  }
}

class _TrendData {
  final String label;
  final String unit;
  final List<_TrendPoint> points;

  const _TrendData({
    required this.label,
    required this.unit,
    required this.points,
  });

  factory _TrendData.fromType(
    VitalType type,
    List<VitalMeasurementModel> vitals,
  ) {
    final filtered = vitals
        .where((vital) => vital.type == type)
        .map((vital) {
          final value = _TrendPoint.parseVitalValue(vital);
          if (value == null) return null;
          return _TrendPoint(timestamp: vital.timestamp, value: value);
        })
        .whereType<_TrendPoint>()
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return _TrendData(
      label: type.displayName,
      unit: type.unit,
      points: filtered.takeLast(10).toList(),
    );
  }

  static _TrendData? fromVitals(List<VitalMeasurementModel> vitals) {
    if (vitals.length < 2) {
      return null;
    }

    for (final type in [
      VitalType.heartRate,
      VitalType.bloodPressure,
      VitalType.bloodSugar,
      VitalType.temperature,
    ]) {
      final data = _TrendData.fromType(type, vitals);
      if (data.points.length >= 2) {
        return data;
      }
    }

    return null;
  }
}

class _TrendPoint {
  final DateTime timestamp;
  final double value;

  const _TrendPoint({
    required this.timestamp,
    required this.value,
  });

  static double? parseVitalValue(VitalMeasurementModel vital) {
    switch (vital.type) {
      case VitalType.bloodPressure:
        final parts = vital.value.split('/');
        if (parts.isEmpty) return null;
        return double.tryParse(parts.first.trim());
      case VitalType.bloodSugar:
      case VitalType.temperature:
        return double.tryParse(vital.value);
      case VitalType.heartRate:
      case VitalType.oxygenSaturation:
      case VitalType.weight:
        return double.tryParse(vital.value);
    }
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;

  _SparklinePainter({
    required this.values,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final minValue = values.reduce(min);
    final maxValue = values.reduce(max);
    final range = max(maxValue - minValue, 1e-6);

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i == 0
          ? 0.0
          : (i / (values.length - 1)) * size.width;
      final normalized = (values[i] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withOpacity(0.25),
          color.withOpacity(0.05),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}

extension _TakeLast<T> on List<T> {
  Iterable<T> takeLast(int count) {
    if (count <= 0) return const Iterable.empty();
    if (length <= count) return this;
    return sublist(length - count);
  }
}

