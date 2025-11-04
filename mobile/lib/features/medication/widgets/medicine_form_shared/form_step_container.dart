import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FormStepContainer extends StatelessWidget {
  final String title;
  final String? description;
  final Widget child;
  final int stepNumber;

  const FormStepContainer({
    super.key,
    required this.title,
    this.description,
    required this.child,
    required this.stepNumber,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              ),
          child: child,
        );
      },
      child: Column(
        key: ValueKey(stepNumber),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.theme.typography.xl),
              if (description != null) ...[
                SizedBox(height: 8.h),
                Text(
                  description!,
                  style: context.theme.typography.base.copyWith(
                    color: context.theme.colors.mutedForeground,
                  ),
                ),
              ],
              SizedBox(height: 24.h),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: child,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
