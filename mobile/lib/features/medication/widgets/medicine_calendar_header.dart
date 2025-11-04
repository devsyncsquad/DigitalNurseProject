import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class MedicineCalendarHeader extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const MedicineCalendarHeader({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: FLineCalendar(
        initialSelection: selectedDate,
        initialScroll: selectedDate,
        onChange: (date) => onDateChanged(date ?? DateTime.now()),
        toggleable: true,
        start: DateTime(1900),
        end: DateTime(2050),
        today: DateTime.now(),
      ),
    );
  }
}
