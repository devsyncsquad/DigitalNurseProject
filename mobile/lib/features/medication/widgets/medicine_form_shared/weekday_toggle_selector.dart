import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeekdayToggleSelector extends StatelessWidget {
  final List<int> selectedDays;
  final Function(List<int>) onDaysChanged;

  const WeekdayToggleSelector({
    super.key,
    required this.selectedDays,
    required this.onDaysChanged,
  });

  static const List<String> dayLabels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
  static const List<String> dayNames = [
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
  ];
  static const List<int> dayValues = [
    7,
    1,
    2,
    3,
    4,
    5,
    6,
  ]; // 1=Monday, 7=Sunday

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days',
          style: context.theme.typography.sm.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final isSelected = selectedDays.contains(dayValues[index]);
            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: index == 0 || index == 6 ? 0 : 4.w,
                ),
                child: _buildDayToggle(context, index, isSelected),
              ),
            );
          }),
        ),
        SizedBox(height: 8.h),
        Text(
          'Selected: ${_getSelectedDayNames()}',
          style: context.theme.typography.sm.copyWith(
            color: context.theme.colors.mutedForeground,
          ),
        ),
      ],
    );
  }

  Widget _buildDayToggle(BuildContext context, int index, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleDay(index),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? context.theme.colors.primary
                : context.theme.colors.muted,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? context.theme.colors.primary
                  : context.theme.colors.border,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(
                dayLabels[index],
                style: context.theme.typography.sm.copyWith(
                  color: isSelected
                      ? context.theme.colors.primaryForeground
                      : context.theme.colors.foreground,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dayNames[index],
                style: context.theme.typography.xs.copyWith(
                  color: isSelected
                      ? context.theme.colors.primaryForeground
                      : context.theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _toggleDay(int index) {
    final dayValue = dayValues[index];
    final newSelectedDays = List<int>.from(selectedDays);

    if (newSelectedDays.contains(dayValue)) {
      newSelectedDays.remove(dayValue);
    } else {
      newSelectedDays.add(dayValue);
    }

    // Sort the days (Monday = 1, Sunday = 7)
    newSelectedDays.sort((a, b) {
      // Convert to Monday-first ordering for sorting
      final aOrder = a == 7 ? 0 : a;
      final bOrder = b == 7 ? 0 : b;
      return aOrder.compareTo(bOrder);
    });

    onDaysChanged(newSelectedDays);
  }

  String _getSelectedDayNames() {
    if (selectedDays.isEmpty) return 'None';

    final sortedDays = List<int>.from(selectedDays);
    sortedDays.sort((a, b) {
      final aOrder = a == 7 ? 0 : a;
      final bOrder = b == 7 ? 0 : b;
      return aOrder.compareTo(bOrder);
    });

    return sortedDays.map((day) => dayNames[dayValues.indexOf(day)]).join(', ');
  }
}
