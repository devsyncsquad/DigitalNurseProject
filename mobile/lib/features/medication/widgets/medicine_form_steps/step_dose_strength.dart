import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../providers/medicine_form_provider.dart';

class StepDoseStrength extends StatefulWidget {
  const StepDoseStrength({super.key});

  @override
  State<StepDoseStrength> createState() => _StepDoseStrengthState();
}

class _StepDoseStrengthState extends State<StepDoseStrength> {
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _strengthController = TextEditingController();
  String _selectedUnit = 'mg';

  static const List<String> _commonUnits = ['mg', 'ml', 'g', 'mcg', 'IU', '%'];

  static const List<String> _commonDoses = ['1', '2', '3', '1/2', '1/4', '5'];

  @override
  void initState() {
    super.initState();
    final provider = context.read<MedicineFormProvider>();

    _doseController.text = provider.formData.doseAmount;
    _strengthController.text = provider.formData.strength;

    _doseController.addListener(() {
      provider.setDoseAmount(_doseController.text);
    });

    _strengthController.addListener(() {
      if (_strengthController.text.isNotEmpty) {
        provider.setStrength('${_strengthController.text}$_selectedUnit');
      }
    });
  }

  @override
  void dispose() {
    _doseController.dispose();
    _strengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicineFormProvider>(
      builder: (context, provider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What\'s the dose and strength?',
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 24.h),

            // Dose Amount Section
            _buildDoseSection(context, provider),

            SizedBox(height: 24.h),

            // Strength Section
            _buildStrengthSection(context, provider),
          ],
        );
      },
    );
  }

  Widget _buildDoseSection(
    BuildContext context,
    MedicineFormProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dose Amount',
          style: context.theme.typography.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),

        // Quick select chips
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: _commonDoses.map((dose) {
            final isSelected = _doseController.text == dose;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  _doseController.text = dose;
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? context.theme.colors.primary
                        : context.theme.colors.muted,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? context.theme.colors.primary
                          : context.theme.colors.border,
                    ),
                  ),
                  child: Text(
                    dose,
                    style: context.theme.typography.sm.copyWith(
                      color: isSelected
                          ? context.theme.colors.primaryForeground
                          : context.theme.colors.foreground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),

        SizedBox(height: 16.h),

        // Custom dose input
        FTextField(
          controller: _doseController,
          label: const Text('Dose Amount'),
          hint: 'e.g., 1 tablet, 5ml, 2 pills',
        ),
      ],
    );
  }

  Widget _buildStrengthSection(
    BuildContext context,
    MedicineFormProvider provider,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strength',
          style: context.theme.typography.lg.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(
              flex: 2,
              child: FTextField(
                controller: _strengthController,
                label: const Text('Amount'),
                hint: 'e.g., 500',
                keyboardType: TextInputType.number,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(flex: 1, child: _buildUnitSelector(context, provider)),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitSelector(
    BuildContext context,
    MedicineFormProvider provider,
  ) {
    return Material(
      color: Colors.transparent,
      child: PopupMenuButton<String>(
        initialValue: _selectedUnit,
        onSelected: (unit) {
          setState(() {
            _selectedUnit = unit;
          });
          // Update the strength in provider
          provider.setStrength('$_strengthController.text$unit');
        },
        child: FCard(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedUnit,
                    style: context.theme.typography.lg.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  FIcons.chevronDown,
                  size: 16.r,
                  color: context.theme.colors.mutedForeground,
                ),
              ],
            ),
          ),
        ),
        itemBuilder: (context) => _commonUnits.map((unit) {
          return PopupMenuItem<String>(value: unit, child: Text(unit));
        }).toList(),
      ),
    );
  }
}
