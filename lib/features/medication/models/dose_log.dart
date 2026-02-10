import 'package:hive_flutter/hive_flutter.dart';

part 'dose_log.g.dart';

@HiveType(typeId: 1)
class DoseLog extends HiveObject {
  @HiveField(0)
  final String medId;

  @HiveField(1)
  final DateTime scheduledTime;

  @HiveField(2)
  final DateTime? takenAt;

  @HiveField(3)
  final bool isMissed;

  DoseLog({
    required this.medId,
    required this.scheduledTime,
    this.takenAt,
    this.isMissed = false,
  });
}
