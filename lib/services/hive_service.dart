import 'package:hive_flutter/hive_flutter.dart';
import 'package:medication_reminder/features/medication/models/medication.dart';
import 'package:medication_reminder/features/medication/models/dose_log.dart';

class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MedicationAdapter());
    Hive.registerAdapter(DoseLogAdapter());
    await Hive.openBox<Medication>('meds');
    await Hive.openBox<DoseLog>('logs');
  }
}
