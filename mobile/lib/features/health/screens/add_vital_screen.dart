import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/extensions/vital_type_extensions.dart';
import '../../../core/models/vital_measurement_model.dart';
import '../../../core/providers/health_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/modern_surface_theme.dart';
import '../../../core/widgets/modern_scaffold.dart';

class AddVitalScreen extends StatefulWidget {
  const AddVitalScreen({super.key});

  @override
  State<AddVitalScreen> createState() => _AddVitalScreenState();
}

class _AddVitalScreenState extends State<AddVitalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();

  VitalType _selectedType = VitalType.bloodPressure;
  final DateTime _timestamp = DateTime.now();

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser!.id;

    final vital = VitalMeasurementModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _selectedType,
      value: _valueController.text.trim(),
      timestamp: _timestamp,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      userId: userId,
    );

    final success = await context.read<HealthProvider>().addVital(vital);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Vital logged successfully'),
            backgroundColor: AppTheme.getSuccessColor(context),
          ),
        );
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to log vital'),
            backgroundColor: AppTheme.getErrorColor(context),
          ),
        );
      }
    }
  }

  String _getHintText() {
    switch (_selectedType) {
      case VitalType.bloodPressure:
        return 'e.g., 120/80';
      case VitalType.bloodSugar:
        return 'e.g., 95';
      case VitalType.heartRate:
        return 'e.g., 72';
      case VitalType.temperature:
        return 'e.g., 98.6';
      case VitalType.oxygenSaturation:
        return 'e.g., 98';
      case VitalType.weight:
        return 'e.g., 170';
    }
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
      child: ModernScaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Log Vital',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: SingleChildScrollView(
          padding: ModernSurfaceTheme.screenPadding(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  decoration: ModernSurfaceTheme.glassCard(context),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Vital Type',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: ModernSurfaceTheme.deepTeal,
                            ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButton<VitalType>(
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
                              _valueController.clear();
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                FTextField(
                  controller: _valueController,
                  label: Text('${_selectedType.displayName} (${_selectedType.unit})'),
                  hint: _getHintText(),
                  keyboardType: TextInputType.text,
                ),
                SizedBox(height: 16.h),
                FTextField(
                  controller: _notesController,
                  label: const Text('Notes (Optional)'),
                  hint: 'Additional notes',
                  maxLines: 3,
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ModernSurfaceTheme.primaryTeal,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text('Save Vital'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
