import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/medicine_model.dart';
import '../../../core/providers/medication_provider.dart';

class CaregiverUpcomingMedicationsCard extends StatelessWidget {
  const CaregiverUpcomingMedicationsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final medicationProvider = context.watch<MedicationProvider>();
    final upcoming = [...medicationProvider.upcomingReminders]
      ..sort((a, b) {
        final aTime = a['reminderTime'] as DateTime;
        final bTime = b['reminderTime'] as DateTime;
        return aTime.compareTo(bTime);
      });

    final now = DateTime.now();
    final nextReminders = upcoming.where((reminder) {
      final time = reminder['reminderTime'] as DateTime;
      return !time.isBefore(now);
    }).toList();

    return FCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming medicines',
            style: context.theme.typography.sm.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          if (nextReminders.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              child: Text(
                'No upcoming doses scheduled.',
                style: context.theme.typography.xs.copyWith(
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            )
          else
            ...nextReminders.take(4).map((reminder) {
              final medicine = reminder['medicine'] as MedicineModel;
              final time = reminder['reminderTime'] as DateTime;
              final isSoon = time.difference(now).inMinutes <= 30;
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.theme.colors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medication,
                        color: context.theme.colors.primary,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            medicine.name,
                            style: context.theme.typography.sm.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${medicine.dosage} • ${DateFormat('MMM d, h:mm a').format(time)}',
                            style: context.theme.typography.xs.copyWith(
                              color: context.theme.colors.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (isSoon) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('Reminder sent for ${medicine.name}'),
                            ),
                          );
                        } else {
                          context.push('/medications');
                        }
                      },
                      child: Text(isSoon ? 'Remind now' : 'Details'),
                    ),
                  ],
                ),
              );
            }).toList(),
          if (nextReminders.length > 4)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push('/medications'),
                child: const Text('View all medicines'),
              ),
            ),
        ],
      ),
    );
  }
}

