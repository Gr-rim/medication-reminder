import 'package:hive_flutter/hive_flutter.dart';
import 'package:medication_reminder/features/medication/models/medication.dart';

class MedRepository {
  final Box<Medication> _box = Hive.box<Medication>('meds');

  Future<void> addMed(Medication med) async {
    await _box.put(med.id, med);
  }

  Future<List<Medication>> getAllMeds() async {
    return _box.values.toList();
  }
}
