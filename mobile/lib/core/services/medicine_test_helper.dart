import '../models/medicine_model.dart';
import '../services/medication_service.dart';

/// Helper class for testing medicine functionality
class MedicineTestHelper {
  static final MedicationService _medicationService = MedicationService();

  /// Test adding a medicine
  static Future<void> testAddMedicine() async {
    print('Testing medicine addition...');

    try {
      final testMedicine = MedicineModel(
        id: 'test-med-${DateTime.now().millisecondsSinceEpoch}',
        name: 'Test Medicine',
        dosage: '1 tablet',
        frequency: MedicineFrequency.daily,
        startDate: DateTime.now(),
        reminderTimes: ['09:00', '18:00'],
        userId: 'test-user',
        medicineForm: MedicineForm.tablet,
        strength: '500mg',
        doseAmount: '1 tablet',
      );

      final added = await _medicationService.addMedicine(testMedicine);
      print('✅ Medicine added successfully: ${added.name}');

      // Test retrieving medicines
      final medicines = await _medicationService.getMedicines('test-user');
      print('✅ Retrieved ${medicines.length} medicines');
    } catch (e) {
      print('❌ Medicine addition failed: $e');
    }
  }

  /// Run all medicine tests
  static Future<void> runAllTests() async {
    print('🧪 Starting Medicine Tests...\n');

    await testAddMedicine();
    print('');

    print('🏁 Medicine Tests completed!');
  }
}
