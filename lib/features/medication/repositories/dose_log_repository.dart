import 'package:hive_flutter/hive_flutter.dart';
import 'package:medication_reminder/features/medication/models/dose_log.dart';

class DoseLogRepository {
  final Box<DoseLog> _box = Hive.box<DoseLog>('logs');

  Future<void> saveLog(DoseLog log) async {
    final key = '${log.medId}_${log.scheduledTime.millisecondsSinceEpoch}';
    await _box.put(key, log);
  }

  Future<List<DoseLog>> getAllLogs() async {
    return _box.values.toList();
  }

  Future<List<DoseLog>> getLogsForToday() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return _box.values
        .where(
          (log) =>
              log.scheduledTime.isAfter(
                start.subtract(const Duration(seconds: 1)),
              ) &&
              log.scheduledTime.isBefore(end),
        )
        .toList();
  }
}
